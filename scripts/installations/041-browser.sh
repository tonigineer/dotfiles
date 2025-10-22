#!/usr/bin/env bash

readonly COLORSCHEME_DIR=~/.local/state/caelestia/theme/librewolf.css

pkgs=(
    librewolf-bin
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-hyprland
)

get_profile() {
  local ini="$HOME/.librewolf/profiles.ini" def
  def=$(awk -F= '/^\[Install/ {i=1} i && $1=="Default" {print $2; exit}' "$ini")
  if [[ -n $def ]]; then printf '%s/.librewolf/%s\n' "$HOME" "$def"
  else
    awk -F= -v d="$HOME/.librewolf" '
      /^\[Profile/ {p=1} p&&$1=="Path"{path=$2}
      p&&$1=="Default"&&$2==1{print d"/"path; exit}
    ' "$ini"
  fi
}

readonly PROFILE_DIR=$(get_profile)

status() {
    yay_check "${pkgs[@]}" &&
        [ -L ~/.librewolf/colorscheme.css ] &&
        [ -L $PROFILE_DIR/chrome/userChrome.css ]
}

install() {
    yay_install "${pkgs[@]}"

    mkdir -p $PROFILE_DIR/chrome
    ln -sf $dotfiles_dir/.librewolf/userChrome.css $PROFILE_DIR/chrome/userChrome.css
    ln -sf "$COLORSCHEME_DIR" ~/.librewolf/colorscheme.css

    xdg-settings set default-web-browser librewolf.desktop
}

uninstall() {
    local pkgs=(librewolf-bin)
    yay_uninstall "${pkgs[@]}"

    rm -f $PROFILE_DIR/chrome/userChrome.css
    rm -f ~/.librewolf/colorscheme.css
}
