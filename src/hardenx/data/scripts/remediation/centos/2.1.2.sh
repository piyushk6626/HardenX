#!/usr/bin/env bash

secure_grub() {
    local grub_cfg="/boot/grub2/grub.cfg"

    if [[ $EUID -ne 0 ]]; then
       echo "Error: This script must be run as root." >&2
       return 1
    fi

    if [[ ! -f "$grub_cfg" ]]; then
        echo "Error: GRUB configuration file not found at $grub_cfg" >&2
        return 1
    fi

    # 1. Set ownership
    chown root:root "$grub_cfg" || return 1

    # 2. Set permissions
    chmod 600 "$grub_cfg" || return 1

    # 3. Set password interactively
    echo "Setting GRUB superuser password. Please follow the prompts."
    grub2-setpassword || return 1

    # 4. Regenerate config
    if command -v grub2-mkconfig &> /dev/null; then
        grub2-mkconfig -o "$grub_cfg" &> /dev/null || return 1
    else
        echo "Error: grub2-mkconfig command not found. Cannot regenerate config." >&2
        return 1
    fi

    return 0
}

if secure_grub; then
    true
else
    false
fi