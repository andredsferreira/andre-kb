package db

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/url"
	"os"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
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
	password, err := loadPassword()
	if err != nil {
		log.Fatalf("could not load database password: %v", err)
	}

	cfg := &dbConfig{
		Host:     os.Getenv("PSQL_HOST"),
		Port:     os.Getenv("PSQL_PORT"),
		User:     os.Getenv("PSQL_USER"),
		Password: password,
		Database: os.Getenv("PSQL_DATABASE"),
	}

	Postgres, err = sql.Open("postgres", cfg.connectionString())
	if err != nil {
		log.Fatal(err)
	}

	Postgres.SetConnMaxLifetime(time.Minute * 3)
	Postgres.SetMaxOpenConns(10)
	Postgres.SetMaxIdleConns(10)

	if err = Postgres.Ping(); err != nil {
		log.Fatalf("database is not responding: %v", err)
	}
}

// loadPassword returns PSQL_PASSWORD if set (local development),
// otherwise fetches it from AWS Secrets Manager.
func loadPassword() (string, error) {
	if pw := os.Getenv("PSQL_PASSWORD"); pw != "" {
		return pw, nil
	}

	secretID := os.Getenv("DB_SECRET_ID")
	if secretID == "" {
		return "", fmt.Errorf("neither PSQL_PASSWORD nor DB_SECRET_ID is set")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	awsCfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return "", fmt.Errorf("loading AWS config: %w", err)
	}

	client := secretsmanager.NewFromConfig(awsCfg)
	out, err := client.GetSecretValue(ctx, &secretsmanager.GetSecretValueInput{
		SecretId: &secretID,
	})
	if err != nil {
		return "", fmt.Errorf("getting secret %q: %w", secretID, err)
	}
	if out.SecretString == nil {
		return "", fmt.Errorf("secret %q has no string value", secretID)
	}

	// Support both a JSON secret ({"password": "..."}) and a plain-string secret.
	var parsed struct {
		Password string `json:"password"`
	}
	if err := json.Unmarshal([]byte(*out.SecretString), &parsed); err == nil && parsed.Password != "" {
		return parsed.Password, nil
	}
	return *out.SecretString, nil
}

func (c *dbConfig) connectionString() string {
	u := url.URL{
		Scheme: "postgresql",
		User:   url.UserPassword(c.User, c.Password),
		Host:   fmt.Sprintf("%s:%s", c.Host, c.Port),
		Path:   c.Database,
	}
	return u.String()
}
