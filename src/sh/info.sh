# Application information
if [ ! "${INFO_LOADED:-}" ]; then
  APP_NAME="fuzic"
  APP_VERSION="0.1"
  APP_WEBSITE="https://git.indyfac.ch/amin/fuzic"
  WINDOW_TITLE="🔎🎶 $APP_NAME | a simple music browser and player"
  export APP_NAME APP_VERSION APP_WEBSITE WINDOW_TITLE

  export INFO_LOADED=1
fi
