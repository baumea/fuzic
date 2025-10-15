# Methods and constants for lyrics handling
#
# Lyrics are retrieved as following:
# 1. Check if the lyrics are already stored in this store
# 2. If the track is playable, check if an accompanying `.lrc` file is present.
# 3. If the track is playable, read lyrics from the tags
# 4. Call custom fetch command
#
# The path to the lyrics is `__radix(mbid)/mbid.lrc` where `mbid` is the
# MusicBrainz ID of the track.

if [ ! "${LYRICS_LOADED:-}" ]; then
  # Folder to store lyrics
  LYRICS_DIRECTORY="${LYRICS_DIRECTORY:-"$LOCALDATADIR/lyrics"}"
  [ -d "$LYRICS_DIRECTORY" ] || mkdir -p "$LYRICS_DIRECTORY"
  export LYRICS_DIRECTORY

  # Custom command to fetch lyrics
  #
  # This command reads from stdin the json object of the release and prints the
  # lyrics of the track.
  LYRICS_FETCH_CUSTOM="${LYRICS_FETCH_CUSTOM:-""}"
  export LYRICS_FETCH_CUSTOM

  export LYRICS_LOADED=1
fi

# File path for lyrics file
#
# @argument $1: MusicBrainz track ID
lyrics_file() {
  mbid="${1:-}"
  echo "$LYRICS_DIRECTORY/$(__radix "$mbid").lrc"
}

# Store lyrics
#
# @argument $1: MusicBrainz track ID
#
# This methods reads from stdin and stores it.
store_lyrics() {
  mbid="${1:-}"
  file="$(lyrics_file "$mbid")"
  dir="$(dirname "$file")"
  [ -d "$dir" ] || mkdir -p "$dir"
  cat >"$file"
}

# Fetch lyrics using custom command and store them
#
# @argument $1: MusicBrainz release ID
# @argument $2: MusicBrainz track ID
#
# The custom script is executed only if the environment variable is set. Else
# the message stored in `$LYRICS_NO_LYRICS` is saved.
store_lyrics_custom() {
  rlid="${1:-}"
  mbid="${2:-}"
  if [ "$LYRICS_FETCH_CUSTOM" ]; then
    mb_release "$rlid" |
      $JQ --arg mbid "$mbid" '{release: ., trackid: $mbid}' |
      sh -c "$LYRICS_FETCH_CUSTOM" |
      store_lyrics "$mbid"
  else
    echo "$LYRICS_NO_LYRICS" |
      store_lyrics "$mbid"
  fi
}

# Print lyrics
#
# @argument $1: MusicBrainz release ID
# @argument $2: MusicBrainz track ID
lyrics() {
  rlid="${1:-}"
  mbid="${2:-}"
  # 1. Check if lyrics has already been stored
  file="$(lyrics_file "$mbid")"
  if [ -f "$file" ]; then
    cat "$file"
    return
  fi
  # 2. & 3.: For playable tracks only
  decoration="$(grep "^$rlid" "$LOCALDATA_RELEASES" | cut -d "$(printf '\t')" -f 2)"
  if [ "$decoration" ] && [ -f "$decoration" ]; then
    afname="$($JQ --arg mbid "$mbid" '.tracks | to_entries[] | select(.key == $mbid) | .value' "$decoration")"
    af="$(dirname "$decoration")/$afname"
    # Check if `.lrc` file exists
    lf="$(echo "$af" | rev | cut -d "." -f 2- | rev).lrc"
    if [ -f "$lf" ]; then
      store_lyrics "$mbid" <"$lf"
      cat "$file"
      return
    fi
    # Read lyrics from tag
    if [ "$FFPROBE" ]; then
      lyrics="$($FFPROBE -v error -show_entries format_tags -print_format json "$af" |
        $JQ '.format.tags | ."USLT:description" // ."LYRICS" // ."Lyrics" // ."©lyr" // ."WM/Lyrics" // ""')"
      if [ "$lyrics" ]; then
        echo "$lyrics" | store_lyrics "$mbid"
        cat "$file"
        return
      fi
    fi
  fi
  # Make call to external command
  store_lyrics_custom "$rlid" "$mbid"
  cat "$file"
}

# Reload lyrics file
#
# @argument $1: MusicBrainz release ID
# @argument $2: MusicBrainz track ID
reload_lyrics() {
  rlid="${1:-}"
  mbid="${2:-}"
  file="$(lyrics_file "$mbid")"
  rm -f "$file"
  lyrics "$rlid" "$mbid"
}
