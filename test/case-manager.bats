#!/usr/bin/env bats
# Tests for case-manager. Each test runs in an isolated temp directory.
# Requires: bats (npm i -g bats | apt-get install bats)
# Run: bats test/

SCRIPT="$BATS_TEST_DIRNAME/../case-manager"

setup() {
    TESTDIR="$(mktemp -d)"
    cd "$TESTDIR"
}

teardown() {
    rm -rf "$TESTDIR"
}

@test "version prints the current version" {
    run bash "$SCRIPT" version
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.1.0"* ]]
}

@test "help prints usage" {
    run bash "$SCRIPT" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: case-manager"* ]]
}

@test "no command prints an error and fails" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
}

@test "unknown command fails" {
    run bash "$SCRIPT" frobnicate
    [ "$status" -eq 1 ]
}

# ---- create ----

@test "create builds the four subdirectories" {
    run bash "$SCRIPT" create case1
    [ "$status" -eq 0 ]
    [ -d case1/images ]
    [ -d case1/reports ]
    [ -d case1/logs ]
    [ -d case1/evidence ]
}

@test "create rejects a duplicate name" {
    run bash "$SCRIPT" create case1
    run bash "$SCRIPT" create case1
    [ "$status" -eq 1 ]
}

@test "create rejects a name with a slash" {
    run bash "$SCRIPT" create "a/b"
    [ "$status" -eq 1 ]
}

@test "create rejects a name with spaces" {
    run bash "$SCRIPT" create "a b"
    [ "$status" -eq 1 ]
}

@test "create rejects a leading dot" {
    run bash "$SCRIPT" create ".hidden"
    [ "$status" -eq 1 ]
}

@test "create rejects '.'" {
    run bash "$SCRIPT" create "."
    [ "$status" -eq 1 ]
}

@test "create rejects '..'" {
    run bash "$SCRIPT" create ".."
    [ "$status" -eq 1 ]
}

@test "create rejects a '..' substring" {
    run bash "$SCRIPT" create "a..b"
    [ "$status" -eq 1 ]
}

@test "create rejects a trailing newline" {
    run bash "$SCRIPT" create $'case\n'
    [ "$status" -eq 1 ]
}

@test "create accepts a valid name" {
    run bash "$SCRIPT" create "valid-1.2"
    [ "$status" -eq 0 ]
}

# ---- list ----

@test "list is safe in an empty directory" {
    run bash "$SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"No cases found."* ]]
}

@test "list shows created cases" {
    bash "$SCRIPT" create c1 >/dev/null 2>&1
    run bash "$SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" == *"c1"* ]]
    [[ "$output" == *"Total: 1 cases"* ]]
}

# ---- status ----

@test "status rejects '.'" {
    run bash "$SCRIPT" status "."
    [ "$status" -eq 1 ]
}

@test "status works on a real case" {
    bash "$SCRIPT" create c1 >/dev/null 2>&1
    run bash "$SCRIPT" status c1
    [ "$status" -eq 0 ]
    [[ "$output" == *"Case Status: c1"* ]]
    [[ "$output" == *"evidence:"* ]]
}

@test "status fails on a missing case" {
    run bash "$SCRIPT" status nope
    [ "$status" -eq 1 ]
}

# ---- archive ----

@test "archive creates a .tar.gz" {
    bash "$SCRIPT" create c1 >/dev/null 2>&1
    run bash "$SCRIPT" archive c1
    [ "$status" -eq 0 ]
    [ -f c1.tar.gz ]
}

@test "archive refuses '../x' (path traversal)" {
    run bash "$SCRIPT" archive "../x"
    [ "$status" -eq 1 ]
}

@test "archive fails on a missing case" {
    run bash "$SCRIPT" archive nope
    [ "$status" -eq 1 ]
}

# ---- delete ----

@test "delete refuses '..' and runs no rm" {
    touch SENTINEL
    run bash "$SCRIPT" delete ".."
    [ "$status" -eq 1 ]
    [ -f SENTINEL ]
}

@test "delete refuses '/etc' (absolute path)" {
    run bash "$SCRIPT" delete /etc
    [ "$status" -eq 1 ]
}

@test "delete removes a case after confirmation" {
    bash "$SCRIPT" create c1 >/dev/null 2>&1
    run bash "$SCRIPT" delete c1 < <(printf 'y\n')
    [ "$status" -eq 0 ]
    [ ! -d c1 ]
}

@test "delete is cancelled on 'N'" {
    bash "$SCRIPT" create c1 >/dev/null 2>&1
    run bash "$SCRIPT" delete c1 < <(printf 'N\n')
    [ "$status" -eq 0 ]
    [ -d c1 ]
}

@test "delete --force removes without prompting" {
    bash "$SCRIPT" create c1 >/dev/null 2>&1
    run bash "$SCRIPT" delete --force c1
    [ "$status" -eq 0 ]
    [ ! -d c1 ]
}

# ---- rename ----

@test "rename works" {
    bash "$SCRIPT" create old >/dev/null 2>&1
    run bash "$SCRIPT" rename old new
    [ "$status" -eq 0 ]
    [ -d new ]
    [ ! -d old ]
}

@test "rename rejects an invalid new name" {
    bash "$SCRIPT" create old >/dev/null 2>&1
    run bash "$SCRIPT" rename old "a b"
    [ "$status" -eq 1 ]
    [ -d old ]
}

@test "rename fails when target already exists" {
    bash "$SCRIPT" create old >/dev/null 2>&1
    bash "$SCRIPT" create new >/dev/null 2>&1
    run bash "$SCRIPT" rename old new
    [ "$status" -eq 1 ]
}

# ---- open ----

@test "open fails gracefully when there are no cases" {
    run bash "$SCRIPT" open
    [ "$status" -eq 1 ]
    [[ "$output" == *"No case directories found"* ]]
}

# ---- color hygiene ----

@test "piped output contains no ANSI escape sequences" {
    run bash "$SCRIPT" create c1
    [ "$status" -eq 0 ]
    ! [[ "$output" == *$'\e'* ]]
}
