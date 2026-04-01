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

ssh -t "master@$SERVER" "sudo bash -c '
    apt-get install -y git
    echo \"***********************************************\"
    echo \"* Der Server verbindet sich jetzt mit GitHub. *\"
    echo \"* Falls gefragt: Fingerprint mit yes bestaetigen *\"
    echo \"***********************************************\"
    git clone $REPO_URL /usr/local/lib/permissions_for_claude || git -C /usr/local/lib/permissions_for_claude pull
    chmod 700 /usr/local/lib/permissions_for_claude/allow_claude.sh
    chown root:root /usr/local/lib/permissions_for_claude/allow_claude.sh
    mkdir -p /root/.ssh
    grep -qF \"sudoers_admin\" /root/.ssh/authorized_keys 2>/dev/null || \
        echo \"command=\\\"/usr/local/lib/permissions_for_claude/allow_claude.sh \$SSH_ORIGINAL_COMMAND\\\",no-pty,no-port-forwarding $PUBLIC_KEY\" >> /root/.ssh/authorized_keys
'"
