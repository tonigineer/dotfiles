#!/usr/bin/env bash
# Local tweaks to the grub package's /etc/grub.d scripts for the Pixel Orbit theme.
#
#   - 10_linux: drop the "Loading Linux ..." / "Loading initial ramdisk ..." echoes and
#     clear to the boot splash's opening frame instead, see "Opening frame" below
#   - 30_uefi-firmware: give the firmware entry --class efi, so the theme has an icon
#   - entry names: "Arch Linux" / "Arch Linux (fallback)" instead of "Arch Linux, with
#     Linux linux (fallback initramfs)" (other kernels get their name in brackets), and
#     "Windows 11" instead of "Windows Boot Manager (on /dev/nvme2n1p3)"
#
# The grub package overwrites both files on update, so rerun this afterwards:
#   sudo ~/.local/share/grub-themes/pixel-orbit/grub-tweaks.sh --mkconfig
# Idempotent. With --mkconfig, regenerates grub.cfg as well.
set -euo pipefail

sed -E -i '/^[[:space:]]*echo[[:space:]]+\x27\$\(echo "\$message" \| grub_quote\)\x27[[:space:]]*$/d' \
    /etc/grub.d/10_linux
sed -E -i '/--class efi/! s/(menuentry \x27\$LABEL\x27) /\1 --class efi /' \
    /etc/grub.d/30_uefi-firmware

sed -i -f - /etc/grub.d/10_linux <<'SED'
s@title="$(gettext_printf "%s, with Linux %s (fallback initramfs)" "${os}" "${version}")"@title="${os}$(test "${version}" = linux || printf ' (%s)' "${version}") (fallback)"@
s@title="$(gettext_printf "%s, with Linux %s" "${os}" "${version}")"@title="${os}$(test "${version}" = linux || printf ' (%s)' "${version}")"@
SED
sed -i -f - /etc/grub.d/30_os-prober <<'SED'
s@'$(echo "${LONGNAME} $onstr" | grub_quote)' $CLASS@'$(echo "${LONGNAME}" | sed "s/^Windows Boot Manager$/Windows 11/" | grub_quote)' $CLASS@
SED

# Opening frame: a booting Linux entry clears the screen to the Plymouth splash's
# first frame (060-bootsplash installs it as /boot/grub/pixel-orbit-launch.png)
# instead of black and keeps it up while GRUB loads the kernel; the splash then
# takes over that same frame and sets it moving. Without the file it clears to
# black. `clear` also drops the "Booting `...'" line a timeout prints.
#
# What earlier versions added is removed first (the frame line, and the launch
# log GRUB used to print: the only lines in 10_linux that clear the screen, set
# colours or echo the log's indent), so reruns replace rather than duplicate.
sed -E -i "/pixel-orbit-launch|^\t(clear|set color_normal=[a-z-]+\/[a-z-]+|echo (-e )?'(\\\\n)*            .*)$/d" \
    /etc/grub.d/10_linux
launch=$(cat <<'EOF'
	if [ -f "\$prefix/pixel-orbit-launch.png" ]; then background_image --mode normal "\$prefix/pixel-orbit-launch.png"; fi
	clear
EOF
)
LAUNCH=$launch awk '
    index($0, "\tlinux\t${rel_dirname}/${basename} ") == 1 { print ENVIRON["LAUNCH"] }
    { print }
' /etc/grub.d/10_linux > /etc/grub.d/10_linux.new
cat /etc/grub.d/10_linux.new > /etc/grub.d/10_linux  # keeps the file's mode
rm /etc/grub.d/10_linux.new
grep -q 'pixel-orbit-launch' /etc/grub.d/10_linux ||
    echo "grub-tweaks: 10_linux has a new layout, opening frame not added" >&2

if [ "${1:-}" = --mkconfig ]; then
    grub-mkconfig -o /boot/grub/grub.cfg
fi
