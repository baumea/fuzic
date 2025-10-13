# List release groups
#
# flagfile   Path to a file with a MusicBrainz track ID per line, tab-delimited
#            from the path to the decoration file (optional)
#
# theme parameters (see `src/sh/awk.sh` and `src/sh/theme.sh`)
# format         Format string
# flag_local     Flag for locally available music
# flag_nolocal   Flag for locally unavailable music
# playing_yes    Mark for currently playing track
# playing_no     Mark for currently not playing track
# fmtmedia       `printf` expression for media identifier
# fmtnr          `printf` expression for track number
# fmttitle       `printf` expression for title
# fmtartist      `printf` expression for artist
# fmtduration    `printf` expression track duration
#
# The input to this awk program is a sequence of lines containing the following fields:
# Field  1: The MusicBrainz ID of the release this track belongs to
# Field  2: MusicBrainz ID of this track
# Field  3: Number of media of this release
# Field  4: Medium number of this track within the release
# Field  5: Track number of this track within the medium
# Field  6: Duration of this track in milliseconds
# Field  7: Title of this track
# Field  8: Artist of this track
# Field  9: Path to decoration file of this release
# Field 10: Empty outside of playlists, else "yes" if the track is currently
#           being played, and something else otherwise.
#
# The output of this script is a sequence of tab-delimited lines. The first
# `REC_FMT_CNT` fields are those that will be displayed to the user. The
# following fields are
# - Constant 0 (we will not sort)
# - MusicBrainz release ID if specified, else the constant "0"
# - MusicBrainz track ID
# - Path to decoration file if some music of that release is locally available

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
  releaseid = $1
  mbid = $2
  medtot = $3 + 0
  med = ($4 && medtot >= 2) ? sprintf(fmtmedia, escape($4)) : ""
  nr = $5 ? sprintf(fmtnr, escape($5)) : ""
  dur = $6
  # Parse duration
  if (dur) {
    dur = int(dur / 1000)
    dh = int(dur / 3600)
    dur = dur % 3600
    dm = int(dur / 60)
    ds = dur % 60
    if (ds <= 9)
      ds = "0"ds
    if (dh && dm <= 9)
      dm = "0"dm
    dur = dh ? dh":"dm":"ds : dm":"ds
  } else {
    dur = "??:??"
  }
  dur = sprintf(fmtduration, dur)
  title = $7 ? sprintf(fmttitle, escape($7)) : ""
  artist = $8 ? sprintf(fmtartist, escape($8)) : ""
  current = $10
  if (current || (flagged[mbid] && $9))
    flagged[mbid] = $9
  # Transform data and fill placeholders
  if (flagged[mbid])
    gsub("<<flag>>", flag_local, line)
  else
    gsub("<<flag>>", flag_nolocal, line)
  gsub("<<media>>", med, line)
  gsub("<<nr>>", nr, line)
  gsub("<<title>>", title, line)
  gsub("<<artist>>", artist, line)
  gsub("<<duration>>", dur, line)
  if (current) {
    if (current == "yes")
      gsub("<<playing>>", playing_yes, line)
    else
      gsub("<<playing>>", playing_no, line)
  }
  print line, "0", releaseid ? releaseid : "0", mbid, flagged[mbid] ? flagged[mbid] : ""
}
