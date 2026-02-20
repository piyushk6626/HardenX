#!/usr/bin/env bash

fail() {
    echo "false"
    exit 1
}

rebuild_grub() {
    if command -v update-grub &>/dev/null; then
        update-grub
    elif command -v grub2-mkconfig &>/dev/null; then
        if [[ -f /boot/grub2/grub.cfg ]]; then
            grub2-mkconfig -o /boot/grub2/grub.cfg
        elif [[ -f /boot/efi/EFI/redhat/grub.cfg ]]; then
            grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
        elif [[ -f /boot/efi/EFI/centos/grub.cfg ]]; then
            grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
        elif [[ -f /boot/efi/EFI/fedora/grub.cfg ]]; then
            grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
        else
            return 1
        fi
    else
        return 1
    fi
    return $?
}

if [[ $EUID -ne 0 ]]; then
   fail
fi

if [[ $# -ne 1 ]] || [[ "$1" != "Enabled" && "$1" != "Disabled" ]]; then
    fail
fi

STATE="$1"
SYSCTL_CONF="/etc/sysctl.d/99-disable-ipv6.conf"
GRUB_DEFAULT="/etc/default/grub"

if [[ "$STATE" == "Disabled" ]]; then
    {
        echo "net.ipv6.conf.all.disable_ipv6=1"
        echo "net.ipv6.conf.default.disable_ipv6=1"
    } > "$SYSCTL_CONF" || fail

    sysctl -p "$SYSCTL_CONF" &>/dev/null || sysctl --system &>/dev/null || fail

    if ! grep -q '^\s*GRUB_CMDLINE_LINUX=.*\bipv6.disable=1\b' "$GRUB_DEFAULT"; then
        cp "$GRUB_DEFAULT" "${GRUB_DEFAULT}.bak" || fail
        sed -i -E 's/^(GRUB_CMDLINE_LINUX=")([^"]*)(")/\1\2 ipv6.disable=1\3/' "$GRUB_DEFAULT" || fail
    fi

    rebuild_grub || fail

elif [[ "$STATE" == "Enabled" ]]; then
    if [[ -f "$SYSCTL_CONF" ]]; then
        rm -f "$SYSCTL_CONF" || fail
        sysctl --system &>/dev/null || fail
    fi

    if grep -q '^\s*GRUB_CMDLINE_LINUX=.*\bipv6.disable=1\b' "$GRUB_DEFAULT"; then
        cp "$GRUB_DEFAULT" "${GRUB_DEFAULT}.bak" || fail
        sed -i -E 's/\s*ipv6.disable=1//' "$GRUB_DEFAULT" || fail
    fi

    rebuild_grub || fail
fi

echo "true"
exit 0