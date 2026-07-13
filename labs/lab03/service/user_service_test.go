package service

import (
	"andrekb/lab03/db"
	"testing"
)

func TestMain(m *testing.M) {
	db.Setup()
	m.Run()
}

func TestGetUsers(t *testing.T) {

	users, err := GetUsers()
	if err != nil {
		t.Fatalf("GetUsers failed: %v", err)
	}
	if len(users) == 0 {
		t.Error("expected at least one user, got none")
	}

}

func TestAddUser(t *testing.T) {
	err := AddUser("morrison", "morrison@example.com")
	if err != nil {
		t.Fatalf("AddUser failed: %v", err)
	}

	var count int
	db.Postgres.QueryRow(`SELECT COUNT(*) FROM users WHERE username = $1`, "morrison").Scan(&count)
	if count != 1 {
		t.Errorf("expected 1 user, got %d", count)
	}

}

func TestGetUserByUsername(t *testing.T) {

	u, err := GetUserByUsername("charlie")
	if err != nil {
		t.Fatalf("GetUserByUsername failed: %v", err)
	}
	if u.Username != "charlie" || u.Email != "charlie@example.com" {
		t.Errorf("got %+v, want {charlie charlie@example.com}", u)
	}

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
