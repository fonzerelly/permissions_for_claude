#!/bin/bash
set -e

if [ -z "$SERVER" ]; then
    echo "Fehler: Umgebungsvariable SERVER ist nicht gesetzt (z.B. SERVER=<deine-server-ip>)"
    exit 1
fi

REPO_URL=$(git remote get-url origin | sed 's|git@github.com:|https://github.com/|')

KEY="$HOME/.ssh/sudoers_admin"

if [ ! -f "$KEY" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$KEY" -C "sudoers_admin" -N ""
    echo "Key erzeugt: $KEY"
else
    echo "Key bereits vorhanden, wird nicht überschrieben: $KEY"
fi

PUBLIC_KEY=$(cat "$KEY.pub")

SCRIPT_DIR=$(dirname "$(realpath "$0")")

sed \
    -e "s|{{REPO_URL}}|$REPO_URL|g" \
    -e "s|{{PUBLIC_KEY}}|$PUBLIC_KEY|g" \
    "$SCRIPT_DIR/libs/server_setup.sh" \
    | ssh -t "master@$SERVER" "sudo bash"
