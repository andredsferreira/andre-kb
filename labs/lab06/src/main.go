// Lambda: insert a row into RDS PostgreSQL, credentials from AWS Secrets Manager.
//
// Env vars:
//
//	DB_SECRET_ARN  (required) ARN or name of the secret
//	DB_HOST        (optional) overrides "host" in the secret
//	DB_NAME        (optional) overrides "dbname" in the secret (default "postgres")
//	DB_SSLMODE     (optional) default "require"; use "verify-full" with the RDS CA bundle
//
// Expected table:
//
//	CREATE TABLE IF NOT EXISTS events (
//	    id         BIGSERIAL PRIMARY KEY,
//	    name       TEXT NOT NULL,
//	    email      TEXT NOT NULL,
//	    payload    JSONB,
//	    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
//	);
//
// Build:
//
//	go mod init rds-writer && go mod tidy
//	GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o lab06 main.go
//	zip lab06-lambda.zip lab06     # runtime: provided.al2023, arch: arm64
package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/url"
	"os"
	"sync"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	_ "github.com/lib/pq"
)

// Matches the JSON shape of RDS-managed / rotation-compatible secrets.
type dbSecret struct {
	Username string      `json:"username"`
	Password string      `json:"password"`
	Host     string      `json:"host"`
	Port     json.Number `json:"port"`
	DBName   string      `json:"dbname"`
}

type Event struct {
	Name    string          `json:"name"`
	Email   string          `json:"email"`
	Payload json.RawMessage `json:"payload,omitempty"`
}

type Response struct {
	ID int64 `json:"id"`
}

var (
	mu sync.Mutex
	db *sql.DB // reused across warm invocations
	sm *secretsmanager.Client
)

func init() {
	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		panic(fmt.Sprintf("load aws config: %v", err))
	}
	sm = secretsmanager.NewFromConfig(cfg)
}

func openDB(ctx context.Context) (*sql.DB, error) {
	arn := os.Getenv("DB_SECRET_ARN")
	if arn == "" {
		return nil, errors.New("DB_SECRET_ARN is not set")
	}

	out, err := sm.GetSecretValue(ctx, &secretsmanager.GetSecretValueInput{SecretId: aws.String(arn)})
	if err != nil {
		return nil, fmt.Errorf("get secret: %w", err)
	}
	if out.SecretString == nil {
		return nil, errors.New("secret has no SecretString")
	}

	var s dbSecret
	if err := json.Unmarshal([]byte(*out.SecretString), &s); err != nil {
		return nil, fmt.Errorf("parse secret: %w", err)
	}

	host := firstNonEmpty(os.Getenv("DB_HOST"), s.Host)
	name := firstNonEmpty(os.Getenv("DB_NAME"), s.DBName, "postgres")
	port := firstNonEmpty(s.Port.String(), "5432")
	ssl := firstNonEmpty(os.Getenv("DB_SSLMODE"), "require")
	if host == "" {
		return nil, errors.New("no host in secret or DB_HOST")
	}

	// url.URL handles escaping of special characters in the password.
	u := url.URL{
		Scheme:   "postgres",
		User:     url.UserPassword(s.Username, s.Password),
		Host:     host + ":" + port,
		Path:     name,
		RawQuery: "sslmode=" + ssl + "&connect_timeout=5",
	}

	conn, err := sql.Open("postgres", u.String())
	if err != nil {
		return nil, fmt.Errorf("open db: %w", err)
	}
	// One Lambda execution environment handles one request at a time.
	conn.SetMaxOpenConns(1)
	conn.SetMaxIdleConns(1)
	conn.SetConnMaxLifetime(5 * time.Minute)

	if err := conn.PingContext(ctx); err != nil {
		conn.Close()
		return nil, fmt.Errorf("ping db: %w", err)
	}
	return conn, nil
}

// getDB returns a live connection, re-reading the secret if the cached
// connection is dead (e.g. after a password rotation).
func getDB(ctx context.Context) (*sql.DB, error) {
	mu.Lock()
	defer mu.Unlock()

	if db != nil {
		if err := db.PingContext(ctx); err == nil {
			return db, nil
		}
		db.Close()
		db = nil
	}

	conn, err := openDB(ctx)
	if err != nil {
		return nil, err
	}
	db = conn
	return db, nil
}

func handler(ctx context.Context, ev Event) (Response, error) {
	if ev.Name == "" || ev.Email == "" {
		return Response{}, errors.New("name and email are required")
	}

	conn, err := getDB(ctx)
	if err != nil {
		return Response{}, err
	}

	// lib/pq wants jsonb as string (or nil), not []byte.
	var payload any
	if len(ev.Payload) > 0 {
		payload = string(ev.Payload)
	}

	var id int64
	err = conn.QueryRowContext(ctx,
		`INSERT INTO events (name, email, payload) VALUES ($1, $2, $3) RETURNING id`,
		ev.Name, ev.Email, payload,
	).Scan(&id)
	if err != nil {
		return Response{}, fmt.Errorf("insert: %w", err)
	}
	return Response{ID: id}, nil
}

func firstNonEmpty(vals ...string) string {
	for _, v := range vals {
		if v != "" {
			return v
		}
	}
	return ""
}

func main() {
	lambda.Start(handler)
}
