#!/usr/bin/env bats

setup() {
    rm -f /etc/sudoers.d/TO_*
}

teardown() {
    rm -f /etc/sudoers.d/TO_*
}

@test "allow_claude.sh findet permissions relativ zu seiner eigenen Position" {
    TMPDIR=$(mktemp -d)
    cp /app/allow_claude.sh "$TMPDIR/"
    mkdir "$TMPDIR/permissions"
    # TO_TMPONLY existiert nur im tmpdir, nicht in /app/permissions/
    # => schlägt fehl wenn allow_claude.sh den Pfad hardcoded hat
    echo "claude ALL=(ALL) NOPASSWD: /usr/bin/whoami" > "$TMPDIR/permissions/TO_TMPONLY"
    run "$TMPDIR/allow_claude.sh" TO_TMPONLY
    rm -rf "$TMPDIR"
    [ "$status" -eq 0 ]
    [ -f /etc/sudoers.d/TO_TMPONLY ]
}

@test "allow_claude.sh TO_WHOAMI besteht die visudo-Syntaxprüfung" {
    run /app/allow_claude.sh TO_WHOAMI
    [ "$status" -eq 0 ]
}

@test "allow_claude.sh TO_ID besteht die visudo-Syntaxprüfung" {
    run /app/allow_claude.sh TO_ID
    [ "$status" -eq 0 ]
}

@test "allow_claude.sh TO_UPTIME_CORRUPTED schlägt bei der visudo-Syntaxprüfung fehl" {
    run /app/allow_claude.sh TO_UPTIME_CORRUPTED
    [ "$status" -ne 0 ]
}

@test "allow_claude.sh TO_UNKNOWN gibt eine sprechende Fehlermeldung aus" {
    run /app/allow_claude.sh TO_UNKNOWN
    [ "$status" -ne 0 ]
    [ "$output" = "Unbekannte Permission: TO_UNKNOWN" ]
}

@test "allow_claude.sh TO_UNKNOWN TO_UPTIME_CORRUPTED schlägt fehl" {
    run /app/allow_claude.sh TO_UNKNOWN TO_UPTIME_CORRUPTED
    [ "$status" -ne 0 ]
}

@test "allow_claude.sh mit TO_WHOAMI und TO_UPTIME_CORRUPTED schlägt fehl" {
    run /app/allow_claude.sh TO_WHOAMI TO_UPTIME_CORRUPTED
    [ "$status" -ne 0 ]
}

@test "allow_claude.sh TO_WHOAMI kopiert die Datei nach /etc/sudoers.d/" {
    run /app/allow_claude.sh TO_WHOAMI
    [ "$status" -eq 0 ]
    [ -f /etc/sudoers.d/TO_WHOAMI ]
}

@test "allow_claude.sh TO_WHOAMI setzt chmod 440" {
    run /app/allow_claude.sh TO_WHOAMI
    [ "$status" -eq 0 ]
    run stat -c "%a" /etc/sudoers.d/TO_WHOAMI
    [ "$output" = "440" ]
}

@test "allow_claude.sh TO_WHOAMI setzt owner root:root" {
    run /app/allow_claude.sh TO_WHOAMI
    [ "$status" -eq 0 ]
    run stat -c "%U:%G" /etc/sudoers.d/TO_WHOAMI
    [ "$output" = "root:root" ]
}
