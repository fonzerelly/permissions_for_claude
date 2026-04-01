#!/bin/bash
set -e

if [ "$1" = "_ALL_" ]; then
    rm -f /etc/sudoers.d/TO_*
    echo "Alle Permissions entzogen"
    exit 0
fi

for permission in "$@"; do
    if [ ! -f "/etc/sudoers.d/$permission" ]; then
        echo "Nicht gefunden: $permission"
        exit 1
    fi
    rm "/etc/sudoers.d/$permission"
    echo "Revoked: $permission"
done
