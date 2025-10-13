# These methods generate lists that are used as input to FZF.

# List release groups of given artist
#
# argument $1: MusicBrainz artist ID
list_releasegroups() {
  name=$(mb_artist "$1" | $JQ '.name')
  mb_artist_releasegroups "$1" |
    $JQ '."release-groups"[] | [
  .id,
  ."primary-type",
  (."secondary-types" // []|join(";")),
  ."first-release-date",
  .title,
  (."artist-credit" | map(([.name, .joinphrase]|join(""))) | join(""))
  ] | join("\t")' |
    awk_releasegroups "$SORT_RG_DEFAULT" "$1" "$name"
}

# List releases in given relese group
#
# argument $1: MusicBrainz release-group ID
list_releases() {
  title="$(mb_releasegroup "$1" |
    $JQ '.title')"
  artist="$(mb_releasegroup "$1" |
    $JQ '."artist-credit" | map(([.name, .joinphrase]|join(""))) | join("")')"
  mb_releasegroup_releases "$1" |
    $JQ '."releases"[] | [
  .id,
  .status,
  .date,
  ."cover-art-archive".count,
  (."label-info" | map(.label.name) | unique | join(", ")),
  (.media | map(."track-count") | add),
  (.media | map(.format) | unique | join(", ")),
  .country,
  .title,
  (."artist-credit" | map(([.name, .joinphrase]|join(""))) | join(""))
  ] | join("\t")' |
    awk_releases "$1" "$title" "$artist"
}

# List recordings of given release
#
# argument $1: MusicBrainz release ID
list_recordings() {
  deco="$(grep "$1" "$LOCALDATA_RELEASES" | cut -d "$(printf '\t')" -f 2)"
  if [ "$deco" ]; then
    rectmp=$(mktemp)
    $JQ '.tracks | keys | join("\n")' "$deco" >"$rectmp"
  fi
  mb_release "$1" |
    $JQ \
      --arg rid "$1" \
      --arg deco "$deco" \
      '.media |
        length as $l |
        .[] |
        .position as $pos |
        .tracks[] | [
          $rid,
          .id,
          $l,
          $pos,
          .number,
          .length,
          .recording.title,
          (.recording."artist-credit" | map([.name, .joinphrase] | join("")) | join("")),
          $deco
        ] |
        join("\t")' |
    awk_recordings "${rectmp:-}"
  if [ "${rectmp:-}" ] && [ -f "$rectmp" ]; then
    rm -f "$rectmp"
  fi
}

# List artists available locally
list_local_artists() {
  cat "$LOCALDATA_ARTISTS_VIEW" 2>/dev/null
}

# List release groups vailable locally
list_local_releasegroups() {
  cat "$LOCALDATA_RELEASEGROUPS_VIEW" 2>/dev/null
}

# List artist from input json data
#
# The input is read from stdin
list_artists_from_json() {
  cat |
    $JQ 'map([.artist.id, .artist.type, .name] | join("\t")) | join("\n")' |
    awk_artists "$SORT_NO"
}

# Print playlist currently loaded
list_playlist() {
  count=$(mpv_playlist_count)
  [ "$count" ] || return 0
  [ "$count" -eq 0 ] && return 0
  mpvquery=""
  for i in $(seq 0 $((count - 1))); do
    mpvquery="$mpvquery\${playlist/$i/title}\t\${playlist/$i/current}\n"
  done
  __mpv_get "$mpvquery" | grep '.' | awk_playlist
}

# List stored playlist
#
# @argument $1: paylist name
list_playlist_stored() {
  t=$(mktemp)
  r=$(mktemp)
  generate_playlist_stored "$PLAYLIST_DIRECTORY/$1" |
    grep "$(printf '\t')" |
    cut -d "," -f 2- >"$t"
  grep -v "/dev/null$" "$t" | cut -d "$(printf '\t')" -f 2 >"$r"
  awk_recordings "$r" <"$t"
  rm -f "$t" "$r"
}
