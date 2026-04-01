#!/usr/bin/env bats

setup() {
    TMPDIR=$(mktemp -d)
    export HOME=$TMPDIR
    SSH_LOG="$TMPDIR/ssh.log"

    mkdir -p "$TMPDIR/bin"
    printf '#!/bin/bash\necho "$@" >> "%s"\nexit 0\n' "$SSH_LOG" > "$TMPDIR/bin/ssh"
    chmod +x "$TMPDIR/bin/ssh"
    export PATH="$TMPDIR/bin:$PATH"

    export SERVER="fake-server"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "grant.sh gibt Fehlermeldung wenn SERVER nicht gesetzt" {
    unset SERVER
    run /app/grant.sh TO_WHOAMI
    [ "$status" -ne 0 ]
    [ "$output" = "Fehler: Umgebungsvariable SERVER ist nicht gesetzt (z.B. SERVER=<deine-server-ip>)" ]
}

@test "grant.sh ruft ssh mit sudoers_admin Key auf" {
    run /app/grant.sh TO_WHOAMI
    [ "$status" -eq 0 ]
    grep -q "sudoers_admin" "$SSH_LOG"
}

@test "grant.sh übergibt Permission-Namen an allow_claude.sh" {
    run /app/grant.sh TO_WHOAMI
    [ "$status" -eq 0 ]
    grep -q "TO_WHOAMI" "$SSH_LOG"
}

@test "grant.sh übergibt mehrere Permissions" {
    run /app/grant.sh TO_WHOAMI TO_ID
    [ "$status" -eq 0 ]
    grep -q "TO_WHOAMI" "$SSH_LOG"
    grep -q "TO_ID" "$SSH_LOG"
}
