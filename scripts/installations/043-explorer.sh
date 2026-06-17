# ── Explorer — Thunar + thumbnailers ────────────────────────────────────

pkgs=(
    evince
    ffmpegthumbnailer
    imv
    libopenraw
    libgsf
    libheif
    poppler-glib
    thunar
    tumbler
    webp-pixbuf-loader
)

remove_pkgs=(
    thunar
)

# ── Hooks ───────────────────────────────────────────────────────────────

mod_post_install() {
    mkdir -p ~/.config/Thunar
    cat >~/.config/Thunar/uca.xml <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<actions>
<action>
<icon>utilities-terminal</icon>
<name>Open Terminal Here</name>
<submenu></submenu>
<unique-id>1763564326697889-1</unique-id>
<command>kitty --directory %f</command>
<description>Open a terminal in this folder</description>
<range></range>
<patterns>*</patterns>
<startup-notify/>
<directories/>
</action>
</actions>
XML
}
