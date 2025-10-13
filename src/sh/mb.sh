# This files provides a high-level access to the MusicBrainz databse. The only
# IDs used here are MusicBrainz IDs

# The following methods are local methods that combines the MusicBrainz API
# with the caching methods.

# Retrieve MusicBrainz data for artist from cache (if it exists), and otherwise
# download it using the MusicBrainz API.
#
# @argument $1: MusicBrainz artist ID
__mb_artist_cache_or_fetch() {
  if ! cache_get_artist "$1"; then
    api_mb_artist "$1" | cache_put_artist "$1"
    cache_get_artist "$1"
  fi
}

# Retrieve MusicBrainz data for release group from cache (if it exists), and
# otherwise download it using the MusicBrainz API.
#
# @argument $1: MusicBrainz release-group ID
__mb_releasegroup_cache_or_fetch() {
  if ! cache_get_releasegroup "$1"; then
    api_mb_releasegroup "$1" | cache_put_releasegroup "$1"
    cache_get_releasegroup "$1"
  fi
}

# Retrieve MusicBrainz data for release from cache (if it exists), and
# otherwise download it using the MusicBrainz API.
#
# @argument $1: MusicBrainz release ID
__mb_release_cache_or_fetch() {
  if ! cache_get_release "$1"; then
    api_mb_release "$1" | cache_put_release "$1"
    cache_get_release "$1"
  fi
}

# Retrieve MusicBrainz data for release groups of given artist from cache (if
# it exists), and otherwise download it using the MusicBrainz API.
#
# @argument $1: MusicBrainz artist ID
__mb_artist_cache_or_fetch_releasegroups() {
  if ! cache_get_artist_releasegroups "$1"; then
    api_mb_browse_artist_releasegroups "$1" | cache_put_artist_releasegroups "$1"
    rg="$(cache_get_artist_releasegroups "$1")"
    total=$(printf "%s" "$rg" | $JQ '."release-group-count"')
    seen=$MB_BROWSE_STEPS
    while [ "$total" -gt "$seen" ]; do
      # Fetch remaning release groups, and append to cache
      sleep 1 # Make sure we don't get blocked (we prefer not to handle failed requests...)
      api_mb_browse_artist_releasegroups "$1" "$seen" | cache_append_artist_releasegroups "$1"
      seen=$((seen + MB_BROWSE_STEPS))
    done
    cache_get_artist_releasegroups "$1"
  fi
}

# Retrieve MusicBrainz data for releases of given release group from cache (if
# it exists), and otherwise download it using the MusicBrainz API.
#
# @argument $1: MusicBrainz release-group ID
__mb_releasegroup_cache_or_fetch_releases() {
  if ! cache_get_releasegroup_releases "$1"; then
    api_mb_browse_releasegroup_releases "$1" | cache_put_releasegroup_releases "$1"
    releases="$(cache_get_releasegroup_releases "$1")"
    total=$(printf "%s" "$releases" | $JQ '."release-count"')
    seen=$MB_BROWSE_STEPS
    while [ "$total" -gt "$seen" ]; do
      # Fetch remaning releases, and append to cache
      sleep 1 # Make sure we don't get blocked (we prefer not to handle failed requests...)
      api_mb_browse_releasegroup_releases "$1" "$seen" | cache_append_releasegroup_releases "$1"
      seen=$((seen + MB_BROWSE_STEPS))
    done
    cache_get_releasegroup_releases "$1"
  fi
}

# The following methods provide the external interface

# Retrieve MusicBrainz data for artist
#
# @argument $1: MusicBrainz artist ID
mb_artist() {
  __mb_artist_cache_or_fetch "$1"
}

# Retrieve Wikidata data for artist
#
# @argument $1: MusicBrainz artist ID
mb_artist_wikidata() {
  if ! cache_get_artist_wikidata "$1"; then
    wikidataid=$(mb_artist "$1" |
      $JQ '.relations |
      map(select(.type=="wikidata")) |
      .[0].url.resource // ""' |
      awk -F "/" '{print $NF}')
    [ ! "$wikidataid" ] && return
    api_wikidata_sitelinks "$wikidataid" | cache_put_artist_wikidata "$1"
    cache_get_artist_wikidata "$1"
  fi
}

# Retrieve Wikipedia (English) summary json for artist
#
# @argument $1: MusicBrainz artist ID
mb_artist_enwikipedia() {
  if ! cache_get_artist_enwikipedia "$1"; then
    # To fetch the wikipedia data, we need the wikipedia URL
    # There are two possibly ways to get the wikipedia URL
    # 1. From the website relations in MB (MB artists donw have wiki rels)
    # 2. MB website relations -> Wikidata -> Wikipedia
    # Lately, Wikipedia pages are not stored in the MB artist url relations.
    # For obvious reasons it is recommended to link to wikidata only. So, we
    # take the second route.
    wikidata=$(mb_artist_wikidata "$1" || true)
    wikiid=$(printf "%s" "$wikidata" |
      $JQ '.enwiki.url // ""' |
      awk -F "/" '{print $NF}')
    [ ! "$wikiid" ] && return
    api_wikipedia_en_summary "$wikiid" | cache_put_artist_enwikipedia "$1"
    cache_get_artist_enwikipedia "$1"
  fi
}

# Retrieve  Discogs json for artist
#
# @argument $1: MusicBrainz artist ID
mb_artist_discogs() {
  if ! cache_get_artist_discogs "$1"; then
    discogsid=$(mb_artist "$1" |
      $JQ '.relations |
      map(select(.type=="discogs")) |
      .[0].url.resource // ""' |
      awk -F "/" '{print $NF}')
    [ ! "$discogsid" ] && return
    api_discogs_artist "$discogsid" | cache_put_artist_discogs "$1"
    cache_get_artist_discogs "$1"
  fi
}

# Retrieve release groups for artist
#
# @argument $1: MusicBrainz artist ID
mb_artist_releasegroups() {
  __mb_artist_cache_or_fetch_releasegroups "$1"
}

# Retrieve MusicBrainz release group
#
# @argument $1: MusicBrainz release-group ID
mb_releasegroup() {
  __mb_releasegroup_cache_or_fetch "$1"
}

# Retrieve MusicBrainz releases of release group
#
# @argument $1: MusicBrainz release-group ID
mb_releasegroup_releases() {
  __mb_releasegroup_cache_or_fetch_releases "$1"
}

# Retrieve MusicBrainz release
#
# @argument $1: MusicBrainz release ID
mb_release() {
  __mb_release_cache_or_fetch "$1"
}

# Reload hook that is used after a change in the query (when searching
# MusicBrainz).
#
# This method waits for the search to complete, then it parses the search
# results and prints them.
mb_results_async() {
  # Wait for async. process to terminate
  sleep 1
  while [ -f "$LOCKFILE" ]; do
    sleep 1
  done
  # Show results
  cat "$RESULTS" || true
}

# Initiate search on MusicBrainz
#
# @argument $1: view
#
# This methods initiates an asynchronous search for both views
# (VIEW_SEARCH_ARTIST and VIEW_SEARCH_ALBUM). If a running query is detected,
# that one is killed first. The search results are then stored and become
# retrievable using `mb_results_async`.
mb_search_async() {
  view="$1"
  # Kill any running search
  if [ -f "$PIDFILE" ]; then
    pid=$(cat "$PIDFILE")
    rm -f "$PIDFILE"
    kill -9 "$pid" >/dev/null 2>&1 || true
  fi
  # Clear search and stop if no search string is given
  if [ ! "$FZF_QUERY" ]; then
    rm -f "$RESULTS"
    touch "$RESULTS"
    exit 0
  fi
  # Store PID of current process
  echo "$$" >"$PIDFILE"
  touch "$LOCKFILE"
  sleep 1
  if [ "$view" = "$VIEW_SEARCH_ARTIST" ]; then
    api_mb_search_artist "$FZF_QUERY" |
      $JQ '.artists[] | [
    .id,
    .type,
    .name,
    ."sort-name",
    .disambiguation,
    .["life-span"].begin,
    .["life-span"].end
    ] | join("\t")' |
      awk_artists "$SORT_NO" >"$RESULTS" ||
      true
  else
    api_mb_search_releasegroup "$FZF_QUERY" |
      $JQ '."release-groups"[] | [
    .id,
    ."primary-type",
    (."secondary-types" // []|join(";")),
    ."first-release-date",
    .title,
    (."artist-credit" | map(([.name, .joinphrase]|join(""))) | join(""))
    ] | join("\t")' |
      awk_releasegroups "$SORT_NO" >"$RESULTS" ||
      true
  fi
  # Process ends now: Display and quit
  rm -f "$LOCKFILE" "$PIDFILE"
}
