# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Goal

A bash script that grants Claude temporary, scoped SSH access to the home server (`192.168.178.60`). The script and all tests run inside Docker containers orchestrated via `docker-compose`.

## Development Workflow (TDD)

This project follows strict test-driven development:

1. Write a failing test first — make sure it fails *for the right reason* (the assert fails, not a missing file/syntax error).
2. Write the minimal production code to make it pass.
3. Move to the next small change.

Tests run inside a Docker container. Start them with:

```bash
docker compose up --build
```

To run a single test (once the test framework is established):

```bash
docker compose run --rm tests bash -c "<test-runner-command> <test-name>"
```

## Architecture (intended)

```
permissions_for_claude/
  grant_access.sh       ← main script (creates temporary SSH access)
  revoke_access.sh      ← cleanup / revocation logic
  tests/
    ...                 ← unit tests (bash-based, e.g. bats)
  docker-compose.yml    ← spins up test container
  Dockerfile            ← test environment (bats + dependencies)
  doc.md                ← running log of decisions and what each function does
```

## Test Framework

Tests use **bats** (Bash Automated Testing System) running inside Docker. The `docker-compose.yml` service exits with the test suite's exit code so CI can detect failures.

## doc.md Protocol

Every new function or behaviour must be documented in `doc.md` — describe what it does concretely, not just its name.
