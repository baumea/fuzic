# Preset filters for different views. These filters are associated to key
# bindings (see `src/sh/keys.sh`), and are configurable through a configuration
# file (see `src/sh/config.sh`).
if [ ! "${FILTER_LOADED:-}" ]; then
  # The `QUERY_LOCAL` filter is associated with the keys `KEYS_FILTER_LOCAL`.
  # It is used to hide all entries that are not available locally (see
  # `src/sh/query.sh` for details and the relevant methods)
  QUERY_LOCAL="${QUERY_LOCAL:-"$(printf "'%s'" "$FORMAT_LOCAL" | __clean_filter)"}"

  # The following variables store preset strings derived from the theme (see
  # `src/sh/theme.sh`), and used in the assignment of the default filters.
  q_has_seconary="$(printf "%s" "$RGV_FMT_HASSECONDARY_YES" | __clean_filter)"
  q_album="$(printf "%s" "$RGV_FMT_TYPE_ALBUM" | __clean_filter)"
  q_ep="$(printf "%s" "$RGV_FMT_TYPE_EP" | __clean_filter)"
  q_single="$(printf "%s" "$RGV_FMT_TYPE_SINGLE" | __clean_filter)"
  if printf "$RV_FMT" | grep -q "<<status>>"; then
    q_official="$(printf "'%s'" "$RV_FMT_STATUS_OFFICIAL" | __clean_filter)"
  fi
  export QUERY_LOCAL

  # Here starts the list of all filters (grouped per view) that are associated
  # to the keys `KEYS_FILTER_0` - `KEYS_FILTER_9`. The filters in the
  # `F_1_<view>` variable are automatically applied whenever the given view is
  # entered.
  F_1_VIEW_ARTIST="${F_1_VIEW_ARTIST:-"!'$q_has_seconary'"}"
  F_2_VIEW_ARTIST="${F_2_VIEW_ARTIST:-"'$q_album'"}"
  F_3_VIEW_ARTIST="${F_3_VIEW_ARTIST:-"'$q_ep'"}"
  F_4_VIEW_ARTIST="${F_4_VIEW_ARTIST:-"'$q_single'"}"
  F_5_VIEW_ARTIST="${F_5_VIEW_ARTIST:-}"
  F_6_VIEW_ARTIST="${F_6_VIEW_ARTIST:-}"
  F_7_VIEW_ARTIST="${F_7_VIEW_ARTIST:-}"
  F_8_VIEW_ARTIST="${F_8_VIEW_ARTIST:-}"
  F_9_VIEW_ARTIST="${F_9_VIEW_ARTIST:-}"
  export F_1_VIEW_ARTIST F_2_VIEW_ARTIST F_3_VIEW_ARTIST F_4_VIEW_ARTIST \
    F_5_VIEW_ARTIST F_6_VIEW_ARTIST F_7_VIEW_ARTIST F_8_VIEW_ARTIST \
    F_9_VIEW_ARTIST

  F_1_VIEW_RELEASEGROUP="${F_1_VIEW_RELEASEGROUP:-"${q_official:-}"}"
  F_2_VIEW_RELEASEGROUP="${F_2_VIEW_RELEASEGROUP:-}"
  F_3_VIEW_RELEASEGROUP="${F_3_VIEW_RELEASEGROUP:-}"
  F_4_VIEW_RELEASEGROUP="${F_4_VIEW_RELEASEGROUP:-}"
  F_5_VIEW_RELEASEGROUP="${F_5_VIEW_RELEASEGROUP:-}"
  F_6_VIEW_RELEASEGROUP="${F_6_VIEW_RELEASEGROUP:-}"
  F_7_VIEW_RELEASEGROUP="${F_7_VIEW_RELEASEGROUP:-}"
  F_8_VIEW_RELEASEGROUP="${F_8_VIEW_RELEASEGROUP:-}"
  F_9_VIEW_RELEASEGROUP="${F_9_VIEW_RELEASEGROUP:-}"
  export F_1_VIEW_RELEASEGROUP F_2_VIEW_RELEASEGROUP F_3_VIEW_RELEASEGROUP \
    F_4_VIEW_RELEASEGROUP F_5_VIEW_RELEASEGROUP F_6_VIEW_RELEASEGROUP \
    F_7_VIEW_RELEASEGROUP F_8_VIEW_RELEASEGROUP F_9_VIEW_RELEASEGROUP

  F_1_VIEW_RELEASE="${F_1_VIEW_RELEASE:-}"
  F_2_VIEW_RELEASE="${F_2_VIEW_RELEASE:-}"
  F_3_VIEW_RELEASE="${F_3_VIEW_RELEASE:-}"
  F_4_VIEW_RELEASE="${F_4_VIEW_RELEASE:-}"
  F_5_VIEW_RELEASE="${F_5_VIEW_RELEASE:-}"
  F_6_VIEW_RELEASE="${F_6_VIEW_RELEASE:-}"
  F_7_VIEW_RELEASE="${F_7_VIEW_RELEASE:-}"
  F_8_VIEW_RELEASE="${F_8_VIEW_RELEASE:-}"
  F_9_VIEW_RELEASE="${F_9_VIEW_RELEASE:-}"
  export F_1_VIEW_RELEASE F_2_VIEW_RELEASE F_3_VIEW_RELEASE F_4_VIEW_RELEASE \
    F_5_VIEW_RELEASE F_6_VIEW_RELEASE F_7_VIEW_RELEASE F_8_VIEW_RELEASE \
    F_9_VIEW_RELEASE

  F_1_LIST_ARTISTS="${F_1_LIST_ARTISTS:-}"
  F_2_LIST_ARTISTS="${F_2_LIST_ARTISTS:-}"
  F_3_LIST_ARTISTS="${F_3_LIST_ARTISTS:-}"
  F_4_LIST_ARTISTS="${F_4_LIST_ARTISTS:-}"
  F_5_LIST_ARTISTS="${F_5_LIST_ARTISTS:-}"
  F_6_LIST_ARTISTS="${F_6_LIST_ARTISTS:-}"
  F_7_LIST_ARTISTS="${F_7_LIST_ARTISTS:-}"
  F_8_LIST_ARTISTS="${F_8_LIST_ARTISTS:-}"
  F_9_LIST_ARTISTS="${F_9_LIST_ARTISTS:-}"
  export F_1_LIST_ARTISTS F_2_LIST_ARTISTS F_3_LIST_ARTISTS F_4_LIST_ARTISTS \
    F_5_LIST_ARTISTS F_6_LIST_ARTISTS F_7_LIST_ARTISTS F_8_LIST_ARTISTS \
    F_9_LIST_ARTISTS

  F_1_LIST_ALBUMS="${F_1_LIST_ALBUMS:-}"
  F_2_LIST_ALBUMS="${F_2_LIST_ALBUMS:-}"
  F_3_LIST_ALBUMS="${F_3_LIST_ALBUMS:-}"
  F_4_LIST_ALBUMS="${F_4_LIST_ALBUMS:-}"
  F_5_LIST_ALBUMS="${F_5_LIST_ALBUMS:-}"
  F_6_LIST_ALBUMS="${F_6_LIST_ALBUMS:-}"
  F_7_LIST_ALBUMS="${F_7_LIST_ALBUMS:-}"
  F_8_LIST_ALBUMS="${F_8_LIST_ALBUMS:-}"
  F_9_LIST_ALBUMS="${F_9_LIST_ALBUMS:-}"
  export F_1_LIST_ALBUMS F_2_LIST_ALBUMS F_3_LIST_ALBUMS F_4_LIST_ALBUMS \
    F_5_LIST_ALBUMS F_6_LIST_ALBUMS F_7_LIST_ALBUMS F_8_LIST_ALBUMS \
    F_9_LIST_ALBUMS

  export FILTER_LOADED=1
fi
