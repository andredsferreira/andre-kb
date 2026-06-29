package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	// Cockroach DB uses the PostgresSQL driver under the hood.
	_ "github.com/lib/pq"
)

var CockroachDB *sql.DB

type dbConfig struct {
	Host        string
	Port        string
	User        string
	Password    string
	Database    string
	SSLMode     string
	SSLRootCert string
}

func Setup() {
	dbConfig := &dbConfig{
		Host:        os.Getenv("CRDB_HOST"),
		Port:        os.Getenv("CRDB_PORT"),
		User:        os.Getenv("CRDB_USER"),
		Password:    os.Getenv("CRDB_PASSWORD"),
		Database:    os.Getenv("CRDB_DATABASE"),
		SSLMode:     os.Getenv("CRDB_SSLMODE"),
		SSLRootCert: os.Getenv("CRDB_ROOT_CERT"),
	}
	var err error
	CockroachDB, err = sql.Open("postgres", dbConfig.connectionString())
	if err != nil {
		log.Fatal(err)
	}

	CockroachDB.SetConnMaxLifetime(time.Minute * 3)
	CockroachDB.SetMaxOpenConns(10)
	CockroachDB.SetMaxIdleConns(10)

	err = CockroachDB.Ping()
	if err != nil {
		log.Fatalf("database is not responding: %v", err)
	}
}

func (c *dbConfig) connectionString() string {
	connStr := fmt.Sprintf(
		"postgresql://%s:%s@%s:%s/%s?sslmode=%s",
		c.User,
		c.Password,
		c.Host,
		c.Port,
		c.Database,
		c.SSLMode,
	)

	if c.SSLRootCert != "" {
		connStr += fmt.Sprintf("&sslrootcert=%s", c.SSLRootCert)
	}

	return connStr
}
