#!/bin/bash

PERMISSIONS_DIR=$(dirname "$(realpath "$0")")/../permissions

for permission in "$@"; do
    if [ ! -f "$PERMISSIONS_DIR/$permission" ]; then
        echo "Unbekannte Permission: $permission"
        exit 1
    fi
    visudo -c -f "$PERMISSIONS_DIR/$permission" || exit 1
    cp "$PERMISSIONS_DIR/$permission" "/etc/sudoers.d/$permission" || exit 1
    chown root:root "/etc/sudoers.d/$permission" || exit 1
    chmod 440 "/etc/sudoers.d/$permission" || exit 1
    echo "Granted: $permission"
done
