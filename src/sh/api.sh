# This file provides the methods for access to several APIs
#
# APIs:
# - MusicBrainz
# - Discogs
# - Wikidata
# - Wikipedia
if [ ! "${API_LOADED:-}" ]; then
  MB_MAX_RETRIES=10
  MB_BROWSE_STEPS=100
  USER_AGENT="$APP_NAME/$APP_VERSION ($APP_WEBSITE)"
  SLEEP_ON_ERROR=1
  export MB_MAX_RETRIES MB_BROWSE_STEPS USER_AGENT SLEEP_ON_ERROR

  export API_LOADED=1
fi

# Internal method for MusicBrainz API access
#
# @argument $1: entity (see `case` below)
# @argument $2: MusicBrainz ID
# @argument $3: offset (optional, but mandatory for browse requests)
#
# If the API access fails, then the error message is logged, and at most
# `MB_MAX_RETRIES` retries are made. If browse requests are made, then at most
# `MB_BROWSE_STEPS` number of entries are requested per call. The offset in
# browse request must be specified.
__api_mb() {
  tmpout=$(mktemp)
  for _ in $(seq "$MB_MAX_RETRIES"); do
    case "$1" in
    "artist")
      $CURL \
        --output "$tmpout" \
        --get \
        --data fmt=json \
        --data inc="url-rels+artist-rels+aliases" \
        -A "$USER_AGENT" \
        "https://musicbrainz.org/ws/2/artist/$2"
      ;;
    "releasegroup")
      $CURL \
        --output "$tmpout" \
        --get \
        --data fmt=json \
        --data inc=artist-credits \
        -A "$USER_AGENT" \
        "https://musicbrainz.org/ws/2/release-group/$2"
      ;;
    "release")
      $CURL \
        --output "$tmpout" \
        --get \
        --data fmt=json \
        --data inc="recordings+artist-credits+release-groups+labels" \
        -A "$USER_AGENT" \
        "https://musicbrainz.org/ws/2/release/$2"
      ;;
    "browse-artist-releasegroups")
      $CURL \
        --output "$tmpout" \
        --get \
        --data fmt=json \
        --data inc=artist-credits \
        --data limit="$MB_BROWSE_STEPS" \
        --data offset="$3" \
        --data artist="$2" \
        -A "$USER_AGENT" \
        "https://musicbrainz.org/ws/2/release-group"
      ;;
    "browse-releasegroup-releases")
      $CURL \
        --output "$tmpout" \
        --get \
        --data fmt=json \
        --data inc="artist-credits+labels+media+release-groups" \
        --data limit="$MB_BROWSE_STEPS" \
        --data offset="$3" \
        --data release-group="$2" \
        -A "$USER_AGENT" \
        "https://musicbrainz.org/ws/2/release"
      ;;
    "search-artist")
      $CURL \
        --output "$tmpout" \
        --get \
        --data fmt=json \
        --data-urlencode query="$2" \
        -A "$USER_AGENT" \
        "https://musicbrainz.org/ws/2/artist"
      ;;
    "search-releasegroup")
      $CURL \
        --output "$tmpout" \
        --get \
        --data fmt=json \
        --data inc=artist-credits \
        --data-urlencode query="$2" \
        -A "$USER_AGENT" \
        "https://musicbrainz.org/ws/2/release-group"
      ;;
    esac
    errormsg=$($JQ -e '.error // ""' "$tmpout")
    if [ "$errormsg" ]; then
      err "Failed to fetch MusicBrainz data for $1 $2: $errormsg"
      echo "$errormsg" | grep -q -i "not found" && break
      echo "$errormsg" | grep -q -i "invalid" && break
      sleep "$SLEEP_ON_ERROR"
    else
      cat "$tmpout"
      rm -f "$tmpout"
      return 0
    fi
  done
  rm -f "$tmpout"
  err "Failed to fetch MusicBrainz data for $1 $2 (not retrying anymore...)"
  return 1
}

# The interface to MusicBrainz API.

# Retrieve MusicBrainz artist information
#
# @argument $1: MusicBrainz artist ID
api_mb_artist() {
  __api_mb "artist" "$1"
}

# Retrieve MusicBrainz release-group information
#
# @argument $1: MusicBrainz release-group ID
api_mb_releasegroup() {
  __api_mb "releasegroup" "$1"
}

# Retrieve MusicBrainz release information
#
# @argument $1: MusicBrainz release ID
api_mb_release() {
  __api_mb "release" "$1"
}

# Retrieve MusicBrainz release-groups for given artist
#
# @argument $1: MusicBrainz artist ID
# @argument $2: offset (defaults to 0)
api_mb_browse_artist_releasegroups() {
  __api_mb "browse-artist-releasegroups" "$1" "${2:-0}"
}

# Retrieve MusicBrainz releases in given release group
#
# @argument $1: MusicBrainz release-group ID
# @argument $2: offset (defaults to 0)
api_mb_browse_releasegroup_releases() {
  __api_mb "browse-releasegroup-releases" "$1" "${2:-0}"
}

# Search MusicBrainz database for given artist
#
# @argument $1: query
api_mb_search_artist() {
  __api_mb "search-artist" "$1"
}

# Search MusicBrainz database for given release group
#
# @argument $1: query
api_mb_search_releasegroup() {
  __api_mb "search-releasegroup" "$1"
}

# Retrieve Discogs artist information
#
# @argument $1: Discogs artist ID
api_discogs_artist() {
  $CURL \
    --get \
    -A "$USER_AGENT" \
    "https://api.discogs.com/artists/$1"
}

# Retrieve sitelinks from wikidata
#
# @argument $1: Wikidata ID
api_wikidata_sitelinks() {
  $CURL \
    --get \
    -A "$USER_AGENT" \
    "https://www.wikidata.org/w/rest.php/wikibase/v1/entities/items/$1/sitelinks"
}

# Retrieve summary from Wikipedia page
#
# @argument $1: Wikipedia page name
api_wikipedia_en_summary() {
  $CURL \
    --get \
    -A "$USER_AGENT" \
    "https://en.wikipedia.org/api/rest_v1/page/summary/$1"
}
