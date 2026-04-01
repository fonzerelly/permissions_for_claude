#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

for permission in "$@"; do
    if [ ! -f "$SCRIPT_DIR/permissions/$permission" ]; then
        echo "Unbekannte Permission: $permission"
        exit 1
    fi
    visudo -c -f "$SCRIPT_DIR/permissions/$permission" || exit 1
    cp "$SCRIPT_DIR/permissions/$permission" "/etc/sudoers.d/$permission" || exit 1
    chown root:root "/etc/sudoers.d/$permission" || exit 1
    chmod 440 "/etc/sudoers.d/$permission" || exit 1
    echo "Granted: $permission"
done
