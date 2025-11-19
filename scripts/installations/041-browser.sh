#!/usr/bin/env bash

readonly COLORSCHEME_DIR=~/.local/state/caelestia/theme

pkgs=(
    zen-browser-bin
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
)

get_profile() {
  local base ini def

  # Detect where Zen is installed (native vs flatpak)
  if [[ -f "$HOME/.zen/profiles.ini" ]]; then
    base="$HOME/.zen"
    ini="$base/profiles.ini"
  elif [[ -f "$HOME/.var/app/app.zen_browser.zen/.zen/profiles.ini" ]]; then
    base="$HOME/.var/app/app.zen_browser.zen/.zen"
    ini="$base/profiles.ini"
  else
    echo "zen profiles.ini not found" >&2
    return 1
  fi

  # First try [Install...] section Default=
  def=$(awk -F= '
    /^\[Install/ {inst=1}
    inst && $1=="Default" {print $2; exit}
  ' "$ini")

  if [[ -n $def ]]; then
    # If Default is absolute, just print it; otherwise prepend base
    if [[ $def = /* ]]; then
      printf '%s\n' "$def"
    else
      printf '%s/%s\n' "$base" "$def"
    fi
    return 0
  fi

  # Fallback: find [Profile*] with Default=1
  awk -F= -v d="$base" '
    /^\[Profile/ {p=1; rel=1; path=""}
    p && $1=="IsRelative" {rel=$2}
    p && $1=="Path"       {path=$2}
    p && $1=="Default" && $2==1 {
      if (rel == 1) print d "/" path;
      else          print path;
      exit
    }
  ' "$ini"
}

readonly PROFILE_DIR="$(get_profile)"

status() {
    yay_check "${pkgs[@]}" &&
        [ -L "$PROFILE_DIR/chrome/userChrome.css" ] &&
        [ -L "$PROFILE_DIR/chrome/userContent.css" ]
}

install() {
    yay_install "${pkgs[@]}"

    mkdir -p "$PROFILE_DIR/chrome"
    ln -sf $COLORSCHEME_DIR/zen-userChrome.css "$PROFILE_DIR/chrome/userChrome.css"
    ln -sf $COLORSCHEME_DIR/zen-userContent.css "$PROFILE_DIR/chrome/userContent.css"

    xdg-settings set default-web-browser zen.desktop
}

uninstall() {
    local pkgs=(zen-browser-bin)
    yay_uninstall "${pkgs[@]}"

    rm -rf "$PROFILE_DIR/chrome"
}
