# Interface to the mpv music player. This interface communicates to an mpv
# instance through the socket `MPV_SOCKET`.

# Internal helper method to send a command without arguments to mpv
#
# @argument $1: command
__mpv_command() {
  printf "{ \"command\": [\"%s\"] }\n" "$1" | $SOCAT - "$MPV_SOCKET"
}

# Internal helper method to send a command with a single argument to mpv
#
# @argument $1: command
# @argument $2: argument
__mpv_command_with_arg() {
  printf "{ \"command\": [\"%s\", \"%s\"] }\n" "$1" "$2" | $SOCAT - "$MPV_SOCKET"
}

# Internal helper method to send a command with two arguments to mpv
#
# @argument $1: command
# @argument $2: argument 1
# @argument $3: argument 2
__mpv_command_with_args2() {
  printf "{ \"command\": [\"%s\", \"%s\", \"%s\"] }\n" "$1" "$2" "$3" | $SOCAT - "$MPV_SOCKET"
}

# Internal helper method to resolve mpv variables
#
# @argument $1: mpv expression
__mpv_get() {
  __mpv_command_with_arg "expand-text" "$1" | $JQ '.data'
}

# Get the total number of tracks in the playlist
mpv_playlist_count() {
  __mpv_get '${playlist-count}'
}

# Get the position of the current track in the playlist (0 based)
mpv_playlist_position() {
  __mpv_get '${playlist-pos}'
}

# Move track on playlist
#
# @argument $1: track index 1
# @argument $2: track index 2
#
# Moves the track at the first index to the position of the track of the second
# index. Also here, indices are 0 based.
mpv_playlist_move() {
  __mpv_command_with_args2 "playlist-move" "$1" "$2"
}

# Remove all tracks from the playlist
mpv_playlist_clear() {
  __mpv_command "playlist-clear"
}

# Randomly shuffle the order of the tracks in the playlist
mpv_playlist_shuffle() {
  __mpv_command "playlist-shuffle"
}

# Revert a previously shuffle command
#
# This method works only for a first shuffle.
mpv_playlist_unshuffle() {
  __mpv_command "playlist-unshuffle"
}

# Quit the mpv instance bound to the socket `MPV_SOCKET`
mpv_quit() {
  __mpv_command "quit"
}

# Start an mpv instance and bind it to the socket `MPV_SOCKET`
mpv_start() {
  MPV_SOCKET="$(mktemp --suffix=.sock)"
  trap 'mpv_quit >/dev/null; rm -f "$MPV_SOCKET"' EXIT INT
  $MPV --no-config --no-terminal --input-ipc-server="$MPV_SOCKET" --idle --no-osc --no-input-default-bindings &
}

# Play the track at the specified index in the playlist
#
# @argument $1: index (0 based)
mpv_play_index() {
  __mpv_command_with_arg "playlist-play-index" "$1"
}

# Remove the track at the specified index from the playlist
#
# @argument $1: index (0 based)
mpv_rm_index() {
  __mpv_command_with_arg "playlist-remove" "$1"
}

# Load the playlist with the specified list, and start playing
#
# This method reads from stdin a playlist file, e.g., a .m3u file.
mpv_play_list() {
  t=$(mktemp)
  cat >"$t"
  __mpv_command_with_arg "loadlist" "$t"
  rm -f "$t"
}

# Append the playlist with the specified list, and start playing
#
# This method reads from stdin a playlist file, e.g., a .m3u file.
mpv_queue_list() {
  t=$(mktemp)
  cat >"$t"
  __mpv_command_with_args2 "loadlist" "$t" "append-play"
  rm -f "$t"
}

# Insert the playlist with the specified list as the next item, and start
# playing
#
# This method reads from stdin a playlist file, e.g., a .m3u file.
mpv_queue_next_list() {
  t=$(mktemp)
  cat >"$t"
  pos=$(mpv_playlist_position)
  cnt1=$(mpv_playlist_count)
  __mpv_command_with_args2 "loadlist" "$t" "append-play"
  rm -f "$t"
  cnt2=$(mpv_playlist_count)
  diff=$((cnt2 - cnt1))
  [ "$diff" -gt 0 ] || return
  # Move added items right after current item (numbers are 0 based)
  for i in $(seq "$diff"); do
    mpv_playlist_move $((cnt1 + i - 1)) $((pos + i))
  done
}

# Play next track on playlist
mpv_next() {
  __mpv_command "playlist-next"
}

# Play previous track on playlist
mpv_prev() {
  __mpv_command "playlist-prev"
}

# Seek forward by 10 seconds
mpv_seek_forward() {
  __mpv_command_with_arg "seek" "10"
}

# Seek backward by 10 seconds
mpv_seek_backward() {
  __mpv_command_with_arg "seek" "-10"
}

# Pause if mpv plays, and play if it is paused
mpv_toggle_pause() {
  __mpv_command_with_arg "cycle" "pause"
}
