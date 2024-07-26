HOME_PATH="$HOME/bin"
if [ -d "$HOME_PATH" ] && [[ "$PATH" != *"$HOME_PATH"* ]]; then
  PATH="$HOME_PATH:$PATH"
fi
