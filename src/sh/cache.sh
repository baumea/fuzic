# This implements the caching functionalities. The cache is stored under
# `CACHEDIR` defined below, and organized as follows (all paths relative to
# `CAHCEDIR`) ./<type>/radix(mbid)/<file>. Here, type is one of `TYPE_ARTIST`,
# `TYPE_RELEASEGROUP`, or `TYPE_RELEASE`. The string `radix(mbid)` is the radix
# encoded MusicBrainz ID of given type (see method below). Finally <file> is a
# filename to hold the respective data in the json format. Currently, the data
# is stored as follows:
# ./artist/radix(mbid)/musicbrainz.json         MusicBrainz artist data
# ./artist/radix(mbid)/discogs.json             Discogs artist data
# ./artist/radix(mbid)/wikidata.json            Wikidata artist data
# ./artist/radix(mbid)/enwikipedia.json         Wikipedia artist data
# ./artist/radix(mbid)/releasegroups.json       Release groups of artist
# ./releasegroup/radix(mbid)/musicbrainz.json   MusicBrainz release-group data
# ./releasegroup/radix(mbid)/releases.json      Releases in release group
# ./release/radix(mbid)/musicbrainz.json        MusicBrainz release data

if [ ! "${CACHE_LOADED:-}" ]; then
  # Base path for cache
  CACHEDIR="${XGD_CACHE_HOME:-"$HOME/.cache"}/$APP_NAME"
  # Directory names for cache types
  TYPE_ARTIST="artist"
  TYPE_RELEASEGROUP="releasegroup"
  TYPE_RELEASE="release"
  # Filenames for cache entries
  ARTIST_FILENAME="musicbrainz.json"
  ARTIST_RELEASEROUPS_FILENAME="releasegroups.json"
  ARTIST_DISCOGS_FILENAME="discogs.json"
  ARTIST_WIKIDATA_FILENAME="wikidata.json"
  ARTIST_ENWIKIPEDIA_FILENAME="enwikipedia.json"
  RELEASEGROUP_FILENAME="musicbrainz.json"
  RELEASEGROUP_RELEASES_FILENAME="releases.json"
  RELEASE_FILENAME="musicbrainz.json"
  export CACHEDIR TYPE_ARTIST TYPE_RELEASEGROUP TYPE_RELEASE ARTIST_FILENAME \
    ARTIST_RELEASEROUPS_FILENAME ARTIST_DISCOGS_FILENAME \
    ARTIST_WIKIDATA_FILENAME ARTIST_ENWIKIPEDIA_FILENAME \
    RELEASEGROUP_FILENAME RELEASEGROUP_RELEASES_FILENAME RELEASE_FILENAME

  export CACHE_LOADED=1
fi

# Radix transform string
#
# @argument $1: some string
__radix() {
  echo "$1" | awk -F "" '{ print $1$2"/"$3$4"/"$0 }'
}

# Radix transform strings (batch)
#
# Here, the input is read line-by-line from stdin.
__radix_batch() {
  cat | awk -F "" '{ print $1$2"/"$3$4"/"$0 }'
}

# Super wrapper to print json data from cache
#
# argument $1: type
# argument $2: MusicBrainz ID
# argument $3: Filename of json file
__get_json() {
  f="$CACHEDIR/$1/$(__radix "$2")/$3"
  [ -f "$f" ] || return
  cat "$f"
}

# Super wrapper to store json data in cache
#
# argument $1: type
# argument $2: MusicBrainz ID
# argument $3: Filename of json file
__put_json() {
  dir="$CACHEDIR/$1/$(__radix "$2")"
  [ -d "$dir" ] || mkdir -p "$dir"
  f="$dir/$3"
  tmpf=$(mktemp)
  cat >"$tmpf"
  [ -s "$tmpf" ] && mv "$tmpf" "$f" || printf "{}" >"$f"
}

# Print MusicBrainz data of given artist from cache
#
# @argument $1: MusicBrainz artist ID
cache_get_artist() {
  __get_json "$TYPE_ARTIST" "$1" "$ARTIST_FILENAME"
}

# Print release groups (MusicBrainz) of given artist from cache
#
# @argument $1: MusicBrainz artist ID
cache_get_artist_releasegroups() {
  __get_json "$TYPE_ARTIST" "$1" "$ARTIST_RELEASEROUPS_FILENAME"
}

# Print Discogs data of given artist from cache
#
# @argument $1: MusicBrainz artist ID
cache_get_artist_discogs() {
  __get_json "$TYPE_ARTIST" "$1" "$ARTIST_DISCOGS_FILENAME"
}

# Print Wikipedia data of given artist from cache
#
# @argument $1: MusicBrainz artist ID
cache_get_artist_enwikipedia() {
  __get_json "$TYPE_ARTIST" "$1" "$ARTIST_ENWIKIPEDIA_FILENAME"
}

# Print Wikidata data of given artist from cache
#
# @argument $1: MusicBrainz artist ID
cache_get_artist_wikidata() {
  __get_json "$TYPE_ARTIST" "$1" "$ARTIST_WIKIDATA_FILENAME"
}

# Store MusicBrainz data of given artist in cache
#
# @argument $1: MusicBrainz artist ID
#
# This methods reads the data to be stored from stdin.
cache_put_artist() {
  cat | __put_json "$TYPE_ARTIST" "$1" "$ARTIST_FILENAME"
}

# Store release groups (MusicBrainz) of given artist in cache
#
# @argument $1: MusicBrainz artist ID
#
# This methods reads the data to be stored from stdin.
cache_put_artist_releasegroups() {
  cat | __put_json "$TYPE_ARTIST" "$1" "$ARTIST_RELEASEROUPS_FILENAME"
}

# Append release groups (MusicBrainz) of given artist to existing file in cache
#
# @argument $1: MusicBrainz artist ID
#
# This methods reads the data to be stored from stdin.
cache_append_artist_releasegroups() {
  tmpf=$(mktemp)
  cat >"$tmpf"
  updated=$(mktemp)
  f="$CACHEDIR/$TYPE_ARTIST/$(__radix "$1")/$ARTIST_RELEASEROUPS_FILENAME"
  $JQ --slurpfile n "$tmpf" '."release-groups" += ($n[0]|."release-groups")' "$f" >"$updated" && mv "$updated" "$f"
  rm -f "$tmpf"
}

# Store Discogs data of given artist to cache
#
# @argument $1: MusicBrainz artist ID
cache_put_artist_discogs() {
  cat | __put_json "$TYPE_ARTIST" "$1" "$ARTIST_DISCOGS_FILENAME"
}

# Store Wikipedia data of given artist to cache
#
# @argument $1: MusicBrainz artist ID
cache_put_artist_enwikipedia() {
  cat | __put_json "$TYPE_ARTIST" "$1" "$ARTIST_ENWIKIPEDIA_FILENAME"
}

# Store Wikidata data of given artist to cache
#
# @argument $1: MusicBrainz artist ID
cache_put_artist_wikidata() {
  cat | __put_json "$TYPE_ARTIST" "$1" "$ARTIST_WIKIDATA_FILENAME"
}

# Print MusicBrainz data of given release group from cache
#
# @argument $1: MusicBrainz release-group ID
cache_get_releasegroup() {
  __get_json "$TYPE_RELEASEGROUP" "$1" "$RELEASEGROUP_FILENAME"
}

# Print releases (MusicBrainz) in release group from cache
#
# @argument $1: MusicBrainz release-group ID
cache_get_releasegroup_releases() {
  __get_json "$TYPE_RELEASEGROUP" "$1" "$RELEASEGROUP_RELEASES_FILENAME"
}

# Store MusicBrainz data of given release group in cache
#
# @argument $1: MusicBrainz release-group ID
cache_put_releasegroup() {
  cat | __put_json "$TYPE_RELEASEGROUP" "$1" "$RELEASEGROUP_FILENAME"
}

# Store releases (MusicBrainz) of given release group in cache
#
# @argument $1: MusicBrainz release-group ID
cache_put_releasegroup_releases() {
  cat | __put_json "$TYPE_RELEASEGROUP" "$1" "$RELEASEGROUP_RELEASES_FILENAME"
}

# Append releases (MusicBrainz) of given release group to existing file in
# cache
#
# @argument $1: MusicBrainz release-group ID
cache_append_releasegroup_releases() {
  tmpf=$(mktemp)
  cat >"$tmpf"
  updated=$(mktemp)
  f="$CACHEDIR/$TYPE_RELEASEGROUP/$(__radix "$1")/$RELEASEGROUP_RELEASES_FILENAME"
  $JQ --slurpfile n "$tmpf" '."releases" += ($n[0]|."releases")' "$f" >"$updated" && mv "$updated" "$f"
  rm -f "$tmpf"
}

# Print MusicBrainz data of given release from cache
#
# @argument $1: MusicBrainz release ID
cache_get_release() {
  __get_json "$TYPE_RELEASE" "$1" "$RELEASE_FILENAME"
}

# Store MusicBrainz data of given release in cache
#
# @argument $1: MusicBrainz release ID
cache_put_release() {
  cat | __put_json "$TYPE_RELEASE" "$1" "$RELEASE_FILENAME"
}

# Print all MusicBrainz cache paths to the files specified by their IDs
#
# @argument $1: type
#
# This method reads from stdin any number of MusicBrainz IDs of objects of the
# specified type, and prints the file paths.
cache_get_file_batch() {
  case "$1" in
  "$TYPE_ARTIST") fn="$ARTIST_FILENAME" ;;
  "$TYPE_RELEASEGROUP") fn="$RELEASEGROUP_FILENAME" ;;
  "$TYPE_RELEASE") fn="$RELEASE_FILENAME" ;;
  *) return 1 ;;
  esac
  cat |
    __radix_batch |
    awk -v dir="$CACHEDIR/$1/" -v f="/$fn" '{ print dir $0 f }'
}

# Detect missing cache files
#
# @argument $1: type
# @argument $2: path to list with MusicBrainz IDs
#
# This method returns a nonzero value if some MusicBrainz objects listed in $2
# are not cached.
cached() {
  cache_get_file_batch "$1" <"$2" |
    xargs -d '\n' ls >/dev/null 2>&1 || return 1
}

# Print MusicBrainz ID associated to the file paths
#
# This reads from stdin any number of paths (one per line)
cache_mbid_from_path_batch() {
  cat | awk -F "/" '{ print $(NF-1) }'
}

# Remove artist items from cache
#
# @argument $1: MusicBrainz arist ID
#
# This function is "safer" than other because it removes data. These safty
# checks are paranoid.
cache_rm_artist() {
  [ "$CACHEDIR" ] || return 1
  [ -d "$CACHEDIR" ] || return 1
  [ -d "$CACHEDIR/$TYPE_ARTIST" ] || return 1
  d="$CACHEDIR/$TYPE_ARTIST/$(__radix "$1")/"
  [ "$d" ] || return 1
  [ -d "$d" ] || return 1
  info "Removing $d from cache"
  rm -rf "$d"
}

# Remove release-group items from cache
#
# @argument $1: MusicBrainz release-group ID
#
# This function is "safer" than other because it removes data. These safty
# checks are paranoid.
cache_rm_releasegroup() {
  [ "$CACHEDIR" ] || return 1
  [ -d "$CACHEDIR" ] || return 1
  [ -d "$CACHEDIR/$TYPE_RELEASEGROUP" ] || return 1
  d="$CACHEDIR/$TYPE_RELEASEGROUP/$(__radix "$1")/"
  [ "$d" ] || return 1
  [ -d "$d" ] || return 1
  info "Removing $d from cache"
  rm -rf "$d"
}

# Remove release items from cache
#
# @argument $1: MusicBrainz release ID
#
# This function is "safer" than other because it removes data. These safty
# checks are paranoid.
cache_rm_release() {
  [ "$CACHEDIR" ] || return 1
  [ -d "$CACHEDIR" ] || return 1
  [ -d "$CACHEDIR/$TYPE_RELEASE" ] || return 1
  d="$CACHEDIR/$TYPE_RELEASE/$(__radix "$1")/"
  [ "$d" ] || return 1
  [ -d "$d" ] || return 1
  info "Removing $d from cache"
  rm -rf "$d"
}

# Load missing cache entries (batch mode)
#
# argument $1: type
#
# This method reads one MusicBrainz IDs of the specified type from stdin (one
# per line), and fetches the missing items.
batch_load_missing() {
  tmpf=$(mktemp)
  cat |
    cache_get_file_batch "$1" |
    xargs -d '\n' \
      sh -c 'for f; do [ -e "$f" ] || echo "$f"; done' _ |
    cache_mbid_from_path_batch >"$tmpf"
  lines=$(wc -l "$tmpf" | cut -d ' ' -f 1)
  if [ "$lines" -gt 0 ]; then
    case "$1" in
    "$TYPE_ARTIST") tt="artists" ;;
    "$TYPE_RELEASEGROUP") tt="release groups" ;;
    "$TYPE_RELEASE") tt="releases" ;;
    esac
    info "Fetching missing $tt"
    cnt=0
    while IFS= read -r mbid; do
      case "$1" in
      "$TYPE_ARTIST")
        name=$(mb_artist "$mbid" | $JQ '.name')
        ;;
      "$TYPE_RELEASEGROUP") name=$(mb_releasegroup "$mbid" | $JQ '.title') ;;
      "$TYPE_RELEASE") name=$(mb_release "$mbid" | $JQ '.title') ;;
      esac
      cnt=$((cnt + 1))
      info "$(printf "%d/%d (%s: %s)" "$cnt" "$lines" "$mbid" "$name")"
      sleep 1
    done <"$tmpf"
  fi
  rm -f "$tmpf"
}
