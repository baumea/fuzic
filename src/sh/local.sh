# Database functionality to support local music.
#
# All local data is stored in the directory `LOCALDATADIR`. In the future, we
# will also use the methods here, and modifications thereof, to support
# MusicBainz collections.
if [ ! "${LOCAL_LOADED:-}" ]; then
  LOCALDATADIR="${XDG_DATA_HOME:-"$HOME/.local/share"}/$APP_NAME"
  LOCALDATA_ARTISTS="$LOCALDATADIR/artists"
  LOCALDATA_RELEASEGROUPS="$LOCALDATADIR/releasegroups"
  LOCALDATA_RELEASES="$LOCALDATADIR/releases"
  LOCALDATA_ARTISTS_VIEW="$LOCALDATADIR/artists_view"
  LOCALDATA_RELEASEGROUPS_VIEW="$LOCALDATADIR/releasegroups_view"
  LOCALDATA_RELEASES_VIEW="$LOCALDATADIR/releases_view"
  LOCALDATA_ARTISTS_LIST="$LOCALDATADIR/artists_list"
  LOCALDATA_RELEASEGROUPS_LIST="$LOCALDATADIR/releasegroups_list"
  LOCALDATA_RELEASES_LIST="$LOCALDATADIR/releases_list"
  DECORATION_FILENAME=${DECORATION_FILENAME:-"mbid.json"}

  # Create necessary files
  [ -d "$LOCALDATADIR" ] || mkdir -p "$LOCALDATADIR"
  [ -f "$LOCALDATA_ARTISTS" ] || touch "$LOCALDATA_ARTISTS"
  [ -f "$LOCALDATA_RELEASEGROUPS" ] || touch "$LOCALDATA_RELEASEGROUPS"
  [ -f "$LOCALDATA_RELEASES" ] || touch "$LOCALDATA_RELEASES"
  [ -f "$LOCALDATA_ARTISTS_LIST" ] || touch "$LOCALDATA_ARTISTS_LIST"
  [ -f "$LOCALDATA_RELEASEGROUPS_LIST" ] || touch "$LOCALDATA_RELEASEGROUPS_LIST"
  [ -f "$LOCALDATA_RELEASES_LIST" ] || touch "$LOCALDATA_RELEASES_LIST"

  export LOCALDATADIR LOCALDATA_ARTISTS LOCALDATA_RELEASEGROUPS \
    LOCALDATA_RELEASES LOCALDATA_ARTISTS_VIEW LOCALDATA_RELEASEGROUPS_VIEW \
    LOCALDATA_RELEASES_VIEW LOCALDATA_ARTISTS_LIST LOCALDATA_RELEASEGROUPS_LIST \
    LOCALDATA_RELEASES_LIST DECORATION_FILENAME

  export LOCAL_LOADED=1
fi

# Retrieve tags as json object from music file
#
# @argument $1: path to music file
#
# The tags retrieved are the MusicBrainz release ID and the MusicBrainz track
# ID
__gettags() {
  $FFPROBE -v error -show_entries format_tags -print_format json "$1" |
    $JQ '.format.tags | {
      trackid: (."MusicBrainz Release Track Id" // ."MUSICBRAINZ_RELEASETRACKID" // ."MusicBrainz/Release Track Id" // ""),
      releaseid: (."MusicBrainz Album Id" // ."MUSICBRAINZ_ALBUMID" // ."MusicBrainz/Album Id" // "")
    }'
}

# Decorate locally available music
#
# @input $1: Path to directory with album
#
# This methods reads the music files in the specified directory and writes a
# json file that points to all relevant MusicBrainz IDs. If the directory
# contains untagged files, or files of different releases, then the decoration
# process will fail, and an error is printed.
decorate() {
  if [ -f "$1/$DECORATION_FILENAME" ]; then
    info "Directory $1 has already been decorated (skipping)"
    return 0
  fi
  decoration=$($JQ -n '.tracks = {}')
  tmpf=$(mktemp)
  (cd "$1" && find . -type f -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.flac' -o -iname '*.m4a' -o -iname '*.ogg') >"$tmpf"
  while IFS= read -r f; do
    mbid=$(__gettags "$1/$f")
    rid=$(echo "$mbid" | $JQ '.releaseid')
    tid=$(echo "$mbid" | $JQ '.trackid')
    if [ ! "$rid" ] || [ ! "$tid" ]; then
      err "File $f: Seems not tagged"
      releaseid=""
      break
    fi
    if [ "${releaseid:-}" ]; then
      if [ "$releaseid" != "$rid" ]; then
        err "Directory $1 contains files of different releases"
        releaseid=""
        break
      fi
    else
      info "Decorating $1 as release $rid"
      releaseid="$rid"
    fi
    decoration=$(echo "$decoration" | $JQ ".tracks += {\"$tid\": \"$f\"}")
  done <"$tmpf"
  rm -f "$tmpf"
  if [ "$releaseid" ]; then
    echo "$decoration" | $JQ ".releaseid = \"$releaseid\"" >"$1/$DECORATION_FILENAME"
  else
    return 1
  fi
}

# Decorate locally available music with specified MusicBrainz release
#
# @input $1: Path to directory with album
# @input $2: MusicBrainz release ID
#
# Similar as `decorate`, but the MusicBrainz IDs are not inferred from the
# tags, but passed as argument.
decorate_as() {
  if [ -f "$1/$DECORATION_FILENAME" ]; then
    rid="$($JQ '.releaseid' "$1/$DECORATION_FILENAME")"
    title="$(mb_release "$rid" | $JQ '.title // ""')"
    artist="$(mb_release "$rid" | $JQ '."artist-credit" | map([.name, .joinphrase] | join("")) | join("")')"
    [ "$rid" = "$2" ] &&
      info "Directory $1 has already been decorated as the release '$title' - '$artist' with the identical MusicBrainz release ID." ||
      info "Directory $1 has already been decorated as the release '$title' - '$artist' with the MusicBrainz release ID $rid."
    while true; do
      infonn "Do you want to redecorate $1? (yes/no)"
      read -r yn
      case $yn in
      "yes") break ;;
      "no") return 0 ;;
      *) info "Please answer \"yes\" or \"no\"." ;;
      esac
    done
  fi
  # Print info
  title="$(mb_release "$2" | $JQ '.title // ""')"
  artist="$(mb_release "$2" | $JQ '."artist-credit" | map([.name, .joinphrase] | join("")) | join("")')"
  info "Decorating $1 as the release $title by $artist"
  # Start decoration
  decoration=$($JQ -n '.tracks = {}')
  tmpf=$(mktemp)
  (cd "$1" && find . -type f -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.flac' -o -iname '*.m4a' -o -iname '*.ogg' | sort) >"$tmpf"
  # Compare number of tracks with release
  rcnt="$(mb_release "$2" | $JQ '.media | map(."track-count") | add')"
  dcnt="$(wc -l "$tmpf" | cut -d ' ' -f 1)"
  if [ ! "$rcnt" -eq "$dcnt" ]; then
    err "Number of tracks in directory ($dcnt) does not match number of tracks in release ($rcnt)."
    return 1
  fi
  #
  tmpj=$(mktemp)
  mb_release "$2" |
    $JQ '.media[] |
    .position as $pos |
    .tracks |
    map({
      $pos,
      "id": .id,
      "n": .number,
      "t": .title
    }) |
    map(if(.n | type == "string" and test("^[0-9]+$")) then .n |= tonumber else . end) |
    sort_by([.pos, .n])[] |
    [.t, .id] |
    join("\t")' >"$tmpj"
  assocfile=$(mktemp)
  awk -F '\t' '
BEGIN { OFS = "\t" }
FNR == NR { title[FNR] = $1; id[FNR] = $2 }
FNR != NR { fname[FNR] = $1 }
END { for (i in id) print title[i], id[i], fname[i] }
' "$tmpj" "$tmpf" >"$assocfile"
  rm -f "$tmpj" "$tmpf"
  # Ask user if this is ok
  info "We discovered the following associatoin:"
  while IFS= read -r line; do
    t="$(echo "$line" | cut -d "$(printf '\t')" -f 1)"
    f="$(echo "$line" | cut -d "$(printf '\t')" -f 3)"
    printf "Track '%s'\tFile '%s'\n" "$t" "$f"
  done <"$assocfile" | column -t -s "$(printf '\t')"
  while true; do
    infonn "Are the track correctly associated to the audio files? (yes/no)"
    read -r yn
    case $yn in
    "yes") break ;;
    "no") return 0 ;;
    *) info "Please answer \"yes\" or \"no\"." ;;
    esac
  done
  # Construct decoration
  decoration=$($JQ -n '.tracks = {}')
  while IFS= read -r line; do
    i="$(echo "$line" | cut -d "$(printf '\t')" -f 2)"
    f="$(echo "$line" | cut -d "$(printf '\t')" -f 3)"
    decoration=$(echo "$decoration" | $JQ ".tracks += {\"$i\": \"$f\"}")
  done <"$assocfile"
  echo "$decoration" | $JQ ".releaseid = \"$2\"" >"$1/$DECORATION_FILENAME"
  return 0
}

# Precompute lists
#
# The main views (VIEW_ARTIST and TYPE_RELEASEGROUP) for locally available
# music are theme dependent. These views are generated from the lists that are
# produced with the present method. It contains all essential data, but in a
# theme-independent fashion. The lists are stored in the files
# `LOCALDATA_ARTISTS_LIST` and `LOCALDATA_RELEASEGROUPS_LIST`.
__precompute_lists() {
  cache_get_file_batch "$TYPE_ARTIST" <"$LOCALDATA_ARTISTS" | xargs -d "\n" \
    $JQ '[
      .id,
      .type,
      .name,
      ."sort-name",
      .disambiguation,
      .["life-span"].begin,
      .["life-span"].end
      ] | join("\t")' >"$LOCALDATA_ARTISTS_LIST" &
  cache_get_file_batch "$TYPE_RELEASEGROUP" <"$LOCALDATA_RELEASEGROUPS" | xargs -d "\n" \
    $JQ '[
      .id,
      ."primary-type",
      (."secondary-types" // []|join(";")),
      ."first-release-date",
      .title,
      (."artist-credit" | map(([.name, .joinphrase]|join(""))) | join(""))
      ] | join("\t")' >"$LOCALDATA_RELEASEGROUPS_LIST" &
  wait
}

# Precompute views
#
# This method injects the theme elements to the lists from `precompute_lists`.
# The resulting views are stored in the files `LOCALDATA_ARTISTS_VIEW` and
# `LOCALDATA_RELEASEGROUPS_VIEW`.
precompute_views() {
  awk_artists "$SORT_ARTIST_DEFAULT" <"$LOCALDATA_ARTISTS_LIST" >"$LOCALDATA_ARTISTS_VIEW"
  awk_releasegroups "$SORT_RG_DEFAULT" <"$LOCALDATA_RELEASEGROUPS_LIST" >"$LOCALDATA_RELEASEGROUPS_VIEW"
}

# Load local music
#
# argument $1: path to decorated music files
#
# This method parses all decorations and generates a line-by-line database of
# locally available artists, releases, and release groups. This data is stored
# in the files `LOCALDATA_ARTISTS`, `LOCALDATA_RELEASES`, and
# `LOCALDATA_RELEASEGROUPS`.
reloaddb() {
  rm -rf "$LOCALDATADIR"
  mkdir -p "$LOCALDATADIR"
  find "$1" -type f -name "$DECORATION_FILENAME" -print0 |
    xargs -0 $JQ '.releaseid+"\t"+input_filename' >"$LOCALDATA_RELEASES"
  # Get necessary metadata and setup lists
  tmpreleases=$(mktemp)
  cut -d "$(printf '\t')" -f 1 "$LOCALDATA_RELEASES" |
    tee "$tmpreleases" |
    batch_load_missing "$TYPE_RELEASE"
  tmpreleasefiles=$(mktemp)
  cache_get_file_batch "$TYPE_RELEASE" <"$tmpreleases" >"$tmpreleasefiles"
  (
    xargs -d "\n" \
      $JQ '."release-group".id' \
      <"$tmpreleasefiles" >"$LOCALDATA_RELEASEGROUPS"
    tf1=$(mktemp)
    sort "$LOCALDATA_RELEASEGROUPS" | uniq >"$tf1"
    mv "$tf1" "$LOCALDATA_RELEASEGROUPS"
  ) &
  (
    xargs -d "\n" \
      $JQ '."release-group"."artist-credit" | map(.artist.id) | join("\n")' \
      <"$tmpreleasefiles" >"$LOCALDATA_ARTISTS"
    tf2=$(mktemp)
    sort "$LOCALDATA_ARTISTS" | uniq >"$tf2"
    mv "$tf2" "$LOCALDATA_ARTISTS"
  ) &
  wait
  rm -f "$tmpreleases" "$tmpreleasefiles"
  batch_load_missing "$TYPE_RELEASEGROUP" <"$LOCALDATA_RELEASEGROUPS"
  batch_load_missing "$TYPE_ARTIST" <"$LOCALDATA_ARTISTS"
  __precompute_lists
}

# Check if necessary cache files are present or not
#
# This method returns a non-zero value if some cached file is required to exist
# for the computation of the lists (and views). This does not include the
# derivation of the MusicBrainz artist IDs and MusicBrainz release-group IDs
# from the MusicBrainz releases (see the `reloaddb` method above).
local_files_present() {
  cached "$TYPE_ARTIST" "$LOCALDATA_ARTISTS" || return 1
  cached "$TYPE_RELEASEGROUP" "$LOCALDATA_RELEASEGROUPS" || return 1
}

# Load missing files
#
# If missing files were detected with `local_files_present`, then these missing
# files may be cached using the present method.
load_missing_files() {
  batch_load_missing "$TYPE_ARTIST" <"$LOCALDATA_ARTISTS"
  batch_load_missing "$TYPE_RELEASEGROUP" <"$LOCALDATA_RELEASEGROUPS"
}
