package service

import (
	"andrekb/lab08/db"
	"testing"
)

func TestMain(m *testing.M) {
	db.Setup()
	m.Run()
}

func TestGetUsers(t *testing.T) {
	// Seed
	db.CockroachDB.Exec(`INSERT INTO users (username, password, email) VALUES ($1, $2, $3)`, "alice", "pass123", "alice@example.com")

	users, err := GetUsers()
	if err != nil {
		t.Fatalf("GetUsers failed: %v", err)
	}
	if len(users) == 0 {
		t.Error("expected at least one user, got none")
	}

	db.CockroachDB.Exec(`DELETE FROM users WHERE username = $1`, "alice")
}

func TestAddUser(t *testing.T) {
	err := AddUser("bob", "pass123", "bob@example.com")
	if err != nil {
		t.Fatalf("AddUser failed: %v", err)
	}

	// Verify it's actually in the DB
	var count int
	db.CockroachDB.QueryRow(`SELECT COUNT(*) FROM users WHERE username = $1`, "bob").Scan(&count)
	if count != 1 {
		t.Errorf("expected 1 user, got %d", count)
	}

	db.CockroachDB.Exec(`DELETE FROM users WHERE username = $1`, "bob")
}

func TestGetUserByUsername(t *testing.T) {
	db.CockroachDB.Exec(`INSERT INTO users (username, password, email) VALUES ($1, $2, $3)`, "charlie", "pass123", "charlie@example.com")

	u, err := GetUserByUsername("charlie")
	if err != nil {
		t.Fatalf("GetUserByUsername failed: %v", err)
	}
	if u.Username != "charlie" || u.Email != "charlie@example.com" {
		t.Errorf("got %+v, want {charlie charlie@example.com}", u)
	}

	db.CockroachDB.Exec(`DELETE FROM users WHERE username = $1`, "charlie")
}

func TestGetUserByUsername_NotFound(t *testing.T) {
	_, err := GetUserByUsername("doesnotexist")
	if err == nil {
		t.Error("expected error for missing user, got nil")
	}
	if err.Error() != "user does not exist" {
		t.Errorf("unexpected error message: %v", err)
	}
}
