# The default queries depend on the current view, and are usually derived from
# the theme. Nevertheless, they may be overwritten with the configuration file.
# Note that filters are not used in the views VIEW_SEARCH_ARTIST and
# VIEW_SEARCH_ALBUM. The reason for this is that in those modes, changing the
# query string triggers a search on the MusicBrainz website (the input is not a
# filter, but a query).
#
# The keybinding KEYS_FILTER_LOCAL triggers a filter of QUERY_LOCAL in the
# views VIEW_ARTIST, VIEW_RELEASEGROUP, and VIEW_RELEASE only. Here, it is only
# possible to adjust QUERY_LOCAL via the configuration. The keybinding KEYS_FILTER_0
# resets the query. F_1_.. filters are the default filters when the respective
# view is entered. For all other keys, the filters are individually
# configurable, by specifying e.g., F_3_VIEW_LIST_ALBUMS.
#
# Derived queries
# To derive the queries from the theme, we must perform some steps: 1) remove
# colors, and 2) escape white spaces. This is implemented in the method
# `__clean_filter`.
#
# List of derived queries:
# - QUERY_LOCAL: Hide items that are not locally available
# - q_has_secondary: Release groups with secondary types
# - q_album: Release group is of type Album
# - q_ep: Release group is of type EP
# - q_single: Release group is of type single
# - q_official: Release is official

# Clean a filter string
#
# This method reads from stdin a string and removes all colors and escapes
# white spaces.
__clean_filter() {
  cat | sed "s/${ESC}\[[0-9;]*[mK]//g" | sed "s/ /\\\ /g"
}

# Determine preset query
#
# @argument $1: Current view
# @argument $2: Key pressed (optional)
#
# If the key is not given, then the F_1_.. query is used for the respective
# view, i.e, its as if a key from KEYS_FILTER_1 has been pressed.
default_query() {
  view=$1
  key="${2:-"$(echo "$KEYS_FILTER_1" | cut -d ',' -f 1)"}"
  case ",$KEYS_FILTER_LOCAL," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST" | "$VIEW_RELEASEGROUP" | "$VIEW_RELEASE") echo "$QUERY_LOCAL" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_1," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_1_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_1_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_1_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_1_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_1_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_2," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_2_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_2_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_2_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_2_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_2_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_3," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_3_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_3_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_3_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_3_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_3_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_4," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_4_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_4_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_4_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_4_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_4_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_5," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_5_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_5_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_5_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_5_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_5_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_6," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_6_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_6_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_6_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_6_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_6_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_7," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_7_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_7_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_7_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_7_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_7_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_8," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_8_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_8_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_8_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_8_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_8_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  case ",$KEYS_FILTER_9," in
  *",$key,"*)
    case "$view" in
    "$VIEW_ARTIST") echo "$F_9_VIEW_ARTIST" ;;
    "$VIEW_RELEASEGROUP") echo "$F_9_VIEW_RELEASEGROUP" ;;
    "$VIEW_RELEASE") echo "$F_9_VIEW_RELEASE" ;;
    "$VIEW_LIST_ARTISTS") echo "$F_9_LIST_ARTISTS" ;;
    "$VIEW_LIST_ALBUMS") echo "$F_9_LIST_ALBUMS" ;;
    esac
    ;;
  esac
  # Doing nothing is the same as this last block:
  # case ",$KEYS_FILTER_0," in
  # *",$key,"*)
  #   case "$view" in
  #   "$VIEW_ARTIST" | "$VIEW_RELEASEGROUP" | "$VIEW_RELEASE" | "$VIEW_LIST_ARTISTS" | "$VIEW_LIST_ALBUMS") echo "" ;;
  #   esac
  #   ;;
  # esac
}
