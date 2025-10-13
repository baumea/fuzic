#!/bin/sh

set -eu

# The user interface of this application is composed out of the following
# views:
# - VIEW_ARTIST: Show all release group of an artist
# - VIEW_RELEASEGROUP: Show all releases within a release group
# - VIEW_RELEASE: Show track list of a release
# - VIEW_SEARCH_ARTIST: Interface to search artists on MusicBrainz
# - VIEW_SEARCH_ALBUM: Interface to search albums (release groups) on MusicBrainz
# - VIEW_LIST_ARTISTS: Presentation of all artists in the local database
# - VIEW_LIST_ALBUMS: Presentation of all albums (release groups) in the local database
# - VIEW_SELECT_ARTIST: Interface for the user to select an artist
# - VIEW_PLAYLIST: View on the currently loaded playlist and playlist manipulation
# - VIEW_QUIT: Exiting view, to terminate the application
#
# All views but the last three are handled within a single fzf instance. The
# views VIEW_SELECT_ARTIST and VIEW_PLAYLIST run each in a separate fzf
# instance. The last view (VIEW_QUIT) does nothing but terminate the
# application.
#
# The fzf instance comprising VIEW_ARTIST - VIEW_LIST_ALBUMS is always in one
# of two modes: normale mode (MODE_NORMAL) or insert mode (MODE_INSERT). Both
# modes come with different key bindings. It is only in the insert mode that
# the query string can be written.
#
# All views and modes are referred to by the following constants. The values
# are arbitrary but must be distinct.
VIEW_ARTIST="artist"
VIEW_RELEASEGROUP="rg"
VIEW_RELEASE="release"
VIEW_SEARCH_ARTIST="search-artist"
VIEW_SEARCH_ALBUM="search-album"
VIEW_LIST_ARTISTS="list-artists"
VIEW_LIST_ALBUMS="list-albums"
VIEW_SELECT_ARTIST="select-artist"
VIEW_PLAYLIST="playlist"
VIEW_PLAYLIST_PLAYLISTSTORE="playlist-list"
VIEW_PLAYLIST_STORE="playlist-store"
VIEW_QUIT="quit"
MODE_NORMAL="hidden"
MODE_INSERT="show"

# Methods and variables used in main instance and subprocesses
# Load application information
. "sh/info.sh"

# Load logging methods
. "sh/log.sh"

# Load configuration
. "sh/config.sh"

# Load mpv methods
. "sh/mpv.sh"

# Load query methods
. "sh/query.sh"

# Load local file handling
. "sh/local.sh"

# Load playlist tools
. "sh/playlist.sh"

# Load playback helper
. "sh/playback.sh"

# Load MusicBrainz, Discogs, and wiki methods
. "sh/api.sh"

# Load preview methods
. "sh/preview.sh"

# Load cache functionality
. "sh/cache.sh"

# Load MusicBrainz wrappers
. "sh/mb.sh"

# Load list-generating methods
. "sh/lists.sh"

# FZF handlers
. "sh/fzf.sh"

# Load keys
. "sh/keys.sh"

# Load sorting methods
. "sh/sort.sh"

# Load theme
. "sh/theme.sh"

# Load tools
. "sh/tools.sh"

# Load AWK scripts
. "sh/awk.sh"

# Load filters
. "sh/filter.sh"

# Command-line options that may only be used internally.
#   --lines
#   --playback
#   --playlist
#   --action-playlistcursor
#   --action-filter
#   --action-gotoartist
#   --action-draw
#   --mbsearch
#   --preview
#   --show-keybindings
#   --remove-from-cache
case "${1:-}" in
"--lines")
  # Print lines that are fed into fzf.
  #
  # @argument $2: view
  # @argument $3: MusicBrainz ID
  #
  # The first argument `view` may be one of VIEW_ARTIST, VIEW_RELEASEGROUP,
  # VIEW_RELEASE, VIEW_LIST_ARTISTS, VIEW_LIST_ALBUMS, and VIEW_PLAYLIST. The
  # MusicBrainz ID  is required for the first three views, and denotes the
  # MusicBrainz ID of the respective object.
  view=${2:-}
  mbid=${3:-}
  case "$view" in
  "$VIEW_ARTIST") list_releasegroups "$mbid" ;;
  "$VIEW_RELEASEGROUP") list_releases "$mbid" ;;
  "$VIEW_RELEASE") list_recordings "$mbid" ;;
  "$VIEW_LIST_ARTISTS") list_local_artists ;;
  "$VIEW_LIST_ALBUMS") list_local_releasegroups ;;
  "$VIEW_PLAYLIST") list_playlist ;;
  "$VIEW_SEARCH_ARTIST" | "$VIEW_SEARCH_ALBUM") mb_results_async ;;
  esac
  exit 0
  ;;
"--playback")
  # Control mpv instance (see `src/sh/playback.sh`)
  #
  # @argument $2: view
  # @argument $3: MusicBrainz ID of current object
  # @argument $4: MusicBrainz ID of selected object
  # @argument $5: Path to decoration file
  shift
  playback "$@"
  exit 0
  ;;
"--playlist")
  # Run playback commands (see `src/sh/playlits.sh`)
  #
  # @argument $2: playlist command
  shift
  playlist "$@"
  exit 0
  ;;
"--action-playlistcursor")
  # Print fzf command to replace cursor in playlist
  #
  # This prints the command read by a `transform` fzf binding, with which the
  # cursor is placed on the currently played track in the playlist view.
  pos=$(mpv_playlist_position)
  printf "pos(%s)" $((pos + 1))
  exit 0
  ;;
"--action-filter")
  # fzf instructions to invoke filters
  #
  # @argument #2: mode
  # @argument #3: view
  #
  # This option takes the key pressed (FZF_KEY), translates it to the preset
  # query of that key in that view, and prints the fzf instructions which sets
  # that query.
  mode=$2
  view=$3
  q="$(default_query "$view" "$FZF_KEY")"
  [ "$q" ] && q="$q "
  printf "show-input+change-query(%s)" "$q"
  [ "$mode" = "$MODE_NORMAL" ] && printf "+hide-input"
  exit 0
  ;;
"--action-gotoartist")
  # fzf instructions to go to artist
  #
  # @argument $2: mode
  # @argument $3: view
  # @argument $4: MusicBrainz ID of current object
  # @argument $5: MusicBrainz ID of selected object
  #
  # With this option, fzf instructions are printed that divert the user to the
  # view VIEW_ARTIST of the artist of the selected object (of it is a
  # single-artist object), or that divert the user to a choice
  # (VIEW_SELECT_ARTIST) of all artists of the selected object. In the view
  # VIEW_PLAYLIST, the latter path is also taken for single-artist objects. The
  # reason for this is that VIEW_PLAYLIST and VIEW_ARTIST are not implemented
  # in the same fzf instance, and VIEW_SELECT_ARTIST already provides an
  # interface to switch from VIEW_PLAYLIST to VIEW_ARTIST.
  mode=$2
  view=$3
  mbid_cur="${4:-}"
  mbid="${5:-}"
  case "$view" in
  "$VIEW_ARTIST" | "$VIEW_SEARCH_ALBUM" | "$VIEW_LIST_ALBUMS") j="$(mb_releasegroup "$mbid" | $JQ '."artist-credit"')" ;;
  "$VIEW_RELEASEGROUP") j="$(mb_release "$mbid" | $JQ '."artist-credit"')" ;;
  "$VIEW_RELEASE" | "$VIEW_PLAYLIST") j="$(mb_release "$mbid_cur" | $JQ ".media | map(.tracks) | flatten[] | select(.id == \"$mbid\") | .\"artist-credit\"")" ;;
  "$VIEW_SEARCH_ARTIST" | "$VIEW_LIST_ARTISTS") aid="$mbid" ;;
  esac
  if [ "$view" = "$VIEW_PLAYLIST" ]; then
    printf "print(%s)+print(%s)+print(%s)+print(%s)+accept" "$VIEW_SELECT_ARTIST" "$j" "$view" "$mbid_cur"
    exit 0
  fi
  if [ "${j:-}" ]; then
    cnt=$(echo "$j" | $JQ 'length')
    [ "$cnt" -eq 1 ] && aid="$(echo "$j" | $JQ '.[0].artist.id')"
  fi
  [ "${aid:-}" ] && $0 --action-draw "$mode" "$VIEW_ARTIST" "0" "$aid" || printf "print(%s)+print(%s)+print(%s)+print(%s)+accept" "$VIEW_SELECT_ARTIST" "$j" "$view" "$mbid_cur"
  exit 0
  ;;
"--action-draw")
  # Generate fzf command to draw screen.
  #
  # @argument $2: mode (default `normal`)
  # @argument $3: view (default list artists)
  # @argument $4: level
  # @argument $5: MusicBrainz ID (optional)
  #
  # The argument `level` specifies the view relative to `view`: If `level` is
  # set to +1, then the specified MusicBrainz ID is an ID of an object one
  # level deeper than `view`. Similarly, the argument `level` may be set to
  # `-1`. Anything else is interpreted as "on the level of `view`".
  #
  # The choice of possible levels ($4) depends on the view.
  # These views are independent of the MusicBrainz ID ($5) and of the argument
  # ($5):
  # - VIEW_SEARCH_ARTIST: Get ready to query MusicBrainz for artists
  # - VIEW_SEARCH_ALBUM: Get ready to query MusicBrainz for albums
  # - VIEW_LIST_ARTISTS: List all locally available artists
  # - VIEW_LIST_ALBUMS: List al locally available albums
  #
  # If no level ($4) is specified, then the remaining views act as follows:
  # - VIEW_ARTIST: Display all release groups of that artist
  # - VIEW_RELEASEGROUP: Display all releases within that release group
  # - VIEW_RELEASE: Display track list of specified release
  #
  # Here, if the level is set to `-1`, then the parent entry is displayed:
  # - VIEW_ARTIST: Divert view to VIEW_LIST_ARTISTS
  # - VIEW_RELEASEGROUP: For single-artist release groups, divert to
  #   VIEW_ARTIST of that artist, else display the artist selection.
  # - VIEW_RELEASE: Divert view to VIEW_LIST_RELEASEGROUP.
  #
  # Alternatively, if the level is set to `+1`, then the child entry is
  # displayed:
  # - VIEW_ARTIST: Divert view to VIEW_LIST_ARTISTS
  # - VIEW_RELEASEGROUP: For single-artist release groups, divert to
  #   VIEW_ARTIST of that artist, else display the artist selection.
  # - VIEW_RELEASE: Divert view to VIEW_LIST_RELEASEGROUP.
  mode="${2:-"$MODE_NORMAL"}"
  view="${3:-"$VIEW_LIST_ARTISTS"}"
  level="${4:-}"
  mbid="${5:-}"
  # Change state, if we are being diverted.
  case "$level" in
  "-1")
    case "$view" in
    "$VIEW_ARTIST")
      view="$VIEW_LIST_ARTISTS"
      mbid=""
      ;;
    "$VIEW_RELEASEGROUP")
      view="$VIEW_ARTIST"
      mbid="$(mb_releasegroup "$mbid" | $JQ '."artist-credit"[0].artist.id')"
      ;;
    "$VIEW_RELEASE")
      view="$VIEW_RELEASEGROUP"
      mbid="$(mb_release "$mbid" | $JQ '."release-group".id')"
      ;;
    esac
    ;;
  "+1")
    case "$view" in
    "$VIEW_SEARCH_ARTIST" | "$VIEW_LIST_ARTISTS") view="$VIEW_ARTIST" ;;
    "$VIEW_ARTIST" | "$VIEW_SEARCH_ALBUM" | "$VIEW_LIST_ALBUMS") view="$VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASEGROUP") view="$VIEW_RELEASE" ;;
    esac
    ;;
  *) ;;
  esac
  # Set initial query
  q="$(default_query "$view")"
  [ "$q" ] && q="$q "
  printf "show-input+change-query(%s)" "$q"
  # Store current state
  printf "+change-list-label(%s)" "$view"
  printf "+change-border-label(%s)" "$mbid"
  # Set header
  fzf_command_set_header "$view" "$mbid"
  # Set preview window
  case "$view" in
  "$VIEW_LIST_ARTISTS" | "$VIEW_SEARCH_ARTIST") printf "+show-preview" ;;
  *) printf "+hide-preview" ;;
  esac
  # Handle MusicBrainz search views
  # - `change` trigger for async. MusicBrainz search
  # - input visible but search disabled
  case "$view" in
  "$VIEW_SEARCH_ARTIST" | "$VIEW_SEARCH_ALBUM") printf "+rebind(change)+disable-search" ;;
  *) printf "+unbind(change)+enable-search" ;;
  esac
  # Load lines
  printf "+reload($0 --lines %s %s)" "$view" "$mbid"
  [ "$mode" = "$MODE_NORMAL" ] && printf "+hide-input"
  exit 0
  ;;
"--mbsearch")
  # Trigger search on MusicBrainz
  #
  # @argument $2: view
  #
  # This stops any search being executed and initiates a new query through the
  # MusicBrainz API. The results will be made available through the ``--lines
  # <view>`` command.
  mb_search_async "$2"
  exit 0
  ;;
"--preview")
  # Generate content for preview window
  #
  # @argument $2: view
  # @argument $3: MusicBrainz ID of selected item
  #
  # This prints the text to be displayed in the preview window.
  view=$2
  mbid="${3:-}"
  case "$view" in
  "$VIEW_LIST_ARTISTS" | "$VIEW_SEARCH_ARTIST" | "$VIEW_SELECT_ARTIST") preview_artist "$mbid" ;;
  *) preview_nothing ;;
  esac
  exit 0
  ;;
"--show-keybindings")
  # Print keybindings for current view
  #
  # @argument $2: view
  print_keybindings "$2"
  exit 0
  ;;
"--remove-from-cache")
  # Remove entry from cache to reload
  #
  # @argument $2: view
  # @argument $3: MusicBrainz ID of current object
  # @argument $4: MusicBrainz ID of selected object
  case "$2" in
  "$VIEW_ARTIST")
    cache_rm_artist "$3"
    cache_rm_releasegroup "$4"
    ;;
  "$VIEW_RELEASEGROUP")
    cache_rm_releasegroup "$3"
    cache_rm_release "$4"
    ;;
  "$VIEW_RELEASE") cache_rm_release "$3" ;;
  "$VIEW_LIST_ALBUMS" | "$VIEW_SEARCH_ALBUM") cache_rm_releasegroup "$4" ;;
  esac
  exit 0
  ;;
esac

# Non-interactive user commands intended to the user. These commands do not
# require temporary files, fzf, nor the mpv instance.
case "${1:-}" in
"--decorate")
  # Decorate directory with tagged audio files
  #
  # @argument $2: path
  #
  # This method reads the tags of the audio files in the specified directory.
  # If the audio files contain MusicBrainz tags, and they are consistent, then
  # a decoration file is written to that directory.
  [ ! "$FFPROBE" ] && err "This option requires ffprobe. Quitting the application now." && exit 1
  [ ! "${2:-}" ] && err "You did not specify a directory." && exit 1
  [ ! -d "$2" ] && err "Path $2 does not point to a directory." && exit 1
  if ! decorate "$2"; then
    err "Something went wrong. Are you're files tagged correctly?"
    exit 1
  fi
  exit 0
  ;;
"--decorate-as")
  # Decorate the specified directory as given MusicBrainz release
  #
  # @argument $2: path
  # @argument $3: MusicBrainz release ID
  [ ! "${2:-}" ] && err "You did not specify a directory." && exit 1
  [ ! -d "$2" ] && err "Path $2 does not point to a directory." && exit 1
  [ ! "${3:-}" ] && err "You did not specify a MusicBrainz release ID." && exit 1
  [ ! "$(mb_release "$3" | $JQ '.title // ""')" ] && err "Did you specify a correct MusicBrainz release ID?" && exit 1
  if ! decorate_as "$2" "$3"; then
    err "Something went wrong."
    exit 1
  fi
  exit 0
  ;;
"--reload-database")
  # Reload database of local music
  #
  # @argument $2: path
  #
  # This method reconstructs the database of locally available music. This is
  # done by traversing the directories under `path` and looking for decorated
  # entries.
  [ ! "${2:-}" ] && err "Path to decorated music is missing." && exit 1
  [ ! -d "$2" ] && err "Path does not point to a directory." && exit 1
  info "Reloading information of local music directory $2"
  reloaddb "$2" || err "Failed to load local data"
  info "Done"
  exit 0
  ;;
"--playlists")
  # List available playlists
  stored_playlists
  exit 0
  ;;
"--print-playlist")
  # Pretty print playlist
  list_playlist_stored "${2:-}" |
    cut -d "$(printf '\t')" -f 1
  exit 0
  ;;
"--help")
  # Print help string
  cat <<EOF
Usage: $0 [OPTION]

GENERAL OPTIONS:
  --help                        Show this help and exit
  --artists                     Default options, list artists of local music
  --albums                      List albums of local music
  --search-artist               Search artist on MusicBrainz
  --search-album                Search album on MusicBrainz
  --artist <mbid>               List release groups of given artist <mbid>
  --releasegroup <mbid>         List releases in given release group <mbid>
  --release <mbid>              Show release given by <mbid>
  --playlists                   List stored playlists and exit
  --load-playlist <playlist>    Load specified playlist
  --print-playlist <playlist>   Print specified playlist and exit

MANAGE LOCAL MUSIC:
  --decorate <path>             Decorate directory containing a tagged release
  --decorate-as <path> <mbid>   Decorate directory as the relase <mbid>
  --reload-database <path>      Populate database with decorated local music from <path>
EOF
  exit 0
  ;;
esac

# Interactive user commands
# If no unknown command is passed, then this will continue to starting the mpv
# instance and fzf.
case "${1:-}" in
"--artist")
  [ ! "${2:-}" ] && err "MusicBrainz Artist ID not specified (see --help)" && exit 1
  VIEW="$VIEW_ARTIST"
  MODE="$MODE_NORMAL"
  MBID="$2"
  ;;
"--releasegroup")
  [ ! "${2:-}" ] && err "MusicBrainz Release-Group ID not specified (see --help)" && exit 1
  VIEW="$VIEW_RELEASEGROUP"
  MODE="$MODE_NORMAL"
  MBID="$2"
  ;;
"--release")
  [ ! "${2:-}" ] && err "MusicBrainz Release ID not specified (see --help)" && exit 1
  VIEW="$VIEW_RELEASE"
  MODE="$MODE_NORMAL"
  MBID="$2"
  ;;
"--search-artist")
  VIEW="$VIEW_SEARCH_ARTIST"
  MODE="$MODE_INSERT"
  MBID=""
  ;;
"--search-album")
  VIEW="$VIEW_SEARCH_ALBUM"
  MODE="$MODE_INSERT"
  MBID=""
  ;;
"--artists" | "")
  VIEW="$VIEW_LIST_ARTISTS"
  MODE="$MODE_NORMAL"
  MBID=""
  ;;
"--albums")
  VIEW="$VIEW_LIST_ALBUMS"
  MODE="$MODE_NORMAL"
  MBID=""
  ;;
"--load-playlist")
  # We will load and play later
  VIEW="$VIEW_PLAYLIST"
  MODE="$MODE_NORMAL"
  MBID=""
  ;;
*)
  err "Unknown option $1 (see --help)"
  exit 1
  ;;
esac

# For history purpose: previous view is always:
LASTVIEW="$VIEW_LIST_ARTISTS"
LASTARG=""

# Start application:
# - set title
# - check for missing data from MusicBrainz
# - precompute main views
# - get temporary directory for temporary files
# - start mpv daemon
# - enter main loop and start fzf

# Set window title
printf '\033]0;%s\007' "$WINDOW_TITLE"

# Check if the required json files are present
local_files_present || load_missing_files
# Generate views
precompute_views

# Generate filenames for temporary files
# We keep these files in a temporary directory and not in the state directory
# because this allows for straight-forward capability to run multiple instances
# simultaneously.
tmpdir=$(mktemp -d)
LOCKFILE="$tmpdir/lock"
RESULTS="$tmpdir/results"
PIDFILE="$tmpdir/pid"
trap 'rm -rf "$tmpdir"' EXIT INT
export LOCKFILE RESULTS PIDFILE

# Start mpv
mpv_start

# Playback possible now
if [ "${1:-}" = "--load-playlist" ]; then
  sleep 1
  $0 --playlist "$PLAYLIST_CMD_LOAD" "${2:-}"
fi

# main loop
# states are stored in (in)visible labels
#
# mode: [$MODE_NORMAL, $MODE_INSERT]
# The mode is reflected on the input visibility. The variable
# `FZF_INPUT_STATE`` is set to "hidden" if and only if the mode is `normal`. To
# swtich to `normal` mode, we call `hide-input`. To switch to insert mode, we
# call `show-input`.
#
# view: [$VIEW_*]
# The view is stored in `FZF_LIST_LABEL`. To set the view, call
# `change-list-label($VIEW)`.
#
# mbid:
# The MusicBrainz ID of the current object is stored in `FZF_BORDER_LABEL`.
IN_NORMAL_MODE="[ \$FZF_INPUT_STATE = hidden ]"
IN_VIEW_PATTERN="[ \$FZF_LIST_LABEL = %s ]"
IN_LIST_ARTISTS_VIEW="$(printf "$IN_VIEW_PATTERN" "$VIEW_LIST_ARTISTS")"
FZF_CURRENT_MODE="\$FZF_INPUT_STATE"
FZF_CURRENT_VIEW="\$FZF_LIST_LABEL"
FZF_CURRENT_MBID="\$FZF_BORDER_LABEL"
FZF_RELOAD_PLAYLIST="reload-sync($0 --lines $VIEW_PLAYLIST)"
FZF_POS_PLAYLIST="transform:$0 --action-playlistcursor"
PUT_FZF_KEY_LOGIC="case \$FZF_KEY in space) echo \"put( )\";; left) echo backward-char;; right) echo forward-char;; backspace|bspace|bs) echo backward-delete-char;; delete|del) echo delete-char;; *) echo \"put(\$FZF_KEY)\";; esac"
FZF_DEFAULT_PREVIEW_WINDOW="right,$PREVIEW_WINDOW_PERCENTAGE%,border-line,nowrap,<50(hidden)"
while true; do
  case "$VIEW" in
  "$VIEW_SELECT_ARTIST")
    sel=$(
      echo "$ARGS" | list_artists_from_json | $FZF \
        --bind="$KEYS_DOWN:down" \
        --bind="$KEYS_UP:up" \
        --bind="$KEYS_HALFPAGE_DOWN:half-page-down" \
        --bind="$KEYS_HALFPAGE_UP:half-page-up" \
        --bind="enter,$KEYS_IN:print($VIEW_ARTIST)+accept" \
        --bind="$KEYS_OUT,$KEYS_QUIT:print($LASTVIEW)+print($LASTARG)+accept" \
        --bind="$KEYS_LIST_ARTISTS:print($VIEW_LIST_ARTISTS)+accept" \
        --bind="$KEYS_LIST_ALBUMS:print($VIEW_LIST_ALBUMS)+accept" \
        --bind="$KEYS_SEARCH_ARTIST:print($VIEW_SEARCH_ARTIST)+accept" \
        --bind="$KEYS_SEARCH_ALBUM:print($VIEW_SEARCH_ALBUM)+accept" \
        --bind="$KEYS_BROWSE:execute-silent:open \"https://musicbrainz.org/artist/{r4}\"" \
        --bind="$KEYS_SHOW_PLAYLIST:print($VIEW_PLAYLIST)+print()+accept" \
        --bind="$KEYS_KEYBINDINGS:preview:$0 --show-keybindings $VIEW_SELECT_ARTIST" \
        --bind="$KEYS_SCROLL_PREVIEW_DOWN:preview-down" \
        --bind="$KEYS_SCROLL_PREVIEW_UP:preview-up" \
        --bind="$KEYS_PREVIEW_TOGGLE_WRAP:toggle-preview-wrap" \
        --bind="$KEYS_PREVIEW_TOGGLE_SIZE:change-preview-window(right,90%,border-line,nowrap|$FZF_DEFAULT_PREVIEW_WINDOW)" \
        --bind="$KEYS_PREVIEW_OPEN:show-preview" \
        --bind="$KEYS_PREVIEW_CLOSE:hide-preview" \
        --bind="$KEYS_FILTER_LOCAL:change-query($QUERY_LOCAL )" \
        -0 -1 \
        --border="bold" \
        --border-label="Select artist" \
        --preview-window="$FZF_DEFAULT_PREVIEW_WINDOW" \
        --wrap-sign="" \
        --preview="$0 --preview $VIEW_SELECT_ARTIST {4}" \
        --delimiter="\t" \
        --prompt="$SEARCH_PROMPT" \
        --margin="5%,20%" \
        --accept-nth="{4}" \
        --with-nth="{1}" || true
    )
    lines=$(echo "$sel" | wc -l)
    if [ "$lines" -eq 1 ]; then
      VIEW="$VIEW_ARTIST"
      MBID="$sel"
    else
      VIEW="$(echo "$sel" | head -1)"
      MBID="$(echo "$sel" | head -2 | tail -1)"
    fi
    LASTVIEW="$VIEW_SELECT_ARTIST"
    LASTARG="$ARGS"
    ;;
  "$VIEW_PLAYLIST_STORE")
    VIEW="$VIEW_PLAYLIST"
    ARGS=""
    MBID=""
    tmpf=$(mktemp)
    list_playlist | cut -d "$(printf '\t')" -f "3,4" >"$tmpf"
    # Make sure we store only nonempty playlists
    [ -s "$tmpf" ] || continue
    while true; do
      infonn "Enter playlist name:"
      read -r playlistname
      [ "$playlistname" ] || continue
      case "$playlistname" in
      *[!a-zA-Z0-9._-]*)
        info "Please use only alaphnumeric symbols and any of \".-_\" for the playlist name."
        ;;
      *)
        f="$PLAYLIST_DIRECTORY/$playlistname"
        if [ -s "$f" ]; then
          while true; do
            infonn "Playlist with name \"$playlistname\" already exists. Do you want to overwrite it? (yes/no)"
            read -r yn
            case $yn in
            "yes" | "no") break ;;
            *) info "Please answer \"yes\" or \"no\"." ;;
            esac
          done
          [ "$yn" = "yes" ] || continue
        fi
        break
        ;;
      esac
    done
    mv "$tmpf" "$f"
    ;;
  "$VIEW_PLAYLIST_PLAYLISTSTORE")
    sel=$(
      stored_playlists | $FZF \
        --border=double \
        --border-label="$TITLE_PLYLST_STORE" \
        --margin="2%,10%" \
        --bind="$KEYS_I_NORMAL:" \
        --bind="$KEYS_DOWN:down" \
        --bind="$KEYS_UP:up" \
        --bind="$KEYS_HALFPAGE_DOWN:half-page-down" \
        --bind="$KEYS_HALFPAGE_UP:half-page-up" \
        --bind="$KEYS_OUT,$KEYS_QUIT:accept" \
        --bind="$KEYS_KEYBINDINGS:preview:$0 --show-keybindings $VIEW_PLAYLIST_PLAYLISTSTORE" \
        --bind="$KEYS_SCROLL_PREVIEW_DOWN:preview-down" \
        --bind="$KEYS_SCROLL_PREVIEW_UP:preview-up" \
        --bind="$KEYS_PREVIEW_TOGGLE_WRAP:toggle-preview-wrap" \
        --bind="$KEYS_PREVIEW_TOGGLE_SIZE:change-preview-window(right,90%,border-line,nowrap|$FZF_DEFAULT_PREVIEW_WINDOW)" \
        --bind="$KEYS_PREVIEW_OPEN:show-preview" \
        --bind="$KEYS_PREVIEW_CLOSE:hide-preview" \
        --bind="$KEYS_PLAYLISTSTORE_SELECT:transform:[ {1} ] && $0 --playlist $PLAYLIST_CMD_LOAD {2} && echo accept" \
        --bind="$KEYS_PLAYLISTSTORE_DELETE:transform:[ {1} ] && rm \"$PLAYLIST_DIRECTORY/{r2}\" && echo \"reload($0 --playlists\)\"" \
        --preview="$0 --print-playlist {2}" \
        --preview-window="$FZF_DEFAULT_PREVIEW_WINDOW" \
        --with-nth="{1}" \
        --delimiter="\t" \
        --wrap-sign="" || true
    )
    VIEW="$VIEW_PLAYLIST"
    ;;
  "$VIEW_PLAYLIST")
    sel=$(
      list_playlist | $FZF \
        --reverse \
        --no-sort \
        --border=double \
        --border-label="$TITLE_PLYLST" \
        --no-input \
        --margin="2%,10%" \
        --bind="$KEYS_I_NORMAL:" \
        --bind="$KEYS_DOWN,$KEYS_N_DOWN:down" \
        --bind="$KEYS_UP,$KEYS_N_UP:up" \
        --bind="$KEYS_HALFPAGE_DOWN:half-page-down" \
        --bind="$KEYS_HALFPAGE_UP:half-page-up" \
        --bind="$KEYS_N_BOT:last" \
        --bind="$KEYS_N_TOP:first" \
        --bind="$KEYS_OUT,$KEYS_N_OUT,$KEYS_QUIT,$KEYS_N_QUIT:print($LASTVIEW)+print($LASTARG)+print($VIEW_PLAYLIST)+print()+accept" \
        --bind="$KEYS_SELECT_ARTIST:transform:$0 --action-gotoartist $MODE_NORMAL $VIEW_PLAYLIST {3} {4}" \
        --bind="$KEYS_LIST_ARTISTS:print($VIEW_LIST_ARTISTS)+accept" \
        --bind="$KEYS_LIST_ALBUMS:print($VIEW_LIST_ALBUMS)+accept" \
        --bind="$KEYS_SEARCH_ARTIST:print($VIEW_SEARCH_ARTIST)+accept" \
        --bind="$KEYS_SEARCH_ALBUM:print($VIEW_SEARCH_ALBUM)+accept" \
        --bind="$KEYS_BROWSE:execute-silent:open \"https://musicbrainz.org/\track/{r4}\"" \
        --bind="$KEYS_OPEN:execute-silent:open \"\$(dirname {5})\"" \
        --bind="$KEYS_N_YANK:execute-silent:printf {4} | $CLIP)" \
        --bind="$KEYS_YANK_CURRENT:execute-silent:printf {3} | $CLIP" \
        --bind="$KEYS_KEYBINDINGS:preview:$0 --show-keybindings $VIEW_PLAYLIST" \
        --bind="$KEYS_SCROLL_PREVIEW_DOWN:preview-down" \
        --bind="$KEYS_SCROLL_PREVIEW_UP:preview-up" \
        --bind="$KEYS_PREVIEW_TOGGLE_WRAP:toggle-preview-wrap" \
        --bind="$KEYS_PREVIEW_TOGGLE_SIZE:change-preview-window(right,90%,border-line,nowrap|$FZF_DEFAULT_PREVIEW_WINDOW)" \
        --bind="$KEYS_PREVIEW_CLOSE:hide-preview" \
        --bind="$KEYS_PLAYBACK,$KEYS_N_PLAYBACK:transform($0 --playback $VIEW_PLAYLIST {3} {4} {5})+$FZF_RELOAD_PLAYLIST+$FZF_POS_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_RELOAD,$KEYS_SHOW_PLAYLIST:$FZF_RELOAD_PLAYLIST+$FZF_POS_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_REMOVE:execute-silent($0 --playlist $PLAYLIST_CMD_REMOVE)+$FZF_RELOAD_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_UP:execute-silent($0 --playlist $PLAYLIST_CMD_UP)+up+$FZF_RELOAD_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_DOWN:execute-silent($0 --playlist $PLAYLIST_CMD_DOWN)+down+$FZF_RELOAD_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_CLEAR:execute-silent($0 --playlist $PLAYLIST_CMD_CLEAR)+$FZF_RELOAD_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_CLEAR_ABOVE:execute-silent($0 --playlist $PLAYLIST_CMD_CLEAR_ABOVE)+$FZF_RELOAD_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_CLEAR_BELOW:execute-silent($0 --playlist $PLAYLIST_CMD_CLEAR_BELOW)+$FZF_RELOAD_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_SHUFFLE:execute-silent($0 --playlist $PLAYLIST_CMD_SHUFFLE)+$FZF_RELOAD_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_UNSHUFFLE:execute-silent($0 --playlist $PLAYLIST_CMD_UNSHUFFLE)+$FZF_RELOAD_PLAYLIST" \
        --bind="$KEYS_PLAYLIST_GOTO_RELEASE:print($VIEW_RELEASE)+accept" \
        --bind="$KEYS_PLAYLIST_STORE:print($VIEW_PLAYLIST_STORE)+print("")+print($LASTVIEW)+print($LASTARG)+accept" \
        --bind="$KEYS_PLAYLIST_OPEN_STORE:print($VIEW_PLAYLIST_PLAYLISTSTORE)+print("")+print($LASTVIEW)+print($LASTARG)+accept" \
        --preview-window="hidden" \
        --wrap-sign="" \
        --delimiter="\t" \
        --with-nth="{1}" \
        --accept-nth="{3}" || true
    )
    VIEW="$(echo "$sel" | head -1)"
    ARGS="$(echo "$sel" | head -2 | tail -1)"
    MBID=$ARGS
    LASTVIEW="$(echo "$sel" | head -3 | tail -1)"
    LASTARG="$(echo "$sel" | head -4 | tail -1)"
    ;;
  "$VIEW_QUIT")
    break
    ;;
  *)
    # Main instance
    #
    # KEY-BINDINGS:
    # Key variables contain comma-delimited sequences of keys. Every key
    # variable starts with `KEYS_`. Key variables with the prefix `KEYS_I_` are
    # exclusive to the `insert` mode. Key variables with the prefix `KEYS_N_`
    # are exclusive to the `normal` mode. All other keys are bound to both
    # modes. It is important that the keys used in `KEYS_N_` variables are
    # naturally printable or modifications of the input string. See
    # `$PUT_FZF_KEY_LOGIC` for details.
    #
    # Here is a list of all keys grouped by type (see `src/sh/keys.sh`).
    #--bind="start:change-list-label($VIEW)+change-list-label($MBID)+$MODE-input+transform:$0 --display" \
    sel=$(
      printf "" | $FZF \
        --reverse \
        --info="inline-right" \
        --header-first \
        --header-border="bottom" \
        --bind="start:transform:$0 --action-draw $MODE $VIEW 0 $MBID" \
        --bind="$KEYS_I_NORMAL:transform:$IN_NORMAL_MODE || echo hide-input" \
        --bind="$KEYS_N_INSERT:transform:$IN_NORMAL_MODE && echo show-input || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_DOWN:down" \
        --bind="$KEYS_UP:up" \
        --bind="$KEYS_HALFPAGE_DOWN:half-page-down" \
        --bind="$KEYS_HALFPAGE_UP:half-page-up" \
        --bind="$KEYS_N_DOWN:transform:$IN_NORMAL_MODE && echo down || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_N_UP:transform:$IN_NORMAL_MODE && echo up || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_N_BOT:transform:$IN_NORMAL_MODE && echo last || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_N_TOP:transform:$IN_NORMAL_MODE && echo first || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_IN:transform:[ {4} ] && $0 --action-draw $FZF_CURRENT_MODE $FZF_CURRENT_VIEW \"+1\" {4}" \
        --bind="$KEYS_OUT:transform:$0 --action-draw $FZF_CURRENT_MODE $FZF_CURRENT_VIEW \"-1\" $FZF_CURRENT_MBID" \
        --bind="$KEYS_N_IN:transform:$IN_NORMAL_MODE && ([ {4} ] && $0 --action-draw $FZF_CURRENT_MODE $FZF_CURRENT_VIEW \"+1\" {4}) || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_N_OUT:transform:$IN_NORMAL_MODE && ($0 --action-draw $FZF_CURRENT_MODE $FZF_CURRENT_VIEW \"-1\" $FZF_CURRENT_MBID) || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_SELECT_ARTIST:transform:$0 --action-gotoartist $FZF_CURRENT_MODE $FZF_CURRENT_VIEW \"$FZF_CURRENT_MBID\" {4}" \
        --bind="$KEYS_LIST_ARTISTS:transform:$0 --action-draw \$FZF_INPUT_STATE $VIEW_LIST_ARTISTS \"0\"" \
        --bind="$KEYS_LIST_ALBUMS:transform:$0 --action-draw \$FZF_INPUT_STATE $VIEW_LIST_ALBUMS \"0\"" \
        --bind="$KEYS_SEARCH_ARTIST:transform:$0 --action-draw $MODE_INSERT $VIEW_SEARCH_ARTIST \"0\"" \
        --bind="$KEYS_SEARCH_ALBUM:transform:$0 --action-draw $MODE_INSERT $VIEW_SEARCH_ALBUM \"0\"" \
        --bind="$KEYS_SWITCH_ARTIST_ALBUM:transform:case $FZF_CURRENT_VIEW in
$VIEW_LIST_ARTISTS) $0 --action-draw $FZF_CURRENT_MODE $VIEW_LIST_ALBUMS \"0\" ;;
$VIEW_LIST_ALBUMS) $0 --action-draw $FZF_CURRENT_MODE $VIEW_LIST_ARTISTS \"0\";;
$VIEW_SEARCH_ARTIST) $0 --action-draw $MODE_INSERT $VIEW_SEARCH_ALBUM \"0\" ;;
$VIEW_SEARCH_ALBUM) $0 --action-draw $MODE_INSERT $VIEW_SEARCH_ARTIST \"0\" ;;
esac" \
        --bind="$KEYS_SWITCH_LOCAL_REMOTE:transform:case $FZF_CURRENT_VIEW in
$VIEW_LIST_ARTISTS) $0 --action-draw $MODE_INSERT $VIEW_SEARCH_ARTIST \"0\" ;;
$VIEW_LIST_ALBUMS) $0 --action-draw $MODE_INSERT $VIEW_SEARCH_ALBUM \"0\" ;;
$VIEW_SEARCH_ARTIST) $0 --action-draw $MODE_NORMAL $VIEW_LIST_ARTISTS \"0\" ;;
$VIEW_SEARCH_ALBUM) $0 --action-draw $MODE_NORMAL $VIEW_LIST_ALBUMS \"0\" ;;
esac" \
        --bind="$KEYS_FILTER:transform:$0 --action-filter $FZF_CURRENT_MODE $FZF_CURRENT_VIEW" \
        --bind="$KEYS_BROWSE:execute-silent:
[ {4} ] || exit 0
case $FZF_CURRENT_VIEW in
  $VIEW_LIST_ARTISTS | $VIEW_SEARCH_ARTIST) t=artist ;;
  $VIEW_ARTIST | $VIEW_SEARCH_ALBUM | $VIEW_LIST_ALBUMS) t=release-group ;;
  $VIEW_RELEASEGROUP) t=release ;;
  $VIEW_RELEASE) t=track ;;
esac
open \"https://musicbrainz.org/\$t/{r4}\"" \
        --bind="$KEYS_OPEN:execute-silent:
[ {5} ] || exit 0
open \"\$(dirname {5})\"" \
        --bind="$KEYS_N_YANK:transform:$IN_NORMAL_MODE && echo \"execute-silent(printf {4} | $CLIP)\" || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_YANK_CURRENT:execute-silent:printf $FZF_CURRENT_MBID | $CLIP" \
        --bind="$KEYS_SHOW_PLAYLIST:transform:echo \"print($VIEW_PLAYLIST)+print()+print($FZF_CURRENT_VIEW)+print($FZF_CURRENT_MBID)+accept\"" \
        --bind="$KEYS_KEYBINDINGS:preview:$0 --show-keybindings $FZF_CURRENT_VIEW" \
        --bind="$KEYS_REFRESH:execute-silent($0 --remove-from-cache $FZF_CURRENT_VIEW \"$FZF_CURRENT_MBID\" {4})+transform:$0 --action-draw $FZF_CURRENT_MODE $FZF_CURRENT_VIEW \"0\" $FZF_CURRENT_MBID" \
        --bind="$KEYS_QUIT:print($VIEW_QUIT)+accept" \
        --bind="$KEYS_N_QUIT:transform:$IN_NORMAL_MODE && ($IN_LIST_ARTISTS_VIEW && echo \"print($VIEW_QUIT)+accept\" || $0 --action-draw $MODE_NORMAL $VIEW_LIST_ARTISTS \"0\") || $PUT_FZF_KEY_LOGIC" \
        --bind="$KEYS_SCROLL_PREVIEW_DOWN:preview-down" \
        --bind="$KEYS_SCROLL_PREVIEW_UP:preview-up" \
        --bind="$KEYS_PREVIEW_TOGGLE_WRAP:toggle-preview-wrap" \
        --bind="$KEYS_PREVIEW_TOGGLE_SIZE:change-preview-window(right,90%,border-line,nowrap|$FZF_DEFAULT_PREVIEW_WINDOW)" \
        --bind="$KEYS_PREVIEW_OPEN:show-preview" \
        --bind="$KEYS_PREVIEW_CLOSE:hide-preview" \
        --bind="$KEYS_PLAYBACK:transform:$0 --playback $FZF_CURRENT_VIEW \"$FZF_CURRENT_MBID\" {4} {5}" \
        --bind="$KEYS_N_PLAYBACK:transform:$IN_NORMAL_MODE && $0 --playback $FZF_CURRENT_VIEW \"$FZF_CURRENT_MBID\" {4} {5} || $PUT_FZF_KEY_LOGIC" \
        --bind="change:execute-silent($0 --mbsearch $FZF_CURRENT_VIEW &)+reload:$0 --lines $FZF_CURRENT_VIEW" \
        --preview-window="$FZF_DEFAULT_PREVIEW_WINDOW" \
        --wrap-sign="" \
        --preview="$0 --preview $FZF_CURRENT_VIEW {4}" \
        --delimiter="\t" \
        --with-nth="{1}" || true
    )
    VIEW="$(echo "$sel" | head -1)"
    ARGS="$(echo "$sel" | head -2 | tail -1)"
    LASTVIEW="$(echo "$sel" | head -3 | tail -1)"
    LASTARG="$(echo "$sel" | head -4 | tail -1)"
    ;;
  esac
done
