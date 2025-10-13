# List artists
#
# parameters:
# flagfile: path to a file with a MusicBrainz artist ID per line (optional)
# sortby:   sort selector (see `src/sh/awk.sh`)
#
# theme parameters (see `src/sh/awk.sh` and `src/sh/theme.sh`)
# format            Format string
# flag_local        Flag for locally available music
# flag_nolocal      Flag for locally unavailable music
# type_person       Single-person artist indicator
# type_group        Artist group indicator
# fmtname           `printf` expression to transform artist names
# fmtdisambiguation `printf` expression to transform disambiguation
#
# This awk program takes as input a sequence of lines where the first item is
# the MusicBrainz artist ID, the second item is the type of the artist
# ("Person" or "Group"), the third item is the name, the forth item is the sort
# string, and the fifth item is a disambiguation string.
#
# The output of this script is a sequence of tab-delimited lines. The first
# `AV_FMT_CNT` lines are those that will be displayed to the user. The following lines are
# - Field intended for sorting
# - constant 0 (field intended for parent id)
# - MusicBrainz artist ID
# - 1 if some music of that artist is locally available

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
  name = $3 ? sprintf(fmtname, escape($3)) : ""
  sort = 0
  if (sortby) {
    sort = sortby == "sort-artist-sortname" ? $4 : $3
  }
  disa = $5 ? sprintf(fmtdisambiguation, escape($5)) : ""
  # Transform data and fill placeholders
  if (flagged[mbid])
    gsub("<<flag>>", flag_local, line)
  else
    gsub("<<flag>>", flag_nolocal, line)
  if (type == "Group")
    gsub("<<type>>", type_group, line)
  else
    gsub("<<type>>", type_person, line)
  gsub("<<name>>", name, line)
  gsub("<<disambiguation>>", disa, line)
  print line, sort, "0", mbid, flagged[mbid]
}
