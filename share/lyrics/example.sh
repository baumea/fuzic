#!/bin/sh

# Example script for `fuzic` to display the lyrics of a track. This script
# reads from stdin a JSON string and stores it in the variable `j`. The
# variable `tj` contains the JSON string of the track.
j="$(cat)"
tj="$(echo "$j" | jq -r '.trackid as $tid | .release.media[].tracks[] | select(.id == $tid)')"
# The following four variables are self-explanatory:
track_name="$(echo "$tj" | jq -r '.title')"
artist_name="$(echo "$tj" | jq -r '."artist-credit" | map([.name, .joinphrase] | join("")) | join("")')"
album_name="$(echo "$j" | jq -r '.release.title')"
duration="$(echo "$tj" | jq -r '.length / 1000 | round')"
# Now, you may call an API to fetch the lyrics for this track,
#
# curl \
#   --get \
#   --silent \
#   --data-urlencode "track_name=$track_name" \
#   --data-urlencode "artist_name=$artist_name" \
#   --data-urlencode "album_name=$album_name" \
#   --data-urlencode "duration=$duration" \
#   "$URL"
#
# or simply print a template to write the lyrics yourself:
printf "Lyrics '%s' by '%s' (album: %s, duration: %s seconds)\n" "$track_name" "$artist_name" "$album_name" "$duration"
