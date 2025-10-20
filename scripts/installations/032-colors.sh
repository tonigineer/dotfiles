#!/usr/bin/env bash

service_name=update-colors

unit_dir=~/.config/systemd/user

service_file="$unit_dir/${service_name}.service"
path_file="$unit_dir/${service_name}.path"

status() {
    systemctl --user --quiet is-active update-colors.path &&
        [[ -f "$service_file" ]] &&
        [[ -f "$path_file" ]]
}

install() {
    mkdir -p "$unit_dir"

    cat >"$service_file" <<'EOF'
[Unit]
Description=Execute script on Caelestia scheme change

[Service]
Type=oneshot
ExecStart=%h/.config/hypr/scripts/update-colors.sh
EOF

    cat >"$path_file" <<'EOF'
[Unit]
Description=Watch Caelestia scheme.json and trigger update-colors.service

[Path]
PathChanged=%h/.local/state/caelestia/scheme.json

[Install]
WantedBy=default.target
EOF

    chmod +x ~/.config/hypr/scripts/update-colors.sh

    systemctl --user daemon-reload
    systemctl --user enable --now "${service_name}.path"
}

uninstall() {
    systemctl --user disable --now "${service_name}.path"

    rm $service_file
    rm $path_file
}
