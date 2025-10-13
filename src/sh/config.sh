# Main application configuration. This application does not require a
# configuration file. However, a configuration file may be stored as
# `CONFIGFILE_DEFAULT`. If that file exists, it will be sourced. The path to
# the file may be overwritten by specifying the environment variable
# `CONFIGFILE`. If a configuration file is specified, then it must also exist.
# A configuration file comprises the specification of environment variables
# that are allowed to be set.
#
# Currently, the following files hold variables that are configurable:
# - `src/sh/filter.sh`:  Configuration of filters that can be triggered with
#                        the respective key bindings.
# - `src/sh/keys.sh`:    Configuration of key bindings to certain actions
# - `src/sh/theme.sh`:   Configuration of theme
# - `src/sh/sort.sh`:    List sorting
CONFIGFILE_DEFAULT="${XDG_CONFIG_HOME:-"$HOME/.config"}/$APP_NAME/config"
CONFIGFILE="${CONFIGFILE:-"$CONFIGFILE_DEFAULT"}"
[ "$CONFIGFILE" != "$CONFIGFILE_DEFAULT" ] && [ ! -f "$CONFIGFILE" ] && err "The configuration file manually specified with the environment variable CONFIGFILE=($CONFIGFILE) does not exist." && exit 1
# shellcheck source=/dev/null
[ -f "$CONFIGFILE" ] && . "$CONFIGFILE"
