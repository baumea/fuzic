# List of keys, organized in groups
#
# Mode selection:
# - KEYS_I_NORMAL: Switch to normal mode (insert mode)
# - KEYS_N_INSERT: Switch to insert mode (normal mode)
#
# Vertical navigation:
# - KEYS_DOWN: Move cursor to the next line
# - KEYS_UP: Move cursor to the previous line
# - KEYS_HALFPAGE_UP: Move cursor half a page up
# - KEYS_HALFPAGE_DOWN: Move cursor half a page up
# - KEYS_N_DOWN: Move cursor to the next line (normal mode)
# - KEYS_N_UP: Move cursor to the previous line (normal mode)
# - KEYS_N_BOT: Move cursor to the last line (normal mode)
# - KEYS_N_TOP: Move cursor to the first line (normal mode)
#
# Horizontal navigation:
# - KEYS_IN: Enter into selected item, down the hierarchy
# - KEYS_OUT: Leave current item, up the hierarchy
# - KEYS_N_IN: Enter into selected item, down the hierarchy (normal mode)
# - KEYS_N_OUT: Leave current item, up the hierarchy (normal mode)
# - KEYS_SELECT_ARTIST: Go to artist of selected entry (in case of multiple
# artists, provide a choice)
# - KEYS_LIST_ARTISTS: Go to VIEW_LIST_ARTISTS
# - KEYS_LIST_ALBUMS: Go to VIEW_LIST_ALBUMS
# - KEYS_SEARCH_ARTIST: Go to VIEW_SEARCH_ARTIST
# - KEYS_SEARCH_ALBUM: Go to VIEW_SEARCH_ALBUM
# - KEYS_SWITCH_ARTIST_ALBUM: Switch artist and album views, i.e.,
# VIEW_LIST_ARTISTS <-> VIEW_LIST_ALBUMS, and VIEW_SEARCH_ARTIST <->
# VIEW_SEARCH_ALBUM.
# - KEYS_SWITCH_LOCAL_REMOTE: Switch between locally available music and remote
# search views, i.e., VIEW_LIST_ARTISTS <-> VIEW_SEARCH_ARTIST, and
# VIEW_LIST_ALBUMS <-> VIEW_SEARCH_ALBUM.
#
# Filtering:
# - KEYS_FILTER_LOCAL: List only locally available entries
# - KEYS_FILTER_0: Clear query
# - KEYS_FILTER_1: Reset query to the default one for the current view (see `src/sh/filter.sh`)
# - KEYS_FILTER_2: Preset query `2` depending on the view (see `src/sh/filter.sh`)
# - KEYS_FILTER_3: Preset query `3` depending on the view (see `src/sh/filter.sh`)
# - KEYS_FILTER_4: Preset query `4` depending on the view (see `src/sh/filter.sh`)
# - KEYS_FILTER_5: Preset query `5` depending on the view (see `src/sh/filter.sh`)
# - KEYS_FILTER_6: Preset query `6` depending on the view (see `src/sh/filter.sh`)
# - KEYS_FILTER_7: Preset query `7` depending on the view (see `src/sh/filter.sh`)
# - KEYS_FILTER_8: Preset query `8` depending on the view (see `src/sh/filter.sh`)
# - KEYS_FILTER_9: Preset query `9` depending on the view (see `src/sh/filter.sh`)
#
# Specials:
# - KEYS_BROWSE: Open MusicBrainz webpage of the selected item
# - KEYS_OPEN: Open file manager in the directory of the selected item
# - KEYS_N_YANK: Copy MusicBrainz ID of selected item to clipboard
# - KEYS_YANK_CURRENT: Copy MusicBrainz ID of current item to clipboard
# - KEYS_SHOW_PLAYLIST: Switch to playlist view
# - KEYS_KEYBINDINGS: Show keybindings
# - KEYS_QUIT: Quit application
# - KEYS_N_QUIT: Quit application if we are in VIEW_LIST_ARTISTS, else go to
# view VIEW_LIST_ARTISTS (normal mode)
# - KEYS_SCROLL_PREVIEW_DOWN: Scroll preview down
# - KEYS_SCROLL_PREVIEW_UP: Scroll preview up
# - KEYS_PREVIEW_OPEN: Open preview window
# - KEYS_PREVIEW_CLOSE: Close preview window
# - KEYS_PREVIEW_TOGGLE_WRAP: Toggle line wrapping in preview window
# - KEYS_PREVIEW_TOGGLE_SIZE: Toggle size (small, large) of preview window
# - KEYS_REFRESH: Refresh current entry
#
# Playback:
# - KEYS_PLAY: Play selected release or selected track
# - KEYS_QUEUE: Queue selected release or selected track
# - KEYS_QUEUE_NEXT: Queue selected release or selected track as next entry in
# the playlist
# - KEYS_N_TOGGLE_PLAYBACK: Play-pause toggle
# - KEYS_N_PLAY_NEXT: Play next track
# - KEYS_N_PLAY_PREV: Play previous track
# - KEYS_N_SEEK_FORWARD: Seek forward
# - KEYS_N_SEEK_BACKWARD: Seek backward
#
# Playlist (in the playlist, there is no `insert` mode):
# - KEYS_PLAYLIST_RELOAD: Manually reload playlist
# - KEYS_PLAYLIST_REMOVE: Remove item from playlist
# - KEYS_PLAYLIST_UP: Move item one position up
# - KEYS_PLAYLIST_DOWN: Move item one position down
# - KEYS_PLAYLIST_CLEAR: Clear playlist
# - KEYS_PLAYLIST_CLEAR_ABOVE: Remove all items above incl. the selected one
# - KEYS_PLAYLIST_CLEAR_BELOW: Remove all items below incl. the selected one
# - KEYS_PLAYLIST_SHUFFLE: Shuffle playlist
# - KEYS_PLAYLIST_UNSHUFFLE: Unshuffle previously shuffled playlist
# - KEYS_PLAYLIST_GOTO_RELEASE: Jump to release or selected entry
# - KEYS_PLAYLIST_STORE: Store current playlist as file
# - KEYS_PLAYLIST_LOAD: Load playlist from file
#
# Playlist store (here, we don't have a `normal` mode):
# - KEYS_PLAYLISTSTORE_SELECT: Use selected playlist
# - KEYS_PLAYLISTSTORE_DELETE: Delete stored playlist

if [ ! "${KEYS_LOADED:-}" ]; then
  # Mode selection:
  KEYS_I_NORMAL="${KEYS_I_NORMAL:-"esc"}"
  KEYS_N_INSERT="${KEYS_N_INSERT:-"a,i,/,?"}"
  export KEYS_I_NORMAL KEYS_N_INSERT

  # Vertical navigation:
  KEYS_DOWN="${KEYS_DOWN:-"ctrl-j,down"}"
  KEYS_UP="${KEYS_UP:-"ctrl-k,up"}"
  KEYS_HALFPAGE_DOWN="${KEYS_HALFPAGE_DOWN:-"ctrl-d"}"
  KEYS_HALFPAGE_UP="${KEYS_HALFPAGE_UP:-"ctrl-u"}"
  KEYS_N_DOWN="${KEYS_N_DOWN:-"j"}"
  KEYS_N_UP="${KEYS_N_UP:-"k"}"
  KEYS_N_BOT="${KEYS_N_BOT:-"G"}"
  KEYS_N_TOP="${KEYS_N_TOP:-"1,g"}"
  export KEYS_DOWN KEYS_UP KEYS_HALFPAGE_DOWN KEYS_HALFPAGE_UP KEYS_N_DOWN \
    KEYS_N_UP KEYS_N_BOT KEYS_N_TOP

  # Horizontal navigation:
  KEYS_IN="${KEYS_IN:-"ctrl-l"}"
  KEYS_OUT="${KEYS_OUT:-"ctrl-h"}"
  KEYS_N_IN="${KEYS_N_IN:-"l"}"
  KEYS_N_OUT="${KEYS_N_OUT:-"h"}"
  KEYS_SELECT_ARTIST="${KEYS_SELECT_ARTIST:-"ctrl-a"}"
  KEYS_LIST_ARTISTS="${KEYS_LIST_ARTISTS:-"alt-a"}"
  KEYS_LIST_ALBUMS="${KEYS_LIST_ALBUMS:-"alt-s"}"
  KEYS_SEARCH_ARTIST="${KEYS_SEARCH_ARTIST:-"alt-z"}"
  KEYS_SEARCH_ALBUM="${KEYS_SEARCH_ALBUM:-"alt-x"}"
  KEYS_SWITCH_ARTIST_ALBUM="${KEYS_SWITCH_ARTIST_ALBUM:-"tab"}"
  KEYS_SWITCH_LOCAL_REMOTE="${KEYS_SWITCH_LOCAL_REMOTE:-"ctrl-/"}"
  export KEYS_IN KEYS_OUT KEYS_N_IN KEYS_N_OUT KEYS_SELECT_ARTIST \
    KEYS_LIST_ARTISTS KEYS_LIST_ALBUMS KEYS_SEARCH_ARTIST KEYS_SEARCH_ALBUM \
    KEYS_SWITCH_ARTIST_ALBUM KEYS_SWITCH_LOCAL_REMOTE

  # Filtering:
  KEYS_FILTER_LOCAL="${KEYS_FILTER_LOCAL:-"alt-l"}"
  KEYS_FILTER_1="${KEYS_FILTER_1:-"alt-1"}"
  KEYS_FILTER_2="${KEYS_FILTER_2:-"alt-2"}"
  KEYS_FILTER_3="${KEYS_FILTER_3:-"alt-3"}"
  KEYS_FILTER_4="${KEYS_FILTER_4:-"alt-4"}"
  KEYS_FILTER_5="${KEYS_FILTER_5:-"alt-5"}"
  KEYS_FILTER_6="${KEYS_FILTER_6:-"alt-6"}"
  KEYS_FILTER_7="${KEYS_FILTER_7:-"alt-7"}"
  KEYS_FILTER_8="${KEYS_FILTER_8:-"alt-8"}"
  KEYS_FILTER_9="${KEYS_FILTER_9:-"alt-9"}"
  KEYS_FILTER_0="${KEYS_FILTER_0:-"alt-0"}"
  KEYS_FILTER="$KEYS_FILTER_LOCAL,$KEYS_FILTER_1,$KEYS_FILTER_2,$KEYS_FILTER_3,$KEYS_FILTER_4,$KEYS_FILTER_5,$KEYS_FILTER_6,$KEYS_FILTER_7,$KEYS_FILTER_8,$KEYS_FILTER_9,$KEYS_FILTER_0"
  export KEYS_FILTER_LOCAL KEYS_FILTER_1 KEYS_FILTER_2 KEYS_FILTER_3 \
    KEYS_FILTER_4 KEYS_FILTER_5 KEYS_FILTER_6 KEYS_FILTER_7 KEYS_FILTER_8 \
    KEYS_FILTER_9 KEYS_FILTER_0 KEYS_FILTER

  # Specials:
  KEYS_BROWSE="${KEYS_BROWSE:-"alt-b"}"
  KEYS_OPEN="${KEYS_OPEN:-"alt-o"}"
  KEYS_N_YANK="${KEYS_N_YANK:-"y"}"
  KEYS_YANK_CURRENT="${KEYS_YANK_CURRENT:-"ctrl-y"}"
  KEYS_SHOW_PLAYLIST="${KEYS_SHOW_PLAYLIST:-"ctrl-p"}"
  KEYS_KEYBINDINGS="${KEYS_KEYBINDINGS:-"alt-?"}"
  KEYS_QUIT="${KEYS_QUIT:-"ctrl-c"}"
  KEYS_N_QUIT="${KEYS_N_QUIT:-"q"}"
  KEYS_SCROLL_PREVIEW_DOWN="${KEYS_SCROLL_PREVIEW_DOWN:-"page-down"}"
  KEYS_SCROLL_PREVIEW_UP="${KEYS_SCROLL_PREVIEW_UP:-"page-up"}"
  KEYS_PREVIEW_OPEN="${KEYS_PREVIEW_OPEN:-"alt-up"}"
  KEYS_PREVIEW_CLOSE="${KEYS_PREVIEW_CLOSE:-"alt-down"}"
  KEYS_PREVIEW_TOGGLE_WRAP="${KEYS_PREVIEW_TOGGLE_WRAP:-"alt-w"}"
  KEYS_PREVIEW_TOGGLE_SIZE="${KEYS_PREVIEW_TOGGLE_SIZE:-"alt-/"}"
  KEYS_REFRESH="${KEYS_REFRESH:-"ctrl-r"}"
  export KEYS_BROWSE KEYS_OPEN KEYS_N_YANK KEYS_YANK_CURRENT \
    KEYS_SHOW_PLAYLIST KEYS_KEYBINDINGS KEYS_QUIT KEYS_N_QUIT \
    KEYS_SCROLL_PREVIEW_DOWN KEYS_SCROLL_PREVIEW_UP KEYS_PREVIEW_CLOSE \
    KEYS_PREVIEW_OPEN KEYS_PREVIEW_TOGGLE_WRAP KEYS_PREVIEW_TOGGLE_SIZE \
    KEYS_REFRESH

  # Playback:
  KEYS_PLAY="${KEYS_PLAY:-"enter"}"
  KEYS_QUEUE="${KEYS_QUEUE:-"ctrl-alt-m"}" # That's actually alt-enter
  KEYS_QUEUE_NEXT="${KEYS_QUEUE_NEXT:-"ctrl-alt-n"}"
  KEYS_TOGGLE_PLAYBACK="${KEYS_TOGGLE_PLAYBACK:-"ctrl-space"}"
  KEYS_PLAY_NEXT="${KEYS_PLAY_NEXT:-"alt-n"}"
  KEYS_PLAY_PREV="${KEYS_PLAY_PREV:-"alt-p"}"
  KEYS_SEEK_FORWARD="${KEYS_SEEK_FORWARD:-"alt-N"}"
  KEYS_SEEK_BACKWARD="${KEYS_SEEK_BACKWARD:-"alt-P"}"
  KEYS_PLAYBACK="$KEYS_PLAY,$KEYS_QUEUE,$KEYS_QUEUE_NEXT,$KEYS_TOGGLE_PLAYBACK,$KEYS_PLAY_NEXT,$KEYS_PLAY_PREV,$KEYS_SEEK_FORWARD,$KEYS_SEEK_BACKWARD"
  KEYS_N_PLAY="${KEYS_N_PLAY:-"."}"
  KEYS_N_QUEUE="${KEYS_N_QUEUE:-";"}"
  KEYS_N_QUEUE_NEXT="${KEYS_N_QUEUE_NEXT:-":"}"
  KEYS_N_TOGGLE_PLAYBACK="${KEYS_N_TOGGLE_PLAYBACK:-"space"}"
  KEYS_N_PLAY_NEXT="${KEYS_N_PLAY_NEXT:-"right,n"}"
  KEYS_N_PLAY_PREV="${KEYS_N_PLAY_PREV:-"left,p"}"
  KEYS_N_SEEK_FORWARD="${KEYS_N_SEEK_FORWARD:-"N,f"}"
  KEYS_N_SEEK_BACKWARD="${KEYS_N_SEEK_BACKWARD:-"P,b"}"
  KEYS_N_PLAYBACK="$KEYS_N_PLAY,$KEYS_N_QUEUE,$KEYS_N_QUEUE_NEXT,$KEYS_N_TOGGLE_PLAYBACK,$KEYS_N_PLAY_NEXT,$KEYS_N_PLAY_PREV,$KEYS_N_SEEK_FORWARD,$KEYS_N_SEEK_BACKWARD"
  export KEYS_PLAY KEYS_QUEUE KEYS_QUEUE_NEXT KEYS_TOGGLE_PLAYBACK \
    KEYS_PLAY_NEXT KEYS_PLAY_PREV KEYS_SEEK_FORWARD KEYS_SEEK_BACKWARD \
    KEYS_PLAYBACK KEYS_N_PLAY KEYS_N_QUEUE KEYS_N_QUEUE_NEXT \
    KEYS_N_TOGGLE_PLAYBACK KEYS_N_PLAY_NEXT KEYS_N_PLAY_PREV \
    KEYS_N_SEEK_FORWARD KEYS_N_SEEK_BACKWARD KEYS_N_PLAYBACK

  # Playlist (in the playlist, there is no `insert` mode):
  KEYS_PLAYLIST_RELOAD="${KEYS_PLAYLIST_RELOAD:-"r,ctrl-r"}"
  KEYS_PLAYLIST_REMOVE="${KEYS_PLAYLIST_REMOVE:-"x,delete"}"
  KEYS_PLAYLIST_UP="${KEYS_PLAYLIST_UP:-"u"}"
  KEYS_PLAYLIST_DOWN="${KEYS_PLAYLIST_DOWN:-"d"}"
  KEYS_PLAYLIST_CLEAR="${KEYS_PLAYLIST_CLEAR:-"C"}"
  KEYS_PLAYLIST_CLEAR_ABOVE="${KEYS_PLAYLIST_CLEAR_ABOVE:-"U"}"
  KEYS_PLAYLIST_CLEAR_BELOW="${KEYS_PLAYLIST_CLEAR_BELOW:-"D"}"
  KEYS_PLAYLIST_SHUFFLE="${KEYS_PLAYLIST_SHUFFLE:-"s"}"
  KEYS_PLAYLIST_UNSHUFFLE="${KEYS_PLAYLIST_UNSHUFFLE:-"S"}"
  KEYS_PLAYLIST_GOTO_RELEASE="${KEYS_PLAYLIST_GOTO_RELEASE:-"ctrl-g"}"
  KEYS_PLAYLIST_STORE="${KEYS_PLAYLIST_STORE:-"ctrl-s"}"
  KEYS_PLAYLIST_OPEN_STORE="${KEYS_PLAYLIST_LOAD:-"ctrl-o"}"
  KEYS_PLAYLIST_DELETE="${KEYS_PLAYLIST_DELETE:-"del"}"
  export KEYS_PLAYLIST_RELOAD KEYS_PLAYLIST_REMOVE KEYS_PLAYLIST_UP \
    KEYS_PLAYLIST_DOWN KEYS_PLAYLIST_CLEAR KEYS_PLAYLIST_CLEAR_ABOVE \
    KEYS_PLAYLIST_CLEAR_BELOW KEYS_PLAYLIST_SHUFFLE KEYS_PLAYLIST_UNSHUFFLE \
    KEYS_PLAYLIST_GOTO_RELEASE KEYS_PLAYLIST_STORE KEYS_PLAYLIST_OPEN_STORE

  # Playlist store (here, we don't have a `normal` mode):
  KEYS_PLAYLISTSTORE_SELECT="${KEYS_PLAYLISTSTORE_SELECT:-"enter"}"
  KEYS_PLAYLISTSTORE_DELETE="${KEYS_PLAYLISTSTORE_DELETE:-"del"}"
  export KEYS_PLAYLISTSTORE_SELECT KEYS_PLAYLISTSTORE_DELETE

  export KEYS_LOADED=1
fi

# Local method to print keybindin groups
#
# @argument $1: Group name
# @argument $2: Keys for first item
# @argument $3: Description of first item
# @argument $4: Keys for second item (optional)
# @argument $5: Description of second item (optional)
# @argument ...
#
# This is a helper method for printing key-binding groups.
__keybindinggroup_from_args() {
  printf "$KBF_GROUP\n" "$1"
  shift
  {
    while [ "$*" ]; do
      printf "$KBF_KEY:\t$KBF_DESC\n" "$1" "${2:-"no description"}"
      shift
      shift
    done
  } | column -t -s "$(printf '\t')"
  #} | column -t -s "$(printf '\t')" -c "$FZF_PREVIEW_COLUMNS" -W 2
  printf "\n\n"
}

# Print view-dependent keybindings
#
# @argument $1: view
#
# This method pretty-prints the keybindings active at the given view.
print_keybindings() {
  view=$1
  case "$view" in
  "$VIEW_SELECT_ARTIST")
    __keybindinggroup_from_args "Previews" \
      "$KEYS_SCROLL_PREVIEW_DOWN" "Scroll preview down" \
      "$KEYS_SCROLL_PREVIEW_UP" "Scroll preview up" \
      "$KEYS_KEYBINDINGS" "Show these keybindings" \
      "$KEYS_PREVIEW_TOGGLE_WRAP" "Toggle preview wrapping" \
      "$KEYS_PREVIEW_TOGGLE_SIZE" "Toggle preview size" \
      "$KEYS_PREVIEW_OPEN" "Open preview window" \
      "$KEYS_PREVIEW_CLOSE" "Close preview window"
    __keybindinggroup_from_args "Navigation" \
      "$KEYS_DOWN" "Down" \
      "$KEYS_UP" "Up" \
      "$KEYS_HALFPAGE_DOWN" "Down half a page" \
      "$KEYS_HALFPAGE_UP" "Up half a page" \
      "enter,$KEYS_IN" "Go to selected artist" \
      "$KEYS_OUT,$KEYS_QUIT" "Return to previews view"
    __keybindinggroup_from_args "Views" \
      "$KEYS_LIST_ARTISTS" "Display artists in local database" \
      "$KEYS_LIST_ALBUMS" "Display albums in local database" \
      "$KEYS_SEARCH_ARTIST" "Show artist on MusicBrainz" \
      "$KEYS_SEARCH_ALBUM" "Show album on MusicBrainz"
    __keybindinggroup_from_args "Special operations" \
      "$KEYS_SHOW_PLAYLIST" "Show playlist" \
      "$KEYS_BROWSE" "Open artist in browser"
    __keybindinggroup_from_args "Filtering" \
      "$KEYS_FILTER_LOCAL" "Show only entries in local database"
    ;;
  "$VIEW_PLAYLIST")
    __keybindinggroup_from_args "Previews" \
      "$KEYS_SCROLL_PREVIEW_DOWN" "Scroll preview down" \
      "$KEYS_SCROLL_PREVIEW_UP" "Scroll preview up" \
      "$KEYS_KEYBINDINGS" "Show these keybindings" \
      "$KEYS_PREVIEW_CLOSE" "Close preview window"
    __keybindinggroup_from_args "Navigation" \
      "$KEYS_DOWN,$KEYS_N_DOWN" "Down" \
      "$KEYS_UP,$KEYS_N_UP" "Up" \
      "$KEYS_HALFPAGE_DOWN" "Down half a page" \
      "$KEYS_HALFPAGE_UP" "Up half a page" \
      "$KEYS_N_TOP" "Go to first entry" \
      "$KEYS_N_BOT" "Go to last entry" \
      "$KEYS_OUT,$KEYS_N_OUT,$KEYS_QUIT,$KEYS_N_QUIT" "Leave playlist view" \
      "$KEYS_SELECT_ARTIST" "Go to artist of selected item" \
      "$KEYS_PLAYLIST_GOTO_RELEASE" "Show release of selected track"
    __keybindinggroup_from_args "Views" \
      "$KEYS_LIST_ARTISTS" "Display artists in local database" \
      "$KEYS_LIST_ALBUMS" "Display albums in local database" \
      "$KEYS_SEARCH_ARTIST" "Show artist on MusicBrainz" \
      "$KEYS_SEARCH_ALBUM" "Show album on MusicBrainz"
    __keybindinggroup_from_args "Playlist" \
      "$KEYS_PLAYLIST_RELOAD" "Reload playlist" \
      "$KEYS_PLAYLIST_REMOVE" "Remove selected track" \
      "$KEYS_PLAYLIST_UP" "Move track up" \
      "$KEYS_PLAYLIST_DOWN" "Move track down" \
      "$KEYS_PLAYLIST_CLEAR" "Clear playlist" \
      "$KEYS_PLAYLIST_CLEAR_ABOVE" "Remove all tracks above" \
      "$KEYS_PLAYLIST_CLEAR_BELOW" "Remove all tracks below" \
      "$KEYS_PLAYLIST_SHUFFLE" "Shuffle" \
      "$KEYS_PLAYLIST_UNSHUFFLE" "Undo shuffle" \
      "$KEYS_PLAYLIST_OPEN_STORE" "Manage stored playlists"
    __keybindinggroup_from_args "Playback" \
      "$KEYS_PLAY,$KEYS_N_PLAY" "Play selected item" \
      "$KEYS_QUEUE,$KEYS_N_QUEUE" "Queue selected item" \
      "$KEYS_QUEUE_NEXT,$KEYS_N_QUEUE_NEXT" "Play selected item next" \
      "$KEYS_TOGGLE_PLAYBACK,$KEYS_N_TOGGLE_PLAYBACK" "Toggle playback" \
      "$KEYS_PLAY_NEXT,$KEYS_N_PLAY_NEXT" "Play next track" \
      "$KEYS_PLAY_PREV,$KEYS_N_PLAY_PREV" "Play previous track" \
      "$KEYS_SEEK_FORWARD,$KEYS_N_SEEK_FORWARD" "Seek forward" \
      "$KEYS_SEEK_BACKWARD,$KEYS_N_SEEK_BACKWARD" "Seek backward"
    __keybindinggroup_from_args "Special operations" \
      "$KEYS_BROWSE" "Open selected item in browser" \
      "$KEYS_OPEN" "Open selected item in file manager" \
      "$KEYS_N_YANK" "Copy MusicBrainz track ID" \
      "$KEYS_YANK_CURRENT" "Copy MusicBrainz release ID"
    ;;
  "$VIEW_PLAYLIST_PLAYLISTSTORE")
    __keybindinggroup_from_args "Previews" \
      "$KEYS_SCROLL_PREVIEW_DOWN" "Scroll preview down" \
      "$KEYS_SCROLL_PREVIEW_UP" "Scroll preview up" \
      "$KEYS_KEYBINDINGS" "Show these keybindings" \
      "$KEYS_PREVIEW_TOGGLE_WRAP" "Toggle preview wrapping" \
      "$KEYS_PREVIEW_TOGGLE_SIZE" "Toggle preview size" \
      "$KEYS_PREVIEW_OPEN" "Open preview window" \
      "$KEYS_PREVIEW_CLOSE" "Close preview window"
    __keybindinggroup_from_args "Navigation" \
      "$KEYS_DOWN" "Down" \
      "$KEYS_UP" "Up" \
      "$KEYS_HALFPAGE_DOWN" "Down half a page" \
      "$KEYS_HALFPAGE_UP" "Up half a page" \
      "$KEYS_OUT,$KEYS_QUIT" "Leave playlist store"
    __keybindinggroup_from_args "Playlist store" \
      "$KEYS_PLAYLISTSTORE_SELECT" "Load playlist" \
      "$KEYS_PLAYLISTSTORE_DELETE" "Delete playlist"
    ;;
  *)
    __keybindinggroup_from_args "Switch between modes" \
      "$KEYS_I_NORMAL" "Swtich to normal mode (insert)" \
      "$KEYS_N_INSERT" "Swtich to insert mode (normal)"
    __keybindinggroup_from_args "Previews" \
      "$KEYS_SCROLL_PREVIEW_DOWN" "Scroll preview down" \
      "$KEYS_SCROLL_PREVIEW_UP" "Scroll preview up" \
      "$KEYS_KEYBINDINGS" "Show these keybindings" \
      "$KEYS_PREVIEW_TOGGLE_WRAP" "Toggle preview wrapping" \
      "$KEYS_PREVIEW_TOGGLE_SIZE" "Toggle preview size" \
      "$KEYS_PREVIEW_OPEN" "Open preview window" \
      "$KEYS_PREVIEW_CLOSE" "Close preview window"
    __keybindinggroup_from_args "Navigation" \
      "$KEYS_DOWN" "Down" \
      "$KEYS_UP" "Up" \
      "$KEYS_N_DOWN" "Down (normal)" \
      "$KEYS_N_UP" "Up (normal)" \
      "$KEYS_HALFPAGE_DOWN" "Down half a page" \
      "$KEYS_HALFPAGE_UP" "Up half a page" \
      "$KEYS_N_TOP" "Go to first entry (normal)" \
      "$KEYS_N_BOT" "Go to last entry (normal)" \
      "$KEYS_IN" "Open selected item" \
      "$KEYS_N_IN" "Open selected item (normal)" \
      "$KEYS_OUT" "Leave current item" \
      "$KEYS_N_OUT" "Leave current item (normal)" \
      "$KEYS_SELECT_ARTIST" "Go to artist of selected item"
    __keybindinggroup_from_args "Views" \
      "$KEYS_LIST_ARTISTS" "Display artists in local database" \
      "$KEYS_LIST_ALBUMS" "Display albums in local database" \
      "$KEYS_SEARCH_ARTIST" "Show artist on MusicBrainz" \
      "$KEYS_SEARCH_ALBUM" "Show album on MusicBrainz" \
      "$KEYS_SWITCH_ARTIST_ALBUM" "Swtich artist / album" \
      "$KEYS_SWITCH_LOCAL_REMOTE" "Swtich local database / MusicBrainz"
    __keybindinggroup_from_args "Filtering" \
      "$KEYS_FILTER_LOCAL" "Show only entries in local database" \
      "$KEYS_FILTER_0" "Clear filter" \
      "$KEYS_FILTER_1" "Reset filter to default for current view" \
      "$KEYS_FILTER_2" "Custom filter" \
      "$KEYS_FILTER_3" "Custom filter" \
      "$KEYS_FILTER_4" "Custom filter" \
      "$KEYS_FILTER_5" "Custom filter" \
      "$KEYS_FILTER_6" "Custom filter" \
      "$KEYS_FILTER_7" "Custom filter" \
      "$KEYS_FILTER_8" "Custom filter" \
      "$KEYS_FILTER_9" "Custom filter"
    __keybindinggroup_from_args "Playback" \
      "$KEYS_PLAY" "Play selected item" \
      "$KEYS_QUEUE" "Queue selected item" \
      "$KEYS_QUEUE_NEXT" "Play selected item next" \
      "$KEYS_TOGGLE_PLAYBACK" "Toggle playback" \
      "$KEYS_PLAY_NEXT" "Play next track" \
      "$KEYS_PLAY_PREV" "Play previous track" \
      "$KEYS_SEEK_FORWARD" "Seek forward" \
      "$KEYS_SEEK_BACKWARD" "Seek backward"
    __keybindinggroup_from_args "Playback (normal)" \
      "$KEYS_N_PLAY" "Play selected item" \
      "$KEYS_N_QUEUE" "Queue selected item" \
      "$KEYS_N_QUEUE_NEXT" "Play selected item next" \
      "$KEYS_N_TOGGLE_PLAYBACK" "Toggle playback" \
      "$KEYS_N_PLAY_NEXT" "Play next track" \
      "$KEYS_N_PLAY_PREV" "Play previous track" \
      "$KEYS_N_SEEK_FORWARD" "Seek forward" \
      "$KEYS_N_SEEK_BACKWARD" "Seek backward"
    __keybindinggroup_from_args "Special operations" \
      "$KEYS_SHOW_PLAYLIST" "Show playlist" \
      "$KEYS_BROWSE" "Open selected item in browser" \
      "$KEYS_OPEN" "Open selected item in file manager" \
      "$KEYS_N_YANK" "Copy selected MusicBrainz ID (normal)" \
      "$KEYS_YANK_CURRENT" "Copy current MusicBrainz ID" \
      "$KEYS_REFRESH" "Refresh current entry" \
      "$KEYS_QUIT" "Quit applicaion" \
      "$KEYS_N_QUIT" "First view or quit (normal)"
    ;;
  esac
}
