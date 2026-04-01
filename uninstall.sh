#!/bin/bash
set -e

for cmd in allow_claude revoke_claude; do
    if [ -L "/usr/local/bin/$cmd" ]; then
        rm "/usr/local/bin/$cmd"
        echo "Entfernt: /usr/local/bin/$cmd"
    else
        echo "Nicht gefunden: /usr/local/bin/$cmd"
    fi
done
