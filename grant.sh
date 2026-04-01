#!/bin/bash
set -e

if [ -z "$SERVER" ]; then
    echo "Fehler: Umgebungsvariable SERVER ist nicht gesetzt (z.B. SERVER=<deine-server-ip>)"
    exit 1
fi

ssh -i "$HOME/.ssh/sudoers_admin" "root@$SERVER" "$@"
