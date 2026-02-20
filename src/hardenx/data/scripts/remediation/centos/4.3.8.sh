#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
  echo "false"
  exit 1
fi

VALUE="$1"
PARAM1="net.ipv4.conf.all.accept_source_route"
PARAM2="net.ipv4.conf.default.accept_source_route"
CONF_FILE="/etc/sysctl.d/99-security.conf"

set_persistent_param() {
  local param_name="$1"
  local param_value="$2"
  local config_file="$3"

  if grep -qE "^[[:space:]]*${param_name}[[:space:]]*=" "${config_file}"; then
    sed -i "s/^[[:space:]]*${param_name}[[:space:]]*=.*/${param_name} = ${param_value}/" "${config_file}"
  else
    echo "${param_name} = ${param_value}" >> "${config_file}"
  fi
  return $?
}

# Apply live settings
{
  sysctl -w "${PARAM1}=${VALUE}"
  sysctl -w "${PARAM2}=${VALUE}"
} &>/dev/null

if [[ $? -ne 0 ]]; then
  echo "false"
  exit 1
fi

# Make persistent settings
mkdir -p "$(dirname "${CONF_FILE}")" || { echo "false"; exit 1; }
touch "${CONF_FILE}" || { echo "false"; exit 1; }

set_persistent_param "${PARAM1}" "${VALUE}" "${CONF_FILE}" || { echo "false"; exit 1; }
set_persistent_param "${PARAM2}" "${VALUE}" "${CONF_FILE}" || { echo "false"; exit 1; }

echo "true"
exit 0