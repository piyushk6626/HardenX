#!/usr/bin/env bash

rules=$(auditctl -l 2>/dev/null)

syscalls=(
    "chmod" "fchmod" "fchmodat"
    "chown" "fchown" "fchownat" "lchown"
    "setxattr" "lsetxattr" "fsetxattr"
    "removexattr" "lremovexattr" "fremovexattr"
)

archs=("b64" "b32")
if [[ "$(getconf LONG_BIT)" == "32" ]]; then
    archs=("b32")
fi

for syscall in "${syscalls[@]}"; do
    for arch in "${archs[@]}"; do
        if ! echo "$rules" | awk -v s="$syscall" -v a="$arch" '
            /^-a/ && /(always,exit|exit,always)/ && $0 ~ "-S " s "(\\s|,|$)" && $0 ~ "-F arch=" a "(\\s|,|$)" && \
            /auid>=1000/ && /perm=a/ && (/auid!=-1/ || /auid!=4294967295/) {
                found=1; exit
            }
            END { if (found) exit 0; else exit 1 }
        '; then
            echo "disabled"
            exit 0
        fi
    done
done

echo "enabled"