#!/bin/bash

fail() {
  echo "false"
  exit 1
}

if [[ "$1" != "Enabled" ]]; then
  exit 0
fi

if [[ "${EUID}" -ne 0 ]]; then
  fail
fi

GRUB_HASH="${GRUB_PASSWORD_HASH:-$2}"

if [[ -z "${GRUB_HASH}" ]]; then
  fail
fi

GRUB_CONFIG_FILE="/etc/grub.d/01_users"

cat > "${GRUB_CONFIG_FILE}" << EOF || fail
set superusers="root"
password_pbkdf2 root ${GRUB_HASH}
EOF

chmod 755 "${GRUB_CONFIG_FILE}" || fail

if update-grub &>/dev/null; then
  echo "true"
else
  rm -f "${GRUB_CONFIG_FILE}"
  fail
fi

exit 0