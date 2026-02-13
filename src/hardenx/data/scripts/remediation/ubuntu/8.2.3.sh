#!/usr/bin/env bash

GRUB_CONFIG="/etc/default/grub"
ACTION="$1"

# --- Pre-flight checks ---
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root." >&2
   false
   exit $?
fi

if [ "$#" -ne 1 ] || { [[ "$ACTION" != "enabled" ]] && [[ "$ACTION" != "disabled" ]]; }; then
    echo "Usage: $0 [enabled|disabled]" >&2
    false
    exit $?
fi

if [ ! -w "$GRUB_CONFIG" ]; then
    echo "Error: Cannot write to GRUB config file: $GRUB_CONFIG" >&2
    false
    exit $?
fi

# Check for existence of update command
UPDATE_CMD=""
if command -v update-grub &> /dev/null; then
    UPDATE_CMD="update-grub"
elif command -v grub2-mkconfig &> /dev/null; then
    # Check common locations for the grub config
    if [ -f "/boot/grub2/grub.cfg" ]; then
        UPDATE_CMD="grub2-mkconfig -o /boot/grub2/grub.cfg"
    elif [ -f "/boot/efi/EFI/redhat/grub.cfg" ]; then # RHEL/CentOS EFI
        UPDATE_CMD="grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg"
    fi
fi

if [ -z "$UPDATE_CMD" ]; then
    echo "Error: Could not find a valid GRUB update command (update-grub, grub2-mkconfig)." >&2
    false
    exit $?
fi


# --- Main Logic ---
MODIFIED=false
if grep -q '^\s*GRUB_CMDLINE_LINUX=' "$GRUB_CONFIG"; then
    # Get the current CMDLINE value, stripping quotes
    CURRENT_CMDLINE=$(grep -oP '^\s*GRUB_CMDLINE_LINUX="\K[^"]*' "$GRUB_CONFIG")
    HAS_AUDIT=$(echo "$CURRENT_CMDLINE" | grep -q -w "audit=1" && echo true || echo false)

    case "$ACTION" in
        enabled)
            if [ "$HAS_AUDIT" = false ]; then
                if [ -z "$CURRENT_CMDLINE" ]; then
                    NEW_CMDLINE="audit=1"
                else
                    NEW_CMDLINE="$CURRENT_CMDLINE audit=1"
                fi
                # Use a different delimiter (#) for sed to avoid issues with slashes
                sed -i.bak "s#^GRUB_CMDLINE_LINUX=.*#GRUB_CMDLINE_LINUX=\"$NEW_CMDLINE\"#" "$GRUB_CONFIG"
                MODIFIED=true
            fi
            ;;
        disabled)
            if [ "$HAS_AUDIT" = true ]; then
                # Remove audit=1 and clean up potential extra whitespace
                NEW_CMDLINE=$(echo "$CURRENT_CMDLINE" | sed -e 's/\baudit=1\b//g' -e 's/  */ /g' -e 's/^ *//;s/ *$//')
                sed -i.bak "s#^GRUB_CMDLINE_LINUX=.*#GRUB_CMDLINE_LINUX=\"$NEW_CMDLINE\"#" "$GRUB_CONFIG"
                MODIFIED=true
            fi
            ;;
    esac
else
    echo "Error: GRUB_CMDLINE_LINUX not found in $GRUB_CONFIG" >&2
    false
    exit $?
fi

# --- Finalization ---
if [ "$MODIFIED" = true ]; then
    if $UPDATE_CMD &> /dev/null; then
        true
    else
        echo "Error: GRUB update command failed." >&2
        false
    fi
else
    # No modification was needed, but the state is correct, so it's a success.
    true
fi