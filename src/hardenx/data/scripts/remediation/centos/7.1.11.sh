#!/usr/bin/env bash

if [[ $# -ne 1 || "$1" != "secure" ]]; then
    false
    exit 1
fi

CONFIG_FILES=(
    "/etc/profile"
    "/root/.bash_profile"
    "/root/.bashrc"
)

OVERALL_STATUS=0

for conf_file in "${CONFIG_FILES[@]}"; do
    if [[ ! -f "$conf_file" || ! -r "$conf_file" || ! -w "$conf_file" ]]; then
        continue
    fi

    tmp_file=$(mktemp)
    if [[ $? -ne 0 ]]; then
        OVERALL_STATUS=1
        break
    fi

    file_was_modified=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^([[:space:]]*(export[[:space:]]+)?PATH=)(.*) ]]; then
            prefix="${BASH_REMATCH[1]}"
            path_val_raw="${BASH_REMATCH[3]}"
            
            # Simple unquoting for clean parsing
            path_val="${path_val_raw}"
            if [[ "${path_val:0:1}" == '"' && "${path_val: -1}" == '"' ]] || \
               [[ "${path_val:0:1}" == "'" && "${path_val: -1}" == "'" ]]; then
                path_val="${path_val:1:-1}"
            fi

            sanitized_dirs=()
            
            IFS=':' read -ra DIRS <<< "$path_val"
            for dir in "${DIRS[@]}"; do
                if [[ -z "$dir" || "$dir" == "." ]]; then
                    continue
                fi

                # Keep non-directory entries (like variables $PATH)
                if [[ ! -d "$dir" ]]; then
                    sanitized_dirs+=("$dir")
                    continue
                fi

                # Check for group or world writability using find.
                # If find outputs anything, the directory is writable and should be skipped.
                if find "$dir" -maxdepth 0 -perm /g+w -print -o -perm /o+w -print | grep -q .; then
                     continue
                else
                     sanitized_dirs+=("$dir")
                fi
            done

            new_path_val=$(IFS=:; echo "${sanitized_dirs[*]}")
            
            if [[ "$new_path_val" != "$path_val" ]]; then
                file_was_modified=true
                # Rebuild line in a standard, quoted format
                echo "${prefix}\"${new_path_val}\"" >> "$tmp_file"
            else
                echo "$line" >> "$tmp_file"
            fi
        else
            echo "$line" >> "$tmp_file"
        fi
    done < "$conf_file"

    if [[ "$file_was_modified" == true ]]; then
        if ! chown --reference="$conf_file" "$tmp_file" || \
           ! chmod --reference="$conf_file" "$tmp_file" || \
           ! mv -f "$tmp_file" "$conf_file"; then
            OVERALL_STATUS=1
            rm -f "$tmp_file" &>/dev/null
            break
        fi
    else
        rm -f "$tmp_file"
    fi
done

if [[ "$OVERALL_STATUS" -eq 0 ]]; then
    true
else
    false
fi