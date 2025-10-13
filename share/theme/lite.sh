# Colors (internal only)
ESC=$(printf '\033')
CARTIST="${ESC}[38;5;209m"
CYEAR="${ESC}[38;5;179m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
OFF="${ESC}[m"

# Pointers
# ========
# Sign that indicates the existence of audio files
FORMAT_LOCAL="${YELLOW}|>${OFF}"

# Input prompt
# =============
# General search prompt (for now only used when choosing one-of-many artist)
SEARCH_PROMPT="search> "

# General workings of format strings
#
# A format string (_FMT) contains placeholders, e.g., <<name>>. These
# placeholders are filled with the relevant information. A placeholder may
# occur zero times, once, or more than once. There are two types of
# placeholders: strings and items. A placeholder of type string comes with a
# variable containing a `printf` expression (_FMT_placeholder). This `printf`
# expression may be used to additionally modify the string passed. If the
# string passed is empty, then each corresponding placeholder is replaced
# with the empty string, i.e., the `printf` expression is bypassed. A
# placeholder of the alternative type (item) comes with a series of variables
# that encode constants to be used (_FMT_placeholder_XYZ).
#
# The items in the format string may be separated with "\t". This will induce
# a proper representation (using `column`). By default, all fields but the
# first are left aligned, and the first field is right aligned. This can be
# changed by setting the appropriate FMT_RIGHTALIGN variable. If that
# variable is empty, then the first field is right aligned. This means that
# at least one field must be right aligned.
#
# Artist view
# ===========
# <<flag>>            item    Indication for locally available audio files
# <<type>>            item    Indicator for single-person artist or group
# <<name>>            string  Artist name
# <<disambiguation>>  string  Disambiguation string
#
AV_FMT_TYPE_PERSON="${RED}P${OFF}"
AV_FMT_TYPE_GROUP="${RED}G${OFF}"
AV_FMT_NAME="${GREEN}%s${OFF}"
AV_FMT_DISAMBIGUATION="(%s)"

# Release-group view
# ==================
# <<flag>>          item    Indication for locally available audio files
# <<type>>          item    Indicates the type
# <<hassecondary>>  item    Indicates if there is some secondary type or none
# <<secondary>>     string  List of secondary types
# <<title>>         string  Title of album
# <<artist>>        string  Artist of album
# <<year>>          string  Year of initial release
# Note: The above <<secondary>> is of a joint item-string type. See code for
# details.
RGV_FMT="<<flag>>\t<<year>>\t<<title>>\t<<artist>>"
RGV_FMT_ARTIST="${CARTIST}%s${OFF}"
RGV_FMT_YEAR="${CYEAR}%s${OFF}"

# Release view
# ============
# <<flag>>      item     Indication for locally available audio files
# <<status>>    item     Release status
# <<tracks>>    string   Total number of track
# <<media>>     string   Media description
# <<year>>      string   Release year
# <<country>>   string   Release country
# <<label>>     string   Release label
# <<title>>     string   Optional titel string
# <<artist>>    string   Optional artist string
RV_FMT="<<flag>>\t<<year>>\t<<tracks>>\t<<media>>\t<<country>>\t<<label>>"

# Headers
# =======
# These header strings are based on the respective view and its fields
# defined above.
#
# Header that displays artist's name (based on artist view)
HEADER_ARTIST_FMT="\t<<name>>"
# Header that displays the release-group (based on release-group view)
HEADER_RG_FMT="\t<<artist>> / <<title>>"
# Header that displays the release (based on release view)
HEADER_R_FMT="\t<<artist>> / <<title>> / <<tracks>> tx <<media>>"
