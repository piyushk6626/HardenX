#!/bin/bash

if [[ "$#" -ne 1 || -z "$1" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONF_FILE="/etc/libuser.conf"
ALGORITHM="$1"
TMP_FILE=$(mktemp)

if [[ ! -f "$CONF_FILE" ]]; then
    echo "false"
    rm -f "$TMP_FILE"
    exit 1
fi

# Use awk to rebuild the file, ensuring the crypt_style is set correctly
# under [defaults]. This is safer than in-place editing.
awk -v alg="${ALGORITHM}" '
    BEGIN {
        in_defaults = 0
        defaults_found = 0
        style_set = 0
    }
    /^\[defaults\]/ {
        in_defaults = 1
        defaults_found = 1
    }
    /^\[.*\]/ && !/^\[defaults\]/ {
        if (in_defaults && !style_set) {
            print "crypt_style = " alg
            style_set = 1
        }
        in_defaults = 0
    }
    in_defaults && /^\s*crypt_style\s*=/ {
        print "crypt_style = " alg
        style_set = 1
        next
    }
    { print }
    END {
        if (in_defaults && !style_set) {
            print "crypt_style = " alg
        }
        if (!defaults_found) {
            exit 1
        }
    }
' "${CONF_FILE}" > "${TMP_FILE}"

AWK_EXIT_CODE=$?

if [[ "$AWK_EXIT_CODE" -ne 0 ]]; then
    echo "false"
    rm -f "${TMP_FILE}"
    exit 1
fi

# Preserve permissions and ownership while replacing the file
install -m "$(stat -c %a ${CONF_FILE})" -o "$(stat -c %u ${CONF_FILE})" -g "$(stat -c %g ${CONF_FILE})" "${TMP_FILE}" "${CONF_FILE}"

if [[ "$?" -eq 0 ]]; then
    echo "true"
else
    echo "false"
    rm -f "${TMP_FILE}"
fi