#!/usr/bin/env bats

setup() {
    # Lege Testdateien in /etc/sudoers.d/ an
    echo "claude ALL=(ALL) NOPASSWD: /usr/bin/whoami" > /etc/sudoers.d/TO_WHOAMI
    echo "claude ALL=(ALL) NOPASSWD: /usr/bin/id"     > /etc/sudoers.d/TO_ID
    chmod 440 /etc/sudoers.d/TO_WHOAMI /etc/sudoers.d/TO_ID
}

teardown() {
    rm -f /etc/sudoers.d/TO_*
}

@test "deactivate_rule.sh entfernt einzelne Permission" {
    run /app/libs/deactivate_rule.sh TO_WHOAMI
    [ "$status" -eq 0 ]
    [ ! -f /etc/sudoers.d/TO_WHOAMI ]
}

@test "deactivate_rule.sh lässt andere Permissions unangetastet" {
    run /app/libs/deactivate_rule.sh TO_WHOAMI
    [ "$status" -eq 0 ]
    [ -f /etc/sudoers.d/TO_ID ]
}

@test "deactivate_rule.sh gibt Fehlermeldung bei unbekannter Permission" {
    run /app/libs/deactivate_rule.sh TO_UNKNOWN
    [ "$status" -ne 0 ]
    [ "$output" = "Nicht gefunden: TO_UNKNOWN" ]
}

@test "deactivate_rule.sh _ALL_ entfernt alle TO_*-Permissions" {
    run /app/libs/deactivate_rule.sh _ALL_
    [ "$status" -eq 0 ]
    [ ! -f /etc/sudoers.d/TO_WHOAMI ]
    [ ! -f /etc/sudoers.d/TO_ID ]
}

@test "deactivate_rule.sh entfernt mehrere Permissions auf einmal" {
    run /app/libs/deactivate_rule.sh TO_WHOAMI TO_ID
    [ "$status" -eq 0 ]
    [ ! -f /etc/sudoers.d/TO_WHOAMI ]
    [ ! -f /etc/sudoers.d/TO_ID ]
}
