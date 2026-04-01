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

@test "revoke gibt Fehlermeldung wenn SERVER nicht gesetzt" {
    unset SERVER
    run /app/revoke TO_WHOAMI
    [ "$status" -ne 0 ]
    [ "$output" = "Fehler: Umgebungsvariable SERVER ist nicht gesetzt (z.B. SERVER=<deine-server-ip>)" ]
}

@test "revoke ruft ssh mit sudoers_revoke Key auf" {
    run /app/revoke TO_WHOAMI
    [ "$status" -eq 0 ]
    grep -q "sudoers_revoke" "$SSH_LOG"
}

@test "revoke übergibt Permission-Namen" {
    run /app/revoke TO_WHOAMI
    [ "$status" -eq 0 ]
    grep -q "TO_WHOAMI" "$SSH_LOG"
}

@test "revoke übergibt _ALL_" {
    run /app/revoke _ALL_
    [ "$status" -eq 0 ]
    grep -q "_ALL_" "$SSH_LOG"
}
