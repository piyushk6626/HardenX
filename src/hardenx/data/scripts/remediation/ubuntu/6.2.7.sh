#!/bin/bash

if [[ $# -ne 1 ]]; then
  false
  exit $?
fi

if [[ "$(id -u)" -ne 0 ]]; then
  false
  exit $?
fi

case "$1" in
  restricted)
    chgrp sudo /bin/su && chmod 4750 /bin/su
    ;;
  unrestricted)
    chgrp root /bin/su && chmod 4755 /bin/su
    ;;
  *)
    false
    ;;
esac