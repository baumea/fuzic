# List release groups
#
# flagfile         path to a file with a MusicBrainz release ID per line,
#                  tab-delimited from the path to the decoration file
#                  (optional)
# origtitle        Title of release group (optional)
# origartist       Artist credit of release group (optional)
# releasegroupid   MusicBrainz release-group ID (optional)
#
# theme parameters (see `src/sh/awk.sh` and `src/sh/theme.sh`)
# format             Format string
# flag_local         Flag for locally available music
# flag_nolocal       Flag for locally unavailable music
# status_official    Official release
# status_promo       Promotional release
# status_bootleg     Bootleg release
# status_pseudo      Pseudo release
# status_withdrawn   Withdrawn
# status_expunged    Expunged release
# status_cancelled   Cancelled release
# status_unknown     Status of release is not specified
# fmttracks          `printf` expression for track number
# fmtmedia           `printf` expression for media number
# fmtyear            `printf` expression for release year
# fmtcountry         `printf` expression for release country
# fmtlabel           `printf` expression for label
# fmttitle           `printf` expression for release title
# fmtartist          `printf` expression for release artist credits
#
# The input to this awk program is a sequence of lines containing the following
# fields:
# Field  1: MusicBrainz ID of the release
# Field  2: Release status
# Field  3: Release date
# Field  4: Number of cover-art images
# Field  5: Label string (', '-delimited)
# Field  6: Total number of tracks
# Field  7: Format (', '-delimited)
# Field  8: Release country
# Field  9: Release title
# Field 10: Artist as credited
#
# The output of this script is a sequence of tab-delimited lines. The first
# `RV_FMT_CNT` fields are those that will be displayed to the user. The
# following fields are
# - sort key (release year)
# - MusicBrainz release-group ID if specified, else the constant "0"
# - MusicBrainz release ID
# - Path to decoration file if some music of that release is locally available

@include "lib/awk/lib.awk"

BEGIN {
  OFS="\t"
  flagged[0] = 0
  delete flagged[0]
  if (flagfile) {
    while ((getline < flagfile) == 1)
      flagged[$1] = $2
    close(flagfile)
  }
}
{
  # Read data
  line = format
  mbid = $1
  status = $2
  year = $3 ? sprintf(fmtyear, substr($3, 1, 4) + 0) : ""
  covercount = $4
  label = $5 ? sprintf(fmtlabel, escape($5)) : ""
  tracks = $6 ? sprintf(fmttracks, escape($6)) : ""
  media = $7 ? sprintf(fmtmedia, escape($7)) : ""
  country = $8 ? sprintf(fmtcountry, escape($8)) : ""
  title = escape($9) != origtitle ? sprintf(fmttitle, escape($9)) : ""
  artist = escape($10) != origartist ? sprintf(fmtartist, escape($10)) : ""
  sort = $3 + 0
  # Transform data and fill placeholders
  if (flagged[mbid])
    gsub("<<flag>>", flag_local, line)
  else
    gsub("<<flag>>", flag_nolocal, line)
  switch (status) {
    case "Official": s = status_official; break
    case "Promotion": s = status_promotion; break
    case "Bootleg": s = status_bootleg; break
    case "Pseudo-release": s = status_pseudo; break
    case "Withdrawn": s = status_withdrawn; break
    case "Expunged": s = status_expunged; break
    case "Cancelled": s = status_cancelled; break
    default: s = status_unknown
  }
  gsub("<<status>>", s, line)
  gsub("<<tracks>>", tracks, line)
  gsub("<<media>>", media, line)
  gsub("<<year>>", year, line)
  gsub("<<country>>", country, line)
  gsub("<<label>>", label, line)
  gsub("<<title>>", title, line)
  gsub("<<artist>>", artist, line)
  print line, sort, releasegroupid ? releasegroupid : "0", mbid, flagged[mbid] ? flagged[mbid] : ""
}
