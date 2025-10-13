# Playback tools and helper
#
# The methods to control the mpv instance are in `src/sh/mpv.sh`. Here,
# a higher-level playback functionality is provided.

# Available playback commands
if [ ! "${PLAYBACK_LOADED:-}" ]; then
  PLAYBACK_CMD_PLAY="play"
  PLAYBACK_CMD_QUEUE="queue"
  PLAYBACK_CMD_QUEUE_NEXT="queue-next"
  PLAYBACK_CMD_TOGGLE_PLAYBACK="toggle"
  PLAYBACK_CMD_PLAY_NEXT="next"
  PLAYBACK_CMD_PLAY_PREV="prev"
  PLAYBACK_CMD_SEEK_FORWARD="seekf"
  PLAYBACK_CMD_SEEK_BACKWARD="seekb"
  export PLAYBACK_CMD_PLAY PLAYBACK_CMD_QUEUE PLAYBACK_CMD_QUEUE_NEXT \
    PLAYBACK_CMD_TOGGLE_PLAYBACK PLAYBACK_CMD_PLAY_NEXT \
    PLAYBACK_CMD_PLAY_PREV PLAYBACK_CMD_SEEK_FORWARD PLAYBACK_CMD_SEEK_BACKWARD

  export PLAYBACK_LOADED=1
fi

# Obtain playback command from key press
#
# @argument $1: key
__playback_cmd_from_key() {
  key=$1
  case ",$KEYS_PLAY," in *",$key,"*) echo "$PLAYBACK_CMD_PLAY" && return ;; esac
  case ",$KEYS_N_PLAY," in *",$key,"*) echo "$PLAYBACK_CMD_PLAY" && return ;; esac
  case ",$KEYS_QUEUE," in *",$key,"*) echo "$PLAYBACK_CMD_QUEUE" && return ;; esac
  case ",$KEYS_N_QUEUE," in *",$key,"*) echo "$PLAYBACK_CMD_QUEUE" && return ;; esac
  case ",$KEYS_QUEUE_NEXT," in *",$key,"*) echo "$PLAYBACK_CMD_QUEUE_NEXT" && return ;; esac
  case ",$KEYS_N_QUEUE_NEXT," in *",$key,"*) echo "$PLAYBACK_CMD_QUEUE_NEXT" && return ;; esac
  case ",$KEYS_TOGGLE_PLAYBACK," in *",$key,"*) echo "$PLAYBACK_CMD_TOGGLE_PLAYBACK" && return ;; esac
  case ",$KEYS_N_TOGGLE_PLAYBACK," in *",$key,"*) echo "$PLAYBACK_CMD_TOGGLE_PLAYBACK" && return ;; esac
  case ",$KEYS_PLAY_NEXT," in *",$key,"*) echo "$PLAYBACK_CMD_PLAY_NEXT" && return ;; esac
  case ",$KEYS_N_PLAY_NEXT," in *",$key,"*) echo "$PLAYBACK_CMD_PLAY_NEXT" && return ;; esac
  case ",$KEYS_PLAY_PREV," in *",$key,"*) echo "$PLAYBACK_CMD_PLAY_PREV" && return ;; esac
  case ",$KEYS_N_PLAY_PREV," in *",$key,"*) echo "$PLAYBACK_CMD_PLAY_PREV" && return ;; esac
  case ",$KEYS_SEEK_FORWARD," in *",$key,"*) echo "$PLAYBACK_CMD_SEEK_FORWARD" && return ;; esac
  case ",$KEYS_N_SEEK_FORWARD," in *",$key,"*) echo "$PLAYBACK_CMD_SEEK_FORWARD" && return ;; esac
  case ",$KEYS_SEEK_BACKWARD," in *",$key,"*) echo "$PLAYBACK_CMD_SEEK_BACKWARD" && return ;; esac
  case ",$KEYS_N_SEEK_BACKWARD," in *",$key,"*) echo "$PLAYBACK_CMD_SEEK_BACKWARD" && return ;; esac
}

# Main playback method
#
# @argument $1: view
# @argument $2: MusicBrainz ID of current object
# @argument $3: MusicBrainz ID of selected object
# @argument $4: Path to decoration file
#
# This option controls the mpv instance via a key pressed in fzf. The key
# pressed is stored in the environment variable FZF_KEY and is resolved to
# the playback command through the method `__playback_cmd_from_key`.
playback() {
  view=${1:-}
  mbid_current="${2:-}"
  mbid="${3:-}"
  path="${4:-}"
  pbcmd=$(__playback_cmd_from_key "$FZF_KEY")
  case "$pbcmd" in
  "$PLAYBACK_CMD_PLAY")
    [ "$path" ] || exit 0
    case "$view" in
    "$VIEW_SEARCH_ARTIST" | "$VIEW_LIST_ARTISTS")
      list_releasegroups "$mbid" |
        while IFS= read -r rgline; do
          rgmbid="$(echo "$rgline" | cut -d "$(printf '\t')" -f 4)"
          rgpath="$(echo "$rgline" | cut -d "$(printf '\t')" -f 5)"
          [ "$rgpath" ] || continue
          [ "${queue:-}" ] || queue=""
          export queue
          list_releases "$rgmbid" |
            while IFS= read -r line; do
              rmbid="$(echo "$line" | cut -d "$(printf '\t')" -f 4)"
              rpath="$(echo "$line" | cut -d "$(printf '\t')" -f 5)"
              [ "$rpath" ] || continue
              if [ ! "$queue" ]; then
                generate_playlist "$rmbid" "$rpath" | mpv_play_list >/dev/null
                queue=1
              else
                generate_playlist "$rmbid" "$rpath" | mpv_queue_list >/dev/null
              fi
            done
          queue=1
        done
      ;;
    "$VIEW_ARTIST" | "$VIEW_SEARCH_ALBUM" | "$VIEW_LIST_ALBUMS")
      list_releases "$mbid" |
        while IFS= read -r line; do
          rmbid="$(echo "$line" | cut -d "$(printf '\t')" -f 4)"
          rpath="$(echo "$line" | cut -d "$(printf '\t')" -f 5)"
          [ "$rpath" ] || continue
          if [ ! "${queue:-}" ]; then
            generate_playlist "$rmbid" "$rpath" | mpv_play_list >/dev/null
            queue=1
          else
            generate_playlist "$rmbid" "$rpath" | mpv_queue_list >/dev/null
          fi
        done
      ;;
    "$VIEW_RELEASEGROUP") generate_playlist "$mbid" "$path" | mpv_play_list >/dev/null ;;
    "$VIEW_RELEASE") generate_playlist "$mbid_current" "$path" "$mbid" | mpv_play_list >/dev/null ;;
    "$VIEW_PLAYLIST") mpv_play_index $((FZF_POS - 1)) >/dev/null ;;
    esac
    ;;
  "$PLAYBACK_CMD_QUEUE")
    [ "$path" ] || exit 0
    case "$view" in
    "$VIEW_SEARCH_ARTIST" | "$VIEW_LIST_ARTISTS")
      list_releasegroups "$mbid" |
        while IFS= read -r rgline; do
          rgmbid="$(echo "$rgline" | cut -d "$(printf '\t')" -f 4)"
          rgpath="$(echo "$rgline" | cut -d "$(printf '\t')" -f 5)"
          [ "$rgpath" ] || continue
          list_releases "$rgmbid" |
            while IFS= read -r line; do
              rmbid="$(echo "$line" | cut -d "$(printf '\t')" -f 4)"
              rpath="$(echo "$line" | cut -d "$(printf '\t')" -f 5)"
              [ "$rpath" ] || continue
              generate_playlist "$rmbid" "$rpath" | mpv_queue_list >/dev/null
            done
        done
      ;;
    "$VIEW_ARTIST" | "$VIEW_SEARCH_ALBUM" | "$VIEW_LIST_ALBUMS")
      list_releases "$mbid" |
        while IFS= read -r line; do
          rmbid="$(echo "$line" | cut -d "$(printf '\t')" -f 4)"
          rpath="$(echo "$line" | cut -d "$(printf '\t')" -f 5)"
          [ "$rpath" ] || continue
          generate_playlist "$rmbid" "$rpath" | mpv_queue_list >/dev/null
        done
      ;;
    "$VIEW_RELEASEGROUP") generate_playlist "$mbid" "$path" | mpv_queue_list >/dev/null ;;
    "$VIEW_RELEASE") generate_playlist "$mbid_current" "$path" "$mbid" | mpv_queue_list >/dev/null ;;
    "$VIEW_PLAYLIST") generate_playlist "$mbid_current" "$path" "$mbid" | mpv_queue_list >/dev/null ;;
    esac
    ;;
  "$PLAYBACK_CMD_QUEUE_NEXT")
    [ "$path" ] || exit 0
    case "$view" in
    "$VIEW_SEARCH_ARTIST" | "$VIEW_LIST_ARTISTS")
      list_releasegroups "$mbid" |
        while IFS= read -r rgline; do
          rgmbid="$(echo "$rgline" | cut -d "$(printf '\t')" -f 4)"
          rgpath="$(echo "$rgline" | cut -d "$(printf '\t')" -f 5)"
          [ "$rgpath" ] || continue
          list_releases "$rgmbid" |
            while IFS= read -r line; do
              rmbid="$(echo "$line" | cut -d "$(printf '\t')" -f 4)"
              rpath="$(echo "$line" | cut -d "$(printf '\t')" -f 5)"
              [ "$rpath" ] || continue
              generate_playlist "$rmbid" "$rpath" | mpv_queue_next_list >/dev/null
            done
        done
      ;;
    "$VIEW_ARTIST" | "$VIEW_SEARCH_ALBUM" | "$VIEW_LIST_ALBUMS")
      list_releases "$mbid" |
        while IFS= read -r line; do
          rmbid="$(echo "$line" | cut -d "$(printf '\t')" -f 4)"
          rpath="$(echo "$line" | cut -d "$(printf '\t')" -f 5)"
          [ "$rpath" ] || continue
          generate_playlist "$rmbid" "$rpath" | mpv_queue_next_list >/dev/null
        done
      ;;
    "$VIEW_RELEASEGROUP") generate_playlist "$mbid" "$path" | mpv_queue_next_list >/dev/null ;;
    "$VIEW_RELEASE") generate_playlist "$mbid_current" "$path" "$mbid" | mpv_queue_next_list >/dev/null ;;
    "$VIEW_PLAYLIST") generate_playlist "$mbid_current" "$path" "$mbid" | mpv_queue_next_list >/dev/null ;;
    esac
    ;;
  "$PLAYBACK_CMD_TOGGLE_PLAYBACK") mpv_toggle_pause ;;
  "$PLAYBACK_CMD_PLAY_NEXT") mpv_next ;;
  "$PLAYBACK_CMD_PLAY_PREV") mpv_prev ;;
  "$PLAYBACK_CMD_SEEK_FORWARD") mpv_seek_forward ;;
  "$PLAYBACK_CMD_SEEK_BACKWARD") mpv_seek_backward ;;
  esac
}
