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

func TestInsertAndQuery(t *testing.T) {
    _, err := CockroachDB.Exec(`INSERT INTO your_table (col1) VALUES ($1)`, "test-value")
    if err != nil {
        t.Fatalf("insert failed: %v", err)
    }

    var col1 string
    err = CockroachDB.QueryRow(`SELECT col1 FROM your_table WHERE col1 = $1`, "test-value").Scan(&col1)
    if err != nil {
        t.Fatalf("query failed: %v", err)
    }

    if col1 != "test-value" {
        t.Errorf("got %s, want test-value", col1)
    }

    CockroachDB.Exec(`DELETE FROM your_table WHERE col1 = $1`, "test-value")
}