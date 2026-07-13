package db

import (
    "testing"
)

func TestMain(m *testing.M) {
    Setup() 
    m.Run()
}

func TestDBConnection(t *testing.T) {
    if err := Postgres.Ping(); err != nil {
        t.Fatalf("db not reachable: %v", err)
    }
}