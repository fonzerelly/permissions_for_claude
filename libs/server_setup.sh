#!/bin/bash
set -e

REPO_URL="{{REPO_URL}}"
PUBLIC_KEY="{{PUBLIC_KEY}}"
INSTALL_DIR="/usr/local/lib/permissions_for_claude"

apt-get install -y git

echo "***********************************************"
echo "* Der Server verbindet sich jetzt mit GitHub. *"
echo "* Falls gefragt: Fingerprint mit yes bestaetigen *"
echo "***********************************************"

git clone "$REPO_URL" "$INSTALL_DIR" \
    || git -C "$INSTALL_DIR" pull

chmod 700 "$INSTALL_DIR/libs/activate_rule.sh"
chown root:root "$INSTALL_DIR/libs/activate_rule.sh"

mkdir -p /root/.ssh

grep -qF "sudoers_admin" /root/.ssh/authorized_keys 2>/dev/null \
    || echo "command=\"$INSTALL_DIR/libs/activate_rule.sh \$SSH_ORIGINAL_COMMAND\",no-pty,no-port-forwarding $PUBLIC_KEY" \
        >> /root/.ssh/authorized_keys
