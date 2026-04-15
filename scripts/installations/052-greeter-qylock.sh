#!/usr/bin/env bash

readonly TMP="$(mktemp -d)"

pkgs=(
	qt6-declarative 
	qt6-5compat
	qt6-multimedia
	qt6-multimedia-ffmpeg
	gst-plugins-base
	gst-plugins-good 
	gst-plugins-bad 
	gst-plugins-ugly 
	fzf
)


preview_theme() {
	~/.local/share/quickshell-lockscreen/lock.sh
}

theme_install() {
    git clone  https://github.com/Darkkal44/qylock.git $TMP/qylock
    sudo cp -r $TMP/qylock /opt/qylock/

	cd /opt/qylock/
	sudo chmod +x /opt/qylock/sddm.sh

	chmod +x sddm.sh && ./sddm.sh
	chmod +x quickshell.sh && ./quickshell.sh

    systemctl enable sddm.service
}

status() {
    yay_check "${pkgs[@]}" &&
        systemctl --quiet is-active sddm.service
}

install() {
    yay_install "${pkgs[@]}"

    theme_install
    preview_theme
}

uninstall() {
    sudo systemctl disable sddm.service

    readonly PGKS=()
    yay_uninstall "${PGKS[@]}"
}
