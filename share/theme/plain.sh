# Pointers
# ========
# Sign that indicates the existence of audio files
FORMAT_LOCAL="|>"

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
AV_FMT_TYPE_PERSON="P"
AV_FMT_TYPE_GROUP="G"
AV_FMT_NAME="%s"
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
RGV_FMT_TYPE_SINGLE="single"
RGV_FMT_TYPE_ALBUM="LP"
RGV_FMT_TYPE_EP="EP"
RGV_FMT_TYPE_BROADCAST="broadcast"
RGV_FMT_TYPE_OTHER="other"
RGV_FMT_HASSECONDARY_YES="xx"
RGV_FMT_SECONDARY="[xx: %s]"
RGV_FMT_SECONDARY_SOUNDTRACK="soundtrack"
RGV_FMT_SECONDARY_SPOKENWORD="spokenword"
RGV_FMT_SECONDARY_INTERVIEW="interview"
RGV_FMT_SECONDARY_AUDIOBOOK="audiobook"
RGV_FMT_SECONDARY_AUDIODRAMA="audio drama"
RGV_FMT_SECONDARY_LIVE="live"
RGV_FMT_SECONDARY_REMIX="remix"
RGV_FMT_SECONDARY_DJMIX="DJ-mix"
RGV_FMT_SECONDARY_MIXTAPE="mixtape"
RGV_FMT_SECONDARY_DEMO="demo"
RGV_FMT_SECONDARY_FIELDREC="field recording"
RGV_FMT_TITLE="%s"
RGV_FMT_ARTIST=" - %s"
RGV_FMT_YEAR="(%s)"

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
RV_FMT="${RV_FMT:-"<<flag>>\t<<status>> >> \t<<tracks>>\t<<media>>\t<<year>>\t<<country>>\t<<label>>\t<<title>> <<artist>>"}"
RV_FMT_STATUS_OFFICIAL="official"
RV_FMT_STATUS_PROMO="promo"
RV_FMT_STATUS_BOOTLEG="bootleg"
RV_FMT_STATUS_PSEUDO="pseudo"
RV_FMT_STATUS_WITHDRAWN="withdrawn"
RV_FMT_STATUS_EXPUNGED="expunged"
RV_FMT_STATUS_CANCELLED="cancelled"
RV_FMT_TRACKS="%s tracks"
RV_FMT_MEDIA="%s"
RV_FMT_YEAR="%s"
RV_FMT_COUNTRY="%s"
RV_FMT_LABEL="%s"
RV_FMT_TITLE="as %s"
RV_FMT_ARTIST="by %s"

# Recording view
# ==============
# <<flag>>       item     Indication for locally available audio files
# <<media>>      string   Media identifier
# <<nr>>         string   Track number within media
# <<title>>      string   Track title
# <<artist>>     string   Track artist
# <<duration>>   string   Track duration
REC_FMT_MEDIA="%s"
REC_FMT_NR="%s"
REC_FMT_TITLE="%s"
REC_FMT_ARTIST="%s"
REC_FMT_DURATION="%s"

# Recording view (playlist)
# =========================
# <<playing>>    item     Mark for currently playing track
# <<title>>      string   Track title
# <<artist>>     string   Track artist
# <<duration>>   string   Track duration
PLYLST_FMT_PLAYING_YES="-->"
PLYLST_FMT_TITLE="%s"
PLYLST_FMT_ARTIST="%s"
PLYLST_FMT_DURATION="%s"

# Headers
# =======
# These header strings are based on the respective view and its fields
# defined above.
#
# Header that displays artist's name (based on artist view)
HEADER_ARTIST_FMT=":::\t<<name>> >"

# Header that displays the release-group (based on release-group view)
HEADER_RG_FMT=":::\t<<artist>> >> <<title>> >"
HEADER_RG_FMT_ARTIST="%s"

# Header that displays the release (based on release view)
#HEADER_RELEASE="${HEADER_RELEASE:-" ${CARTIST}%s$OFF 》${CTITLE}%s$OFF 〉%s"}"
#HEADER_RELEASE_FORMAT="${HEADER_RELEASE_FORMAT:-"${CRELINFO}<<tracks>> tx <<media>> $OFF|$CRELINFO <<label>> <<country>> <<year>>$OFF"}"
HEADER_R_FMT=":::\t<<artist>> >> <<title>> > <<tracks>> tx <<media>> | <<label>> <<country>> <<year>>"
HEADER_R_FMT_TRACKS="%s"
HEADER_R_FMT_MEDIA="%s"
HEADER_R_FMT_YEAR="%s"
HEADER_R_FMT_COUNTRY="%s"
HEADER_R_FMT_LABEL="%s"
HEADER_R_FMT_TITLE="%s"
HEADER_R_FMT_ARTIST="%s"

# Artist Preview
# ==============
# Lines that contain the pattern defined in PREVIEW_NO_WRAP (see
# `src/sh/preview.sh`) will not be wrapped.
#
# We distinguish between single-person and group artists.
#
# <<name>>           | string                   | Artist name
# <<sortname>>       | string                   | Artist sort name
# <<bio>>            | string                   | Artist biography
# <<disambiguation>> | string                   | Artist disambiguation string
# <<alias>>          | higher-order placeholder | Placeholder for aliases
# <<start>           | higher-order placeholder | Placeholder for start string
# <<end>>            | higher-order placeholder | Placeholder for end string
# <<url>>            | higher-order placeholder | Placeholder for links
PREVIEW_ARTIST_PERSON_BIO="%s\n\n"
PREVIEW_ARTIST_PERSON_ALIAS="Also known as %s\n\n"
PREVIEW_ARTIST_PERSON_START="Born: %s\n"
PREVIEW_ARTIST_PERSON_END="Died: %s\n"
PREVIEW_ARTIST_PERSON_URL="\nLinks:\n%s\n"
PREVIEW_ARTIST_PERSON_URL_URLINDEX="%3d"
PREVIEW_ARTIST_PERSON_URL_URLNAME="%s"
PREVIEW_ARTIST_PERSON_URL_URLLINK="%s"

PREVIEW_ARTIST_GROUP_START="Founded: %s\n"
PREVIEW_ARTIST_GROUP_END="Dissolved: %s\n"

# Keybinding themes
# =================
# Format keybinding group
KBF_GROUP="%s"
# Format key
KBF_KEY="%s"
# Format description
KBF_DESC="%s"

# Playlist title
# ==============
TITLE_PLYLST="  Playlist  "
