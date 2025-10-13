# List release groups
#
# flagfile     path to a file with a MusicBrainz release-group ID per line (optional)
# sortby       sort selector (see `src/sh/awk.sh`)
# origartist   Artist name to compare release-groups (optional)
# artistid     MusicBrainz ID of the artist (optional)
#
# theme parameters (see `src/sh/awk.sh` and `src/sh/theme.sh`)
# format                 Format string
# flag_local             Flag for locally available music
# flag_nolocal           Flag for locally unavailable music
# type_single            Single 
# type_album             LP
# type_ep                EP
# type_broadcast         Broadcast
# type_other             Other type
# type_unknown           Type unknown
# hassecondary_yes       Release group has secondary type(s)
# hassecondary_no        Release group does not have any secondary type
# fmtsecondary           `printf` expression to display secondary type
# secondary_soundtrack   ...
# secondary_spokenword   ...
# secondary_interview    ...
# secondary_audiobook    ...
# secondary_audiodrama   ...
# secondary_live         ...
# secondary_remix        ...
# secondary_djmix        ...
# secondary_mixtape      ...
# secondary_demo         ...
# secondary_fieldrec    ... 
# fmttitle               `printf` expression to transform title
# fmtartist              `printf` expression to transform artist
# fmtyear                `printf` expression to transform year
#
# The input to this awk program is a sequence of lines containing the following
# fields:
# Field 1: The MusicBrainz ID of the release group
# Field 2: The primary type
# Field 3: A ;-delimited string of secondary types
# Field 4: The original release year
# Field 5: Title of the release group
# Field 6: The artist as credited
#
# The output of this script is a sequence of tab-delimited lines. The first
# `RGV_FMT_CNT` fields are those that will be displayed to the user. The
# following fields are
# - sort key (release year)
# - MusicBrainz artist ID if specified, else the constant "0"
# - MusicBrainz release-group ID
# - 1 if some music of that release group is locally available

@include "lib/awk/lib.awk"

BEGIN {
  OFS="\t"
  flagged[0] = 0
  delete flagged[0]
  if (flagfile) {
    while ((getline < flagfile) == 1)
      flagged[$1] = 1
    close(flagfile)
  }
}
{
  # Read data
  line = format
  mbid = $1
  type = $2
  sectype = $3
  year = $4 ? sprintf(fmtyear, substr($4, 1, 4) + 0) : ""
  title = $5 ? sprintf(fmttitle, escape($5)) : ""
  artist = escape($6) != origartist ? sprintf(fmtartist, escape($6)) : ""
  sort = $4 ? -$4 : 0
  sort = 0
  if (sortby) {
    sort = sortby == "sort-rg-year" ? ($4 ? -$4 : 0) : $5
  }
  # Transform data and fill placeholders
  if (flagged[mbid])
    gsub("<<flag>>", flag_local, line)
  else
    gsub("<<flag>>", flag_nolocal, line)
  switch (type) {
    case "Single": t = type_single; break
    case "Album": t = type_album; break
    case "EP": t = type_ep; break;
    case "Broadcast": t = type_broadcast; break
    case "Other": t = type_other; break
    default: t = type_unknown; break
  }
  gsub("<<type>>", t, line)
  if (sectype)
    gsub("<<hassecondary>>", hassecondary_yes, line)
  else
    gsub("<<hassecondary>>", hassecondary_no, line)
  gsub("<<title>>", title, line)
  gsub("<<artist>>", artist, line)
  gsub("<<year>>", year, line)
  t = ""
  s = ""
  split(sectype, a, ";")
  for (i in a) {
    switch (a[i]) {
      case "Compilation": t = secondary_compilation; break
      case "Soundtrack": t = secondary_soundtrack; break
      case "Spokenword": t = secondary_spokenword; break
      case "Interview": t = secondary_interview; break
      case "Audiobook": t = secondary_audiobook; break
      case "Audio drama": t = secondary_audiodrama; break
      case "Live": t = secondary_live; break
      case "Remix": t = secondary_remix; break
      case "DJ-mix": t = secondary_djmix; break
      case "Mixtape/Street": t = secondary_mixtape; break
      case "Demo": t = secondary_demo; break
      case "Field recording": t = secondary_fieldrec; break
    }
    if (t)
      s = s ? s ", " t : t
  }
  s = s ? sprintf(fmtsecondary, s) : ""
  gsub("<<secondary>>", s, line)
  print line, sort, artistid ? artistid : "0", mbid, flagged[mbid]
}
