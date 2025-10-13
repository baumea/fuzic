# Preview methods
#
# For now, only artist previews are supported.

if [ ! "${PREVIEW_LOADED:-}" ]; then
  PREVIEW_NO_WRAP="__DO_NOT_WRAP_THIS_LINE__"
  PREVIEW_WINDOW_PERCENTAGE="30"
  export PREVIEW_NO_WRAP PREVIEW_WINDOW_PERCENTAGE

  export PREVIEW_LOADED=1
fi

# This internal method reshapes the text to be shown in the preview. This
# creates a border on both horizontal ends.
#
# The text is read from stdin. If a line contains the pattern defined in
# PREVIEW_NO_WRAP, then that line will not be folded.
__shape() {
  #width="$((FZF_PREVIEW_COLUMNS - 4))"
  width="$((FZF_COLUMNS * PREVIEW_WINDOW_PERCENTAGE / 100 - 4))"
  while IFS= read -r line; do
    line="$(printf "%s" "$line" | tr -d '\r')"
    if printf "%s" "$line" | grep --silent "$PREVIEW_NO_WRAP"; then
      printf "  %s\n" "$line" | sed "s/$PREVIEW_NO_WRAP//g"
    else
      printf "%s\n" "$line" |
        fold -s -w "$width" |
        awk '{print "  "$0"  "}'
    fi
  done
}

# Print preview of artist
#
# @input $1: MusicBrainz artist ID
preview_artist() {
  name="$(mb_artist "$1" | $JQ '.name')"
  sortname="$(mb_artist "$1" | $JQ '."sort-name"')"
  disamb="$(mb_artist "$1" | $JQ '.disambiguation')"
  bio=$(mb_artist_enwikipedia "$1" | $JQ '.extract')
  [ "$bio" ] || bio=$(mb_artist_discogs "$1" | $JQ '.profile' | sed 's/\[a=\([^]]*\)\]/\1/g')
  alias="$(mb_artist "$1" | $JQ '.aliases | map(.name) | join("\t")')"
  startdate="$(mb_artist "$1" | $JQ '."life-span".begin // ""' | head -c 4)"
  startplace="$(mb_artist "$1" | $JQ '."begin-area".name // ""')"
  enddate="$(mb_artist "$1" | $JQ '."life-span".end // ""' | head -c 4)"
  endplace="$(mb_artist "$1" | $JQ '."end-area".name // ""')"
  url="$(mb_artist "$1" | $JQ '[.relations[] | select(."target-type" == "url") | [.type, .url.resource] | join(";")] | join("\t")')"
  if [ "$(mb_artist "$1" | $JQ '.type')" = "Person" ]; then
    awk_preview_artist_person \
      "$name" \
      "$sortname" \
      "$disamb" \
      "$bio" \
      "$alias" \
      "$startdate" \
      "$startplace" \
      "$enddate" \
      "$endplace" \
      "$url" |
      __shape
  else
    awk_preview_artist_group \
      "$name" \
      "$sortname" \
      "$disamb" \
      "$bio" \
      "$alias" \
      "$startdate" \
      "$startplace" \
      "$enddate" \
      "$endplace" \
      "$url" |
      __shape
  fi
  #link=$(printf "More info:\033]8;;%s\033\\ %s\033]8;;\033\\" "https://musicbrainz.org/" "[MusicBrainz]")
}

# Print message if there is nothing to be shown
preview_nothing() {
  echo "No preview available."
}
