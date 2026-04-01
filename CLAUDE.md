# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Goal

A bash script that grants Claude temporary, scoped SSH access to the home server (`<deine-server-ip>`). The script and all tests run inside Docker containers orchestrated via `docker-compose`.

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

## Architecture

```
permissions_for_claude/
  libs/activate_rule.sh       ← server-side script (installs sudoers files)
  setup.sh              ← one-time client-side setup (keys + server config)
  permissions/          ← sudoers snippets (one file per permission)
  tests/
    activate_rule.bats  ← tests for activate_rule.sh
    setup.bats          ← tests for setup.sh
  docker-compose.yml    ← spins up test container
  Dockerfile            ← test environment (bats + dependencies)
  README.md             ← documentation
```

## Test Framework

Tests use **bats** (Bash Automated Testing System) running inside Docker. The `docker-compose.yml` service exits with the test suite's exit code so CI can detect failures.

## Tests
To run tests use run-tests.sh and extend it if necessary.