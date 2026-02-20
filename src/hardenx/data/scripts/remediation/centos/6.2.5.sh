#!/usr/bin/env bash

fail() {
    echo "false"
    exit 1
}

if [[ $EUID -ne 0 ]]; then
    fail
fi

if [[ $# -ne 1 || ("$1" != "Enabled" && "$1" != "Disabled") ]]; then
    fail
fi

if ! command -v visudo &>/dev/null; then
    fail
fi

ACTION="$1"
SUDOERS_MAIN="/etc/sudoers"
SUDOERS_DIR="/etc/sudoers.d"
CONFIG_FILE_DISABLED="${SUDOERS_DIR}/99-no-password-prompt"
PATTERN_UNCOMMENTED='^[[:space:]]*Defaults[[:space:]][^#]*\!authenticate'

get_sudoers_files() {
    local -n files_array=$1
    files_array=()
    [[ -f "$SUDOERS_MAIN" ]] && files_array+=("$SUDOERS_MAIN")
    if [[ -d "$SUDOERS_DIR" ]]; then
        shopt -s nullglob
        for f in "$SUDOERS_DIR"/*; do
            # Skip directories, backup files, and readmes
            [[ -f "$f" && ! "$f" =~ (~|\.bak|\.tmp|\.swp|README)$ ]] && files_array+=("$f")
        done
        shopt -u nullglob
    fi
}

if [[ "$ACTION" == "Enabled" ]]; then
    files_to_check=()
    get_sudoers_files files_to_check
    
    modified=false
    for file in "${files_to_check[@]}"; do
        if grep -qE "$PATTERN_UNCOMMENTED" "$file"; then
            temp_file=$(mktemp) || fail
            cp "$file" "$temp_file" || { rm -f "$temp_file"; fail; }
            sed -i -E "s/($PATTERN_UNCOMMENTED)/# \1/" "$temp_file"
            
            if visudo -c -f "$temp_file" &>/dev/null; then
                mv "$temp_file" "$file" || { rm -f "$temp_file"; fail; }
                modified=true
            else
                rm -f "$temp_file"
                fail
            fi
        fi
    done
    echo "true"
    exit 0
fi

if [[ "$ACTION" == "Disabled" ]]; then
    files_to_check=()
    get_sudoers_files files_to_check

    for file in "${files_to_check[@]}"; do
        if grep -qE "$PATTERN_UNCOMMENTED" "$file"; then
            echo "true"
            exit 0
        fi
    done

    if [[ ! -d "$SUDOERS_DIR" ]]; then
        mkdir -p "$SUDOERS_DIR" || fail
        chmod 0750 "$SUDOERS_DIR" || fail
    fi

    echo "Defaults !authenticate" > "$CONFIG_FILE_DISABLED" || fail
    chmod 0440 "$CONFIG_FILE_DISABLED" || { rm -f "$CONFIG_FILE_DISABLED"; fail; }

    if ! visudo -c &>/dev/null; then
        rm -f "$CONFIG_FILE_DISABLED"
        fail
    fi

    echo "true"
    exit 0
fi

fail