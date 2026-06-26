package service

import (
	"andrekb/lab08/db"
	"database/sql"
	"fmt"
	"regexp"
)

type User struct {
	Username string
	Email    string
}

func GetUserByUsername(username string) (User, error) {
	var u User
	query := `
		SELECT username, password, email
		FROM users
		WHERE username = ?
	`
	row := db.PostgresDB.QueryRow(query, username)
	if err := row.Scan(&u.Username, &u.Email); err != nil {
		if err == sql.ErrNoRows {
			return u, fmt.Errorf("user does not exist")
		}
		return u, err
	}
	return u, nil
}

func AddUser(username, password, email string) error {
	query := `
        INSERT INTO users (username, password, email) 
        VALUES (?, ?, ?)
    `
	_, err := db.PostgresDB.Exec(query, username, password, email)
	if err != nil {
		return err
	}
	return nil
}

func ValidateUser(username, password, email string) bool {
	emailRegex := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	isValidEmail := regexp.MustCompile(emailRegex).MatchString(email)
	if len(username) >= 3 && len(password) >= 3 && isValidEmail {
		return true
	}
	return false
}
