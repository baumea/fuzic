# Playlist manipulation
#
# This files provides an interface to manipulate the playlist. The available
# commands are defined in the following variables.
if [ ! "${PLAYLIST_LOADED:-}" ]; then
  # Playlist commands
  PLAYLIST_CMD_REMOVE="rm"
  PLAYLIST_CMD_UP="up"
  PLAYLIST_CMD_DOWN="down"
  PLAYLIST_CMD_CLEAR="clear"
  PLAYLIST_CMD_CLEAR_ABOVE="clear-above"
  PLAYLIST_CMD_CLEAR_BELOW="clear-below"
  PLAYLIST_CMD_SHUFFLE="shuffle"
  PLAYLIST_CMD_UNSHUFFLE="unshuffle"
  PLAYLIST_CMD_LOAD="load"
  export PLAYLIST_CMD_REMOVE PLAYLIST_CMD_UP PLAYLIST_CMD_DOWN \
    PLAYLIST_CMD_CLEAR PLAYLIST_CMD_CLEAR_ABOVE PLAYLIST_CMD_CLEAR_BELOW \
    PLAYLIST_CMD_SHUFFLE PLAYLIST_CMD_UNSHUFFLE PLAYLIST_CMD_LOAD

  # Storage and loading of playlists
  PLAYLIST_DIRECTORY="${PLAYLIST_DIRECTORY:-"$LOCALDATADIR/playlists"}"
  [ -d "$PLAYLIST_DIRECTORY" ] || mkdir -p "$PLAYLIST_DIRECTORY"
  export PLAYLIST_DIRECTORY

  export PLAYLIST_LOADED=1
fi

# List stored playlists
#
# This prints the names of the stored playlists.
stored_playlists() {
  find "$PLAYLIST_DIRECTORY" -mindepth 1 -maxdepth 1 -type f -printf "$PLYSTORE_PLAYLIST\t%f\n" |
    sort
}

# Generate playlist from MB release ID and path to decoration
#
# @argument $1: MusicBrainz release ID
# @argument $2: Path to decoration file
# @argument $3: MusicBrainz track ID to select (optional)
generate_playlist() {
  printf "#EXTM3U\n"
  dir="$(dirname "$2")"
  mb_release "$1" |
    $JQ \
      --slurpfile decofile "$2" \
      --arg base "$dir" \
      --arg deco "$2" \
      --arg tid "${3:-}" \
      '$decofile[].tracks as $filenames |
        . |
        .id as $rid |
        .media |
        length as $l |
        .[] |
        .position as $pos |
        .tracks |
        if ($tid == "") then . else map(select(.id == $tid)) end |
        map({
          t: [
          $rid,
          .id,
          $l,
          $pos,
          .number,
          .length,
          .title,
          (."artist-credit" | map([.name, .joinphrase] | join("")) | join("")),
          $deco
          ] | join("\t"),
          length: (.length // 0 / 1000 | round | tostring),
          $pos,
          number: .number,
          file: $filenames[.id]
        }) |
        map(if(.number | type == "string" and test("^[0-9]+$")) then .number |= tonumber else . end) |
        sort_by([.pos, .number]) |
        map("#EXTINF:" + .length + "," + .t + "\n" + $base + "/" + .file)[]'
}

# Generate m3u playlist from stored playlist
#
# @argument $1: Playlist file
generate_playlist_stored() {
  f="${1:-}"
  [ -s "$f" ] || return
  # Check that we have all releases cached, else fetch missing ones
  relf=$(mktemp)
  cut -d "$(printf '\t')" -f 1 "$f" >"$relf"
  cached "$TYPE_RELEASE" "$relf" || batch_load_missing "$TYPE_RELEASE" <"$relf"
  jrelf=$(mktemp)
  # Write json file with all releases
  cache_get_file_batch "$TYPE_RELEASE" <"$relf" |
    xargs -d '\n' cat >"$jrelf"
  # Get associated decorations and write json file with all decorations
  jpf=$(mktemp)
  jdecf=$(mktemp)
  awk -F '\t' \
    -v rfile="$LOCALDATA_RELEASES" \
    'BEGIN {
      OFS="\t"
      while ((getline < rfile) == 1)
        release[$1] = $2
      close(rfile)
      print "["
    }
    NR > 1 { print "," }
    { print "{\"rid\":\"" $1 "\",\"tid\":\"" $2 "\",\"deco\":\"" (release[$1] ? release[$1] : "") "\"}" }
  END {print "]"}' <"$f" >"$jpf"
  $JQ 'map(.deco) | join("\n")' "$jpf" |
    grep '.' |
    xargs -d '\n' cat >"$jdecf"
  # Merge all data using jq and print playlist
  printf "#EXTM3U\n"
  $JQ \
    --slurpfile deco "$jdecf" \
    --slurpfile mb "$jrelf" \
    '$deco as $decorations |
      $mb as $releases |
      map(
        . as $item |
        first(
          if ($item.deco | length) > 0 then
            ($item.deco | sub("/[^/]+$"; "")) as $base |
              first($deco[] | select(.releaseid == $item.rid).tracks | to_entries[] | select(.key == $item.tid).value) as $fn |
            $base + "/" + $fn
          else
            "/dev/null"
          end
        ) as $p |
        first(
          $mb[] | select(.id == $item.rid).media[].tracks[] | select(.id == $item.tid)
        ) as $track |
        (
          $track.length // 0 / 1000 | round | tostring
        ) as $length |
        ( if ($item.deco | length) > 0 then $item.deco else "/dev/null" end) as $d |
        $item + {
          path: $p,
          length: $length,
          t: [
            $item.rid,
            $item.tid,
            "",
            "",
            "",
            $length,
            $track.title,
            ($track."artist-credit" | map([.name, .joinphrase] | join("")) | join("")),
            $d
          ] | join("\t")
        }
      ) |
      map("#EXTINF:" + .length + "," + .t + "\n" + .path)[]' \
    "$jpf"
  # Clean up
  rm -f "$relf" "$jrelf" "$jpf" "$jdecf"
}

# Run playback commands
#
# @argument $1: playlist command
#
# This is a wrapper to execute mpv commands.
playlist() {
  case "$1" in
  "$PLAYLIST_CMD_REMOVE") mpv_rm_index $((FZF_POS - 1)) ;;
  "$PLAYLIST_CMD_UP") mpv_playlist_move $((FZF_POS - 1)) $((FZF_POS - 2)) ;;
  "$PLAYLIST_CMD_DOWN") mpv_playlist_move $((FZF_POS - 0)) $((FZF_POS - 1)) ;;
  "$PLAYLIST_CMD_CLEAR") mpv_playlist_clear ;;
  "$PLAYLIST_CMD_CLEAR_ABOVE")
    for _ in $(seq "$FZF_POS"); do
      mpv_rm_index 0
    done
    ;;
  "$PLAYLIST_CMD_CLEAR_BELOW")
    cnt=$(mpv_playlist_count)
    rem=$((cnt - FZF_POS + 1))
    for _ in $(seq "$rem"); do
      mpv_rm_index $((FZF_POS - 1))
    done
    ;;
  "$PLAYLIST_CMD_SHUFFLE") mpv_playlist_shuffle ;;
  "$PLAYLIST_CMD_UNSHUFFLE") mpv_playlist_unshuffle ;;
  "$PLAYLIST_CMD_LOAD")
    f="$PLAYLIST_DIRECTORY/${2:-}"
    [ -s "$f" ] || return
    generate_playlist_stored "$f" | mpv_play_list >/dev/null
    ;;
  esac
}
