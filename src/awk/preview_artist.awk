# Preview artists
#
# parameters:
# name       | Artist name
# sortname   | Artist sort name
# disamb     | Artist disambiguation string
# bio        | Artist biography
# alias      | Tab-delimited string of aliases
# startdate  | Date where artist is born, group is founded
# startplace | Place where artist is born, group is founded
# enddate    | Date where artist died, group dissolved
# endplace   | Place where artist died, group dissolved
# url        | Tab-delimited string of ;-delimited pairs (url name, url link)
#
# theme parameters (see `src/sh/theme.sh`)
# format              | Format string
# fmtname             | `printf` expression to transform artist names
# fmtsortname         | `printf` expression to transform artist sortnames
# fmtbio              | `printf` expression to transform disambiguation
# fmtdisamb           | `printf` expression to transform disambiguation
# fmtalias            | `printf` expression to transform alias
# join_alias          | `printf` expression to join one alias to the previously constructed aliases
# format_start        | Format string for born/founded string
# fmtstart            | `printf` expression for born/founded
# fmtstart_startdate  | `printf` expression to transform the start date
# fmtstart_startplace | `printf` expression to transform the start place
# format_end          | Format string for died/dissolved string
# fmtend              | `printf` expression for died/dissolved
# fmtend_enddate      | `printf` expression to transform the end date
# fmtend_endplace     | `printf` expression to transform the end place
# fmturl              | `printf` expression for links
# format_url          | Format string for url string
# join_url            | `printf` expression to join one url to all others
# fmturl_urlindex     | `printf` expression for URL index
# fmturl_urlname      | `printf` expression for URL name
# fmturl_urllink      | `printf` expression for URL link (address)
#
# This awk program takes no input from stdin and outputs the preview text for
# the artist.

@include "lib/awk/lib.awk"

BEGIN {
  name = name ? sprintf(fmtname, escape(name)) : ""
  sortname = sortname ? sprintf(fmtsortname, escape(sortname)) : ""
  disamb = disamb ? sprintf(fmtdisamb, escape(disamb)) : ""
  bio = bio ? sprintf(fmtbio, escape(bio)) : ""
  # Alias
  if (alias) {
    split(alias, a, "\t")
    for (i in a) {
      alias = i == 1 ? a[i] : sprintf(join_alias, alias, a[i])
    }
    alias = sprintf(fmtalias, escape(alias))
  }
  # Start
  startdate = startdate ? sprintf(fmtstart_startdate, escape(startdate)) : ""
  startplace = startplace ? sprintf(fmtstart_startplace, escape(startplace)) : ""
  if (startdate || startplace) {
    gsub("<<startdate>>", startdate, format_start)
    gsub("<<startplace>>", startplace, format_start)
    start = sprintf(fmtstart, escape(format_start))
  }
  # End
  enddate = enddate ? sprintf(fmtend_enddate, escape(enddate)) : ""
  endplace = endplace ? sprintf(fmtend_endplace, escape(endplace)) : ""
  if (enddate || endplace) {
    gsub("<<enddate>>", enddate, format_end)
    gsub("<<endplace>>", endplace, format_end)
    end = sprintf(fmtend, escape(format_end))
  }
  # Links
  if (url) {
    split(url, a, "\t")
    for (i in a) {
      urlindex = sprintf(fmturl_urlindex, i)
      pos = index(a[i], ";")
      urlname = substr(a[i], 1, pos - 1)
      urlname = urlname ? sprintf(fmturl_urlname, escape(urlname)) : ""
      urllink = substr(a[i], pos + 1)
      urllink = urllink ? sprintf(fmturl_urllink, escape(urllink)) : ""
      urlentry = format_url
      gsub("<<urlindex>>", urlindex, urlentry)
      gsub("<<urlname>>", urlname, urlentry)
      gsub("<<urllink>>", urllink, urlentry)
      url = i == 1 ? urlentry : sprintf(join_url, url, urlentry)
    }
    url = sprintf(fmturl, escape(url))
  }
  # Combine all and print
  gsub("<<name>>", name, format)
  gsub("<<sortname>>", sortname, format)
  gsub("<<disambiguation>>", disamb, format)
  gsub("<<bio>>", bio, format)
  gsub("<<alias>>", alias, format)
  gsub("<<start>>", start, format)
  gsub("<<end>>", end, format)
  gsub("<<url>>", url, format)
  print format
}
