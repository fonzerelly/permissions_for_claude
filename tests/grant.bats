#!/usr/bin/env bats

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

@test "allow_claude.sh mit TO_WHOAMI und TO_UPTIME_CORRUPTED schlägt fehl" {
    run /app/allow_claude.sh TO_WHOAMI TO_UPTIME_CORRUPTED
    [ "$status" -ne 0 ]
}
