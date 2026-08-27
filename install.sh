#!/bin/bash

set -euo pipefail

readonly PLUGIN_ID="io.github.pulkitchauhan.motion-backgrounds"
readonly SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly TARGET_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
readonly MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
readonly WALLS_DIR="$HOME/.config/motion-backgrounds/walls"
readonly DEFAULT_WALLPAPER="samurai-katana-in-forest-cinematic-4k-live-wallpaper.mp4"

install_dependencies() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Installing ffmpeg..."
    omarchy pkg add ffmpeg
  fi

  if ! command -v mpvpaper >/dev/null 2>&1; then
    echo "Installing mpvpaper from the AUR..."
    omarchy pkg aur add mpvpaper
  fi
}

install_plugin_files() {
  mkdir -p "$TARGET_DIR"

  if [[ $SOURCE_DIR != "$TARGET_DIR" ]]; then
    cp -a "$SOURCE_DIR/." "$TARGET_DIR/"
  fi

  chmod +x "$TARGET_DIR/install.sh" "$TARGET_DIR/bin/motion-backgrounds"
  mkdir -p "$WALLS_DIR"
}

install_default_wallpaper() {
  local source="$TARGET_DIR/assets/walls/$DEFAULT_WALLPAPER"
  local destination="$WALLS_DIR/$DEFAULT_WALLPAPER"

  [[ -f $source ]] || {
    echo "Bundled default wallpaper is missing: $source" >&2
    return 1
  }

  if [[ ! -e $destination ]]; then
    install -m 0644 "$source" "$destination"
  fi
}

install_menu_entry() {
  mkdir -p "$(dirname "$MENU_FILE")"

  if [[ ! -f $MENU_FILE ]]; then
    printf '{\n}\n' >"$MENU_FILE"
  fi

  local clean_file="$MENU_FILE.clean.$$"
  local temporary="$MENU_FILE.tmp.$$"

  if rg -q '^\s*// motion-backgrounds:start\s*$' "$MENU_FILE"; then
    awk '
      /^[[:space:]]*\/\/ motion-backgrounds:start[[:space:]]*$/ { skipping = 1; next }
      /^[[:space:]]*\/\/ motion-backgrounds:end[[:space:]]*$/ { skipping = 0; next }
      !skipping { print }
    ' "$MENU_FILE" >"$clean_file"
  else
    cp "$MENU_FILE" "$clean_file"
  fi

  awk -v block="$TARGET_DIR/assets/menu-entry.jsonc" '
    !inserted && index($0, "{") {
      print
      while ((getline line < block) > 0) print line
      close(block)
      inserted = 1
      next
    }
    { print }
    END { if (!inserted) exit 1 }
  ' "$clean_file" >"$temporary"
  rm -f "$clean_file"
  mv -f "$temporary" "$MENU_FILE"
}

enable_plugin() {
  omarchy plugin validate "$TARGET_DIR"

  if omarchy-shell shell rescanPlugins >/dev/null 2>&1; then
    omarchy plugin enable "$PLUGIN_ID"
    omarchy menu refresh >/dev/null 2>&1 || true
  else
    echo "Motion Backgrounds was installed, but omarchy-shell is not reachable."
    echo "Enable it after logging into Omarchy with: omarchy plugin enable $PLUGIN_ID"
  fi
}

warn_about_old_autostart() {
  local autostart="$HOME/.config/hypr/autostart.lua"
  if [[ -f $autostart ]] && rg -q 'mpvpaper' "$autostart"; then
    echo
    echo "Warning: $autostart still starts mpvpaper directly."
    echo "Remove that old mpvpaper line; Motion Backgrounds restores live wallpapers itself."
  fi
}

main() {
  command -v omarchy >/dev/null 2>&1 || {
    echo "Motion Backgrounds requires Omarchy." >&2
    exit 1
  }

  command -v rg >/dev/null 2>&1 || {
    echo "Motion Backgrounds requires ripgrep (rg)." >&2
    exit 1
  }

  install_dependencies
  install_plugin_files
  install_default_wallpaper
  install_menu_entry
  enable_plugin
  warn_about_old_autostart

  echo
  echo "Motion Backgrounds installed."
  echo "Bundled wallpaper added: $WALLS_DIR/$DEFAULT_WALLPAPER"
  echo "Add wallpapers to: $HOME/.config/motion-backgrounds/walls/"
  echo "Open the picker with: Super+Ctrl+Space"
}

main "$@"
