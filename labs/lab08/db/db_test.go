package db

import (
    "testing"
)

func TestMain(m *testing.M) {
    Setup() // uses env vars, same as your app
    m.Run()
}

func TestDBConnection(t *testing.T) {
    if err := CockroachDB.Ping(); err != nil {
        t.Fatalf("db not reachable: %v", err)
    }
}