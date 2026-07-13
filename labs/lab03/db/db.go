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
	Host           string
	Port           string
	User           string
	Password       string
	Database       string
	SSLMode        string
	SSLRootCert    string
	ChannelBinding string
}

func Setup() {
	dbConfig := &dbConfig{
		Host:           os.Getenv("PGDB_HOST"),
		Port:           os.Getenv("PGDB_PORT"),
		User:           os.Getenv("PGDB_USER"),
		Password:       os.Getenv("PGDB_PASSWORD"),
		Database:       os.Getenv("PGDB_DATABASE"),
		SSLMode:        os.Getenv("PGDB_SSLMODE"),
		SSLRootCert:    os.Getenv("PGDB_ROOT_CERT"),
		ChannelBinding: os.Getenv("PGDB_CHANNEL_BINDING"),
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

	if c.ChannelBinding != "" {
		connStr += fmt.Sprintf("&channel_binding=%s", c.ChannelBinding)
	}

	return connStr
}
