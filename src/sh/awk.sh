# The code below is used together with `scripts/build.sh`to internalize the awk
# scripts. See the awk sources for more information.

if [ ! "${AWK_LOADED:-}" ]; then
  AWK_ARTISTS=$(
    cat <<'EOF'
@@include awk/artists.awk
EOF
  )
  export AWK_ARTISTS

  AWK_RELEASES=$(
    cat <<'EOF'
@@include awk/releases.awk
EOF
  )
  export AWK_RELEASES

  AWK_RELEASEGROUPS=$(
    cat <<'EOF'
@@include awk/releasegroups.awk
EOF
  )
  export AWK_RELEASEGROUPS

  AWK_RECORDINGS=$(
    cat <<'EOF'
@@include awk/recordings.awk
EOF
  )
  export AWK_RECORDINGS

  AWK_PREVIEW_ARTIST=$(
    cat <<'EOF'
@@include awk/preview_artist.awk
EOF
  )
  export AWK_PREVIEW_ARTIST

  export AWK_LOADED=1
fi

# Themed awk script to generate list of artists
#
# @argument $1: Sort specification (may be one of SORT_NO, SORT_NAME,
#               SORT_SORTNAME)
awk_artists() {
  case "${1:-}" in
  "$SORT_ARTIST" | "$SORT_ARTIST_SORTNAME") s="$SORT_ALPHA" ;;
  *) s="$SORT_NO" ;;
  esac
  cat |
    awk \
      -F "\t" \
      -v sortby="${1:-}" \
      -v flagfile="${LOCALDATA_ARTISTS:-}" \
      -v format="$AV_FMT" \
      -v flag_local="$AV_FMT_FLAG_LOCAL" \
      -v flag_nolocal="$AV_FMT_FLAG_NO_LOCAL" \
      -v type_person="$AV_FMT_TYPE_PERSON" \
      -v type_group="$AV_FMT_TYPE_GROUP" \
      -v fmtname="$AV_FMT_NAME" \
      -v fmtdisambiguation="$AV_FMT_DISAMBIGUATION" \
      "$AWK_ARTISTS" |
    column -t -s "$(printf '\t')" -R "$AV_FMT_RIGHTALIGN" -l "$AV_FMT_CNT" |
    sort_list "$s"
}

# Themed awk script to generate artist header
awk_artist_header() {
  cat |
    awk \
      -F "\t" \
      -v flagfile="${LOCALDATA_ARTISTS:-}" \
      -v format="$HEADER_ARTIST_FMT" \
      -v flag_local="$HEADER_ARTIST_FMT_FLAG_LOCAL" \
      -v flag_nolocal="$HEADER_ARTIST_FMT_FLAG_NO_LOCAL" \
      -v type_person="$HEADER_ARTIST_FMT_TYPE_PERSON" \
      -v type_group="$HEADER_ARTIST_FMT_TYPE_GROUP" \
      -v fmtname="$HEADER_ARTIST_FMT_NAME" \
      -v fmtdisambiguation="$HEADER_ARTIST_FMT_DISAMBIGUATION" \
      "$AWK_ARTISTS" |
    column -t -s "$(printf '\t')" -R "$HEADER_ARTIST_FMT_RIGHTALIGN" -l "$HEADER_ARTIST_FMT_CNT" |
    cut -d "$(printf '\t')" -f 1
}

# Themed awk script to generate list of release groups
#
# @argument $1: Sort specification (may be one of SORT_NO, SORT_RG_TITLE,
#               SORT_RG_YEAR)
# @argument $2: MusicBrainz artist ID (optional)
# @argument $3: Artist credit name (optional)
awk_releasegroups() {
  case "${1:-}" in
  "$SORT_RG_TITLE") s="$SORT_ALPHA" ;;
  "$SORT_RG_YEAR") s="$SORT_NUMERIC" ;;
  *) s="$SORT_NO" ;;
  esac
  cat |
    awk \
      -F "\t" \
      -v sortby="${1:-}" \
      -v artistid="${2:-}" \
      -v origartist="${3:-}" \
      -v flagfile="${LOCALDATA_RELEASEGROUPS:-}" \
      -v format="$RGV_FMT" \
      -v flag_local="$RGV_FMT_FLAG_LOCAL" \
      -v flag_nolocal="$RGV_FMT_FLAG_NO_LOCAL" \
      -v type_single="$RGV_FMT_TYPE_SINGLE" \
      -v type_album="$RGV_FMT_TYPE_ALBUM" \
      -v type_ep="$RGV_FMT_TYPE_EP" \
      -v type_broadcast="$RGV_FMT_TYPE_BROADCAST" \
      -v type_other="$RGV_FMT_TYPE_OTHER" \
      -v type_unknown="$RGV_FMT_TYPE_UNKNOWN" \
      -v hassecondary_yes="$RGV_FMT_HASSECONDARY_YES" \
      -v hassecondary_no="$RGV_FMT_HASSECONDARY_NO" \
      -v fmtsecondary="$RGV_FMT_SECONDARY" \
      -v secondary_compilation="$RGV_FMT_SECONDARY_COMPILATION" \
      -v secondary_soundtrack="$RGV_FMT_SECONDARY_SOUNDTRACK" \
      -v secondary_spokenword="$RGV_FMT_SECONDARY_SPOKENWORD" \
      -v secondary_interview="$RGV_FMT_SECONDARY_INTERVIEW" \
      -v secondary_audiobook="$RGV_FMT_SECONDARY_AUDIOBOOK" \
      -v secondary_audiodrama="$RGV_FMT_SECONDARY_AUDIODRAMA" \
      -v secondary_live="$RGV_FMT_SECONDARY_LIVE" \
      -v secondary_remix="$RGV_FMT_SECONDARY_REMIX" \
      -v secondary_djmix="$RGV_FMT_SECONDARY_DJMIX" \
      -v secondary_mixtape="$RGV_FMT_SECONDARY_MIXTAPE" \
      -v secondary_demo="$RGV_FMT_SECONDARY_DEMO" \
      -v secondary_fieldrec="$RGV_FMT_SECONDARY_FIELDREC" \
      -v fmttitle="$RGV_FMT_TITLE" \
      -v fmtartist="$RGV_FMT_ARTIST" \
      -v fmtyear="$RGV_FMT_YEAR" \
      "$AWK_RELEASEGROUPS" |
    column -t -s "$(printf '\t')" -R "$RGV_FMT_RIGHTALIGN" -l "$RGV_FMT_CNT" |
    sort_list "$s"
}

# Themed awk script to generate release-group header
awk_releasegroup_header() {
  cat |
    awk \
      -F "\t" \
      -v flagfile="${LOCALDATA_RELEASEGROUPS:-}" \
      -v format="$HEADER_RG_FMT" \
      -v flag_local="$HEADER_RG_FMT_FLAG_LOCAL" \
      -v flag_nolocal="$HEADER_RG_FMT_FLAG_NO_LOCAL" \
      -v type_single="$HEADER_RG_FMT_TYPE_SINGLE" \
      -v type_album="$HEADER_RG_FMT_TYPE_ALBUM" \
      -v type_ep="$HEADER_RG_FMT_TYPE_EP" \
      -v type_broadcast="$HEADER_RG_FMT_TYPE_BROADCAST" \
      -v type_other="$HEADER_RG_FMT_TYPE_OTHER" \
      -v type_unknown="$HEADER_RG_FMT_TYPE_UNKNOWN" \
      -v hassecondary_yes="$HEADER_RG_FMT_HASSECONDARY_YES" \
      -v hassecondary_no="$HEADER_RG_FMT_HASSECONDARY_NO" \
      -v fmtsecondary="$HEADER_RG_FMT_SECONDARY" \
      -v secondary_soundtrack="$HEADER_RG_FMT_SECONDARY_SOUNDTRACK" \
      -v secondary_spokenword="$HEADER_RG_FMT_SECONDARY_SPOKENWORD" \
      -v secondary_interview="$HEADER_RG_FMT_SECONDARY_INTERVIEW" \
      -v secondary_audiobook="$HEADER_RG_FMT_SECONDARY_AUDIOBOOK" \
      -v secondary_audiodrama="$HEADER_RG_FMT_SECONDARY_AUDIODRAMA" \
      -v secondary_live="$HEADER_RG_FMT_SECONDARY_LIVE" \
      -v secondary_remix="$HEADER_RG_FMT_SECONDARY_REMIX" \
      -v secondary_djmix="$HEADER_RG_FMT_SECONDARY_DJMIX" \
      -v secondary_mixtape="$HEADER_RG_FMT_SECONDARY_MIXTAPE" \
      -v secondary_demo="$HEADER_RG_FMT_SECONDARY_DEMO" \
      -v secondary_fieldrec="$HEADER_RG_FMT_SECONDARY_FIELDREC" \
      -v fmttitle="$HEADER_RG_FMT_TITLE" \
      -v fmtartist="$HEADER_RG_FMT_ARTIST" \
      -v fmtyear="$HEADER_RG_FMT_YEAR" \
      "$AWK_RELEASEGROUPS" |
    column -t -s "$(printf '\t')" -R "$HEADER_RG_FMT_RIGHTALIGN" -l "$HEADER_RG_FMT_CNT" |
    cut -d "$(printf '\t')" -f 1
}

# Themed awk script to generate list of releases
#
# @argument $1: MusicBrainz release-group ID (optional)
# @argument $2: Title of release group (optional)
# @argument $3: Artist credit name of release group
awk_releases() {
  cat |
    awk \
      -F "\t" \
      -v releasegroupid="${1:-}" \
      -v origtitle="${2:-}" \
      -v origartist="${3:-}" \
      -v flagfile="${LOCALDATA_RELEASES:-}" \
      -v format="$RV_FMT" \
      -v flag_local="$RV_FMT_FLAG_LOCAL" \
      -v flag_nolocal="$RV_FMT_FLAG_NO_LOCAL" \
      -v status_official="$RV_FMT_STATUS_OFFICIAL" \
      -v status_promo="$RV_FMT_STATUS_PROMO" \
      -v status_bootleg="$RV_FMT_STATUS_BOOTLEG" \
      -v status_pseudo="$RV_FMT_STATUS_PSEUDO" \
      -v status_withdrawn="$RV_FMT_STATUS_WITHDRAWN" \
      -v status_expunged="$RV_FMT_STATUS_EXPUNGED" \
      -v status_cancelled="$RV_FMT_STATUS_CANCELLED" \
      -v status_unknown="$RV_FMT_STATUS_UNKNOWN" \
      -v fmttracks="$RV_FMT_TRACKS" \
      -v fmtmedia="$RV_FMT_MEDIA" \
      -v fmtyear="$RV_FMT_YEAR" \
      -v fmtcountry="$RV_FMT_COUNTRY" \
      -v fmtlabel="$RV_FMT_LABEL" \
      -v fmttitle="$RV_FMT_TITLE" \
      -v fmtartist="$RV_FMT_ARTIST" \
      "$AWK_RELEASES" |
    column -t -s "$(printf '\t')" -R "$RV_FMT_RIGHTALIGN" -l "$RV_FMT_CNT" |
    sort -t "$(printf '\t')" -k 2,2
}

# Themed awk script to generate release header
awk_release_header() {
  cat |
    awk \
      -F "\t" \
      -v flagfile="${LOCALDATA_RELEASES:-}" \
      -v format="$HEADER_R_FMT" \
      -v flag_local="$HEADER_R_FMT_FLAG_LOCAL" \
      -v flag_nolocal="$HEADER_R_FMT_FLAG_NO_LOCAL" \
      -v status_official="$HEADER_R_FMT_STATUS_OFFICIAL" \
      -v status_promo="$HEADER_R_FMT_STATUS_PROMO" \
      -v status_bootleg="$HEADER_R_FMT_STATUS_BOOTLEG" \
      -v status_pseudo="$HEADER_R_FMT_STATUS_PSEUDO" \
      -v status_withdrawn="$HEADER_R_FMT_STATUS_WITHDRAWN" \
      -v status_expunged="$HEADER_R_FMT_STATUS_EXPUNGED" \
      -v status_cancelled="$HEADER_R_FMT_STATUS_CANCELLED" \
      -v status_unknown="$HEADER_R_FMT_STATUS_UNKNOWN" \
      -v fmttracks="$HEADER_R_FMT_TRACKS" \
      -v fmtmedia="$HEADER_R_FMT_MEDIA" \
      -v fmtyear="$HEADER_R_FMT_YEAR" \
      -v fmtcountry="$HEADER_R_FMT_COUNTRY" \
      -v fmtlabel="$HEADER_R_FMT_LABEL" \
      -v fmttitle="$HEADER_R_FMT_TITLE" \
      -v fmtartist="$HEADER_R_FMT_ARTIST" \
      "$AWK_RELEASES" |
    column -t -s "$(printf '\t')" -R "$HEADER_R_FMT_RIGHTALIGN" -l "$HEADER_R_FMT_CNT" |
    cut -d "$(printf '\t')" -f 1
}

# Themed awk script to generate list of tracks
#
# @argument $1: Path to file with MusicBrainz track IDs "tab" decoration file
#               of locally playable audio tracks (optional)
awk_recordings() {
  cat |
    awk \
      -F "\t" \
      -v flagfile="${1:-}" \
      -v format="$REC_FMT" \
      -v flag_local="$REC_FMT_FLAG_LOCAL" \
      -v flag_nolocal="$REC_FMT_FLAG_NO_LOCAL" \
      -v fmtmedia="$REC_FMT_MEDIA" \
      -v fmtnr="$REC_FMT_NR" \
      -v fmttitle="$REC_FMT_TITLE" \
      -v fmtartist="$REC_FMT_ARTIST" \
      -v fmtduration="$REC_FMT_DURATION" \
      "$AWK_RECORDINGS" |
    column -t -s "$(printf '\t')" -R "$REC_FMT_RIGHTALIGN" -l "$REC_FMT_CNT"
}

# Themed awk script to generate list of tracks for playlist view
awk_playlist() {
  cat |
    awk \
      -F "\t" \
      -v format="$PLYLST_FMT" \
      -v playing_yes="$PLYLST_FMT_PLAYING_YES" \
      -v playing_no="$PLYLST_FMT_PLAYING_NO" \
      -v fmttitle="$PLYLST_FMT_TITLE" \
      -v fmtartist="$PLYLST_FMT_ARTIST" \
      -v fmtduration="$PLYLST_FMT_DURATION" \
      "$AWK_RECORDINGS" |
    column -t -s "$(printf '\t')" -R "$PLYLST_FMT_RIGHTALIGN" -l "$PLYLST_FMT_CNT"
}

# Themed awk scrtip to preview single-person artist
#
# @argument  $1: Artist name
# @argument  $2: Artist sort name
# @argument  $3: Artist disambiguation
# @argument  $4: Artist biography
# @argument  $5: Artist aliases
# @argument  $6: Birthdate
# @argument  $7: Birth place
# @argument  $8: Date when died
# @argument  $9: Place where died
# @argument $10: Artist urls
awk_preview_artist_person() {
  awk \
    -v name="${1:-}" \
    -v sortname="${2:-}" \
    -v disamb="${3:-}" \
    -v bio="${4:-}" \
    -v alias="${5:-}" \
    -v startdate="${6:-}" \
    -v startplace="${7:-}" \
    -v enddate="${8:-}" \
    -v endplace="${9:-}" \
    -v url="${10:-}" \
    -v format="$PREVIEW_ARTIST_PERSON_FMT" \
    -v fmtname="$PREVIEW_ARTIST_PERSON_NAME" \
    -v fmtsortname="$PREVIEW_ARTIST_PERSON_SORTNAME" \
    -v fmtbio="$PREVIEW_ARTIST_PERSON_BIO" \
    -v fmtdisamb="$PREVIEW_ARTIST_PERSON_DISAMB" \
    -v fmtalias="$PREVIEW_ARTIST_PERSON_ALIAS" \
    -v join_alias="$PREVIEW_ARTIST_PERSON_ALIAS_JOIN" \
    -v format_start="$PREVIEW_ARTIST_PERSON_START_FMT" \
    -v fmtstart="$PREVIEW_ARTIST_PERSON_START" \
    -v fmtstart_startdate="$PREVIEW_ARTIST_PERSON_START_STARTDATE" \
    -v fmtstart_startplace="$PREVIEW_ARTIST_PERSON_START_STARTPLACE" \
    -v format_end="$PREVIEW_ARTIST_PERSON_END_FMT" \
    -v fmtend="$PREVIEW_ARTIST_PERSON_END" \
    -v fmtend_enddate="$PREVIEW_ARTIST_PERSON_END_ENDDATE" \
    -v fmtend_endplace="$PREVIEW_ARTIST_PERSON_END_ENDPLACE" \
    -v fmturl="$PREVIEW_ARTIST_PERSON_URL" \
    -v format_url="$PREVIEW_ARTIST_PERSON_URL_FMT" \
    -v join_url="$PREVIEW_ARTIST_PERSON_URL_JOIN" \
    -v fmturl_urlindex="$PREVIEW_ARTIST_PERSON_URL_URLINDEX" \
    -v fmturl_urlname="$PREVIEW_ARTIST_PERSON_URL_URLNAME" \
    -v fmturl_urllink="$PREVIEW_ARTIST_PERSON_URL_URLLINK" \
    "$AWK_PREVIEW_ARTIST"
}

# Themed awk scrtip to preview artist group
#
# @argument  $1: Artist name
# @argument  $2: Artist sort name
# @argument  $3: Artist disambiguation
# @argument  $4: Artist biography
# @argument  $5: Artist aliases
# @argument  $6: Founding date
# @argument  $7: Founding place
# @argument  $8: Date when dissolved
# @argument  $9: Place where dissovled
# @argument $10: Artist urls
awk_preview_artist_group() {
  awk \
    -v name="${1:-}" \
    -v sortname="${2:-}" \
    -v disamb="${3:-}" \
    -v bio="${4:-}" \
    -v alias="${5:-}" \
    -v startdate="${6:-}" \
    -v startplace="${7:-}" \
    -v enddate="${8:-}" \
    -v endplace="${9:-}" \
    -v url="${10:-}" \
    -v format="$PREVIEW_ARTIST_GROUP_FMT" \
    -v fmtname="$PREVIEW_ARTIST_GROUP_NAME" \
    -v fmtsortname="$PREVIEW_ARTIST_GROUP_SORTNAME" \
    -v fmtbio="$PREVIEW_ARTIST_GROUP_BIO" \
    -v fmtdisamb="$PREVIEW_ARTIST_GROUP_DISAMB" \
    -v fmtalias="$PREVIEW_ARTIST_GROUP_ALIAS" \
    -v join_alias="$PREVIEW_ARTIST_GROUP_ALIAS_JOIN" \
    -v format_start="$PREVIEW_ARTIST_GROUP_START_FMT" \
    -v fmtstart="$PREVIEW_ARTIST_GROUP_START" \
    -v fmtstart_startdate="$PREVIEW_ARTIST_GROUP_START_STARTDATE" \
    -v fmtstart_startplace="$PREVIEW_ARTIST_GROUP_START_STARTPLACE" \
    -v format_end="$PREVIEW_ARTIST_GROUP_END_FMT" \
    -v fmtend="$PREVIEW_ARTIST_GROUP_END" \
    -v fmtend_enddate="$PREVIEW_ARTIST_GROUP_END_ENDDATE" \
    -v fmtend_endplace="$PREVIEW_ARTIST_GROUP_END_ENDPLACE" \
    -v fmturl="$PREVIEW_ARTIST_GROUP_URL" \
    -v format_url="$PREVIEW_ARTIST_GROUP_URL_FMT" \
    -v join_url="$PREVIEW_ARTIST_GROUP_URL_JOIN" \
    -v fmturl_urlindex="$PREVIEW_ARTIST_GROUP_URL_URLINDEX" \
    -v fmturl_urlname="$PREVIEW_ARTIST_GROUP_URL_URLNAME" \
    -v fmturl_urllink="$PREVIEW_ARTIST_GROUP_URL_URLLINK" \
    "$AWK_PREVIEW_ARTIST"
}
