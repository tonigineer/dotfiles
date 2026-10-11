#!/usr/bin/env bash
# Install a built Pixel Orbit theme into /boot and make it GRUB's theme.
#
#   ./install.sh telemetry|telemetry-sans|horizon
#
# /boot is vfat, so the theme is copied, not linked. The first run backs up
# /etc/default/grub to /etc/default/grub.pre-pixel-orbit; restore that file and
# rerun grub-mkconfig to go back to the previous theme.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
variant="${1:?usage: install.sh telemetry|telemetry-sans|horizon}"
src="$here/out/$variant"
dest="/boot/grub/themes/pixel-orbit-$variant"
conf=/etc/default/grub

[ -f "$src/theme.txt" ] || { echo "not built: $src (run ./build.py)" >&2; exit 1; }
font="$(cd "$src" && ls ter-*.pf2)"

sudo rm -rf "$dest"
sudo cp -r "$src" "$dest"

[ -e "$conf.pre-pixel-orbit" ] || sudo cp -a "$conf" "$conf.pre-pixel-orbit"

set_var() {
    if grep -q "^$1=" "$conf"; then
        sudo sed -i "s|^$1=.*|$1=\"$2\"|" "$conf"
    else
        echo "$1=\"$2\"" | sudo tee -a "$conf" >/dev/null
    fi
}
set_var GRUB_THEME "$dest/theme.txt"
set_var GRUB_FONT "$dest/$font"
set_var GRUB_GFXMODE 2560x1440

# /etc/grub.d tweaks (a grub update undoes them; rerun this script afterwards)
sudo bash "$here/grub-tweaks.sh"

sudo grub-mkconfig -o /boot/grub/grub.cfg
