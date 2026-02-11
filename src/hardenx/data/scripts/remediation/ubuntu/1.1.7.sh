#!/bin/bash

CONF_FILE="/etc/modprobe.d/99-disable-squashfs.conf"

if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "false"
  exit 1
fi

case "$1" in
  Disabled)
    echo "install squashfs /bin/true" > "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
      echo "false"
      exit 1
    fi

    if lsmod | grep -q "^squashfs\s"; then
      modprobe -r squashfs
      if [[ $? -ne 0 ]]; then
        rm -f "$CONF_FILE"
        echo "false"
        exit 1
      fi
    fi
    echo "true"
    ;;

  Enabled)
    if [[ -f "$CONF_FILE" ]]; then
      rm -f "$CONF_FILE"
      if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
      fi
    fi
    echo "true"
    ;;

  *)
    echo "false"
    exit 1
    ;;
esac

exit 0