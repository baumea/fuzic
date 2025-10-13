# Load the tools required for this application. The tools are preset with
# default command-line arguments.
#
# List of tools:
# - fzf:   in order to display, search, and navigate lists
# - curl:  for API access
# - jq:    to parse json files
# - mpv:   music player
# - socat: to communicate with the socket mpv is bound to
# - xsel:  to copy content to the clipboard (not necessary)
if [ ! "${TOOLS_LOADED:-}" ]; then
  if command -v "fzf" >/dev/null; then
    FZF="fzf --black --ansi --cycle --tiebreak=chunk,index"
  else
    err "Did not find the command-line fuzzy finder fzf."
    exit 1
  fi
  export FZF

  if command -v "curl" >/dev/null; then
    CURL="curl --silent"
  else
    err "Did not find curl."
    exit 1
  fi
  export CURL

  if command -v "jq" >/dev/null; then
    JQ="jq -r --compact-output"
  else
    err "Did not find jq."
    exit 1
  fi
  export JQ

  if command -v "mpv" >/dev/null; then
    MPV="mpv"
  else
    err "Did not find mpv."
    exit 1
  fi
  export MPV

  if command -v "socat" >/dev/null; then
    SOCAT="socat"
  else
    err "Did not find socat."
    exit 1
  fi
  export SOCAT

  command -v "ffprobe" >/dev/null && FFPROBE="ffprobe" || FFPROBE=""
  export FFPROBE

  command -v "xsel" >/dev/null && CLIP="xsel" || CLIP="true"
  export CLIP

  export TOOLS_LOADED=1
fi
