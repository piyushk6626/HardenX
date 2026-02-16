#!/usr/bin/env bash

GROUP_FILE="/etc/group"

if [[ "${EUID}" -ne 0 ]]; then
  exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="${GROUP_FILE}.backup.${TIMESTAMP}"

cp -p "${GROUP_FILE}" "${BACKUP_FILE}" || exit 1

TMP_FILE=$(mktemp)
if [[ $? -ne 0 ]]; then
    exit 1
fi
trap 'rm -f "${TMP_FILE}"' EXIT

if ! awk -F: '!seen[$1]++' "${GROUP_FILE}" > "${TMP_FILE}"; then
    exit 1
fi

if cmp -s "${GROUP_FILE}" "${TMP_FILE}"; then
    exit 0
fi

if ! chown --reference="${GROUP_FILE}" "${TMP_FILE}" || ! chmod --reference="${GROUP_FILE}" "${TMP_FILE}"; then
    exit 1
fi

if ! mv "${TMP_FILE}" "${GROUP_FILE}"; then
    exit 1
fi

exit 0