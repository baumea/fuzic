# Print the fzf instructions that sets the header
#
# @argument $1: view
# @argument $2: mbid
fzf_command_set_header() {
  view=$1
  mbid=$2
  case "$view" in
  "$VIEW_SEARCH_ARTIST") header="Search artist on MusicBrainz" ;;
  "$VIEW_SEARCH_ALBUM") header="Search album on MusicBrainz" ;;
  "$VIEW_LIST_ARTISTS") header="Search locally available artist" ;;
  "$VIEW_LIST_ALBUMS") header="Search locally available album" ;;
  "$VIEW_ARTIST")
    header="$(
      mb_artist "$mbid" |
        $JQ '[.id, type, .name, .disambiguation] | join("\t")' |
        awk_artist_header
    )"
    if [ ! "$header" ]; then
      header="Possibly $mbid is not a MusicBrainz Artist ID"
      err "$header"
    fi
    ;;
  "$VIEW_RELEASEGROUP")
    header="$(
      mb_releasegroup "$mbid" |
        $JQ '[
        .id,
        ."primary-type",
        (."secondary-types" // []|join(";")),
        ."first-release-date",
        .title,
        (."artist-credit" | map(([.name, .joinphrase]|join(""))) | join(""))
        ] | join("\t")' |
        awk_releasegroup_header
    )"
    if [ ! "$header" ]; then
      header="Possibly $mbid is not a MusicBrainz Release-Group ID"
      err "$header"
    fi
    ;;
  "$VIEW_RELEASE")
    header="$(
      mb_release "$mbid" |
        $JQ '[
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
        awk_release_header
    )"
    if [ ! "$header" ]; then
      header="Possibly $mbid is not a MusicBrainz Release ID"
      err "$header"
    fi
    ;;
  *)
    header="We entered an unknown state"
    err "$header"
    ;;
  esac
  printf "+change-header(%s)" "$header"
}
