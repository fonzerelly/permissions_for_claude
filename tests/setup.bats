#!/usr/bin/env bats

setup() {
    TMPDIR=$(mktemp -d)
    export HOME=$TMPDIR
    SSH_LOG="$TMPDIR/ssh.log"

    # Mock ssh, scp und git: tun nichts, damit Unit-Tests ohne Server laufen
    mkdir -p "$TMPDIR/bin"
    printf '#!/bin/bash\necho "$@" >> "%s"\nexit 0\n' "$SSH_LOG" > "$TMPDIR/bin/ssh"
    printf '#!/bin/bash\nexit 0\n' > "$TMPDIR/bin/scp"
    printf '#!/bin/bash\necho "https://github.com/fonzerelly/permissions_for_claude.git"\nexit 0\n' > "$TMPDIR/bin/git"
    chmod +x "$TMPDIR/bin/ssh" "$TMPDIR/bin/scp" "$TMPDIR/bin/git"
    export PATH="$TMPDIR/bin:$PATH"

    export SERVER="fake-server"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "setup.sh erzeugt sudoers_admin Key wenn er nicht existiert" {
    run /app/setup.sh
    [ "$status" -eq 0 ]
    [ -f "$HOME/.ssh/sudoers_admin" ]
    [ -f "$HOME/.ssh/sudoers_admin.pub" ]
}

@test "setup.sh gibt Fehlermeldung wenn SERVER nicht gesetzt" {
    unset SERVER
    run /app/setup.sh
    [ "$status" -ne 0 ]
    [ "$output" = "Fehler: Umgebungsvariable SERVER ist nicht gesetzt (z.B. SERVER=<deine-server-ip>)" ]
}

@test "setup.sh trägt authorized_keys Eintrag mit command=-Einschränkung ein" {
    run /app/setup.sh
    [ "$status" -eq 0 ]
    PUBLIC_KEY=$(cat "$HOME/.ssh/sudoers_admin.pub")
    grep -q 'command=.*activate_rule.sh.*\$SSH_ORIGINAL_COMMAND' "$SSH_LOG"
    grep -q "no-pty,no-port-forwarding" "$SSH_LOG"
    grep -qF "$PUBLIC_KEY" "$SSH_LOG"
}

@test "setup.sh erzeugt sudoers_revoke Key wenn er nicht existiert" {
    run /app/setup.sh
    [ "$status" -eq 0 ]
    [ -f "$HOME/.ssh/sudoers_revoke" ]
    [ -f "$HOME/.ssh/sudoers_revoke.pub" ]
}

@test "setup.sh trägt authorized_keys Eintrag für revoke mit command=-Einschränkung ein" {
    run /app/setup.sh
    [ "$status" -eq 0 ]
    PUBLIC_KEY=$(cat "$HOME/.ssh/sudoers_revoke.pub")
    grep -q 'command=.*deactivate_rule.sh.*\$SSH_ORIGINAL_COMMAND' "$SSH_LOG"
    grep -qF "$PUBLIC_KEY" "$SSH_LOG"
}

@test "setup.sh überschreibt vorhandenen Key nicht" {
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$HOME/.ssh/sudoers_admin" -C "original" -N ""
    ORIGINAL=$(cat "$HOME/.ssh/sudoers_admin.pub")

    run /app/setup.sh
    [ "$status" -eq 0 ]
    [ "$(cat "$HOME/.ssh/sudoers_admin.pub")" = "$ORIGINAL" ]
}
