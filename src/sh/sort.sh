# Sort methods for generated lists

if [ ! "${SORT_LOADED:-}" ]; then
  # Sort specifications
  #
  # - No sort
  # - Alphabetic sort
  # - Numeric sort
  SORT_NO="no-sort"
  SORT_ALPHA="sort-alpha"
  SORT_NUMERIC="sort-numeric"

  # Artists may be sorted according to the name or the sort-name taken from
  # MusicBrainz
  SORT_ARTIST="sort-artist"
  SORT_ARTIST_SORTNAME="sort-artist-sortname"

  # Release-groups may be sorted according to the release year or the title
  SORT_RG_TITLE="sort-rg-title"
  SORT_RG_YEAR="sort-rg-year"
  export SORT_NO SORT_ALPHA SORT_NUMERIC SORT_ARTIST SORT_ARTIST_SORTNAME \
    SORT_RG_TITLE SORT_RG_YEAR

  # Configurable default sort
  SORT_ARTIST_DEFAULT="${SORT_ARTIST_DEFAULT:-"$SORT_ARTIST"}"
  SORT_RG_DEFAULT="${SORT_RG_DEFAULT:-"$SORT_RG_YEAR"}"
  export SORT_ARTIST_DEFAULT SORT_RG_DEFAULT

  export SORT_LOADED=1
fi

# Sorting switches
#
# @argument $1: Sort specification (may be one of SORT_NO, SORT_ALPHA,
#               SORT_NUMERIC)
#
# This method sorts the stream read from stdin.
sort_list() {
  case "${1:-}" in
  "$SORT_ALPHA") cat | sort -t "$(printf '\t')" -k 2,2 ;;
  "$SORT_NUMERIC") cat | sort -t "$(printf '\t')" -k 2,2 -n ;;
  *) cat ;;
  esac
}
