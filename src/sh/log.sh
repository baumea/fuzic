# Logging methods
#
# The default log file is `LOGFILE`. In the future, this file may become
# configurable.
if [ ! "${LOG_LOADED:-}" ]; then
  ERR="\033[38;5;196m"
  INFO="\033[38;5;75m"
  OFF="\033[m"
  LOGDIR="${XDG_STATE_HOME:-"$HOME/.local/state"}/$APP_NAME"
  [ -d "$LOGDIR" ] || mkdir -p "$LOGDIR"
  LOGFILE="$LOGDIR/log"
  export ERR INFO OFF LOGFILE

  export LOG_LOADED=1
fi

# Print an error message to stderr and log it incuding the time stamp and PID
# to the log file.
err() {
  echo "$(date) [$$]>${ERR}ERROR:${OFF} ${1:-}" | tee -a "$LOGFILE" | cut -d ">" -f 2- >/dev/stderr
}

# Print information to stderr and log it incuding the time stamp and PID to the
# log file.
info() {
  echo "$(date) [$$]>${INFO}Info:${OFF} ${1:-}" | tee -a "$LOGFILE" | cut -d ">" -f 2- >/dev/stderr
}

# Like `info` but without newlnes on stderr.
infonn() {
  echo "$(date) [$$]>${INFO}Info:${OFF} ${1:-}" | tee -a "$LOGFILE" | cut -d ">" -f 2- | tr '\n' ' ' >/dev/stderr
}
