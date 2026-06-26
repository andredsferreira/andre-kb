package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/lib/pq"
)

var PostgresDB *sql.DB

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
		Host:        os.Getenv("PQDB_HOST"),
		Port:        os.Getenv("PQDB_PORT"),
		User:        os.Getenv("PQDB_USER"),
		Password:    os.Getenv("PQDB_PASSWORD"),
		Database:    os.Getenv("PQDB_DATABASE"),
		SSLMode:     os.Getenv("PQDB_SSLMODE"),
		SSLRootCert: os.Getenv("PQDB_ROOT_CERT"),
	}
	db, err := sql.Open("postgres", dbConfig.connectionString())
	if err != nil {
		log.Fatal(err)
	}

	db.SetConnMaxLifetime(time.Minute * 3)
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(10)

	err = db.Ping()
	if err != nil {
		log.Fatalf("database is not responding: %v", err)
	}

	if os.Getenv("ENV") == "dev" {
		// Bootstrap db
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
