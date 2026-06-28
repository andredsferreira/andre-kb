CREATE DATABASE IF NOT EXISTS "lab03-db";
USE "lab03-db";

CREATE TABLE IF NOT EXISTS users (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username   STRING NOT NULL UNIQUE,
    email      STRING NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO users (username, email) VALUES
    ('alice',   'alice@example.com'),
    ('bob',     'bob@example.com'),
    ('charlie', 'charlie@example.com'),
    ('diana',   'diana@example.com'),
    ('eve',     'eve@example.com')
ON CONFLICT DO NOTHING;