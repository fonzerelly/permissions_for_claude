#!/bin/bash

for permission in "$@"; do
    if [ ! -f "/app/permissions/$permission" ]; then
        echo "Unbekannte Permission: $permission"
        exit 1
    fi
    visudo -c -f "/app/permissions/$permission" || exit 1
    cp "/app/permissions/$permission" "/etc/sudoers.d/$permission" || exit 1
    chown root:root "/etc/sudoers.d/$permission" || exit 1
    chmod 440 "/etc/sudoers.d/$permission" || exit 1
    echo "Granted: $permission"
done
