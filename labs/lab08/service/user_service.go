package service

import (
	"andrekb/lab08/db"
	"database/sql"
	"fmt"
)

type User struct {
	Username string
	Email    string
}

func GetUsers() ([]User, error) {
	var users []User
	query := `
		SELECT username, email
		FROM users
	`
	rows, err := db.CockroachDB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var u User
		if err := rows.Scan(&u.Username, &u.Email); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}

func GetUserByUsername(username string) (User, error) {
	var u User
	query := `SELECT username, email FROM users WHERE username = $1`
	row := db.CockroachDB.QueryRow(query, username)
	if err := row.Scan(&u.Username, &u.Email); err != nil {
		if err == sql.ErrNoRows {
			return u, fmt.Errorf("user does not exist")
		}
		return u, err
	}
	return u, nil
}

func AddUser(username, email string) error {
	query := `INSERT INTO users (username, email) VALUES ($1, $2)`
	_, err := db.CockroachDB.Exec(query, username, email)
	return err
}
