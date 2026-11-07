package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/lib/pq"
)

var Postgres *sql.DB

type dbConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	Database string
}

func Setup() {
	dbConfig := &dbConfig{
		Host:     os.Getenv("PSQL_HOST"),
		Port:     os.Getenv("PSQL_PORT"),
		User:     os.Getenv("PSQL_USER"),
		Password: os.Getenv("PSQL_PASSWORD"),
		Database: os.Getenv("PSQL_DATABASE"),
	}
	var err error
	Postgres, err = sql.Open("postgres", dbConfig.connectionString())
	if err != nil {
		log.Fatal(err)
	}

	Postgres.SetConnMaxLifetime(time.Minute * 3)
	Postgres.SetMaxOpenConns(10)
	Postgres.SetMaxIdleConns(10)

	err = Postgres.Ping()
	if err != nil {
		log.Fatalf("database is not responding: %v", err)
	}
}

func (c *dbConfig) connectionString() string {
	connStr := fmt.Sprintf(
		"postgresql://%s:%s@%s:%s/%s",
		c.User,
		c.Password,
		c.Host,
		c.Port,
		c.Database,
	)

	return connStr
}
