package postgres

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"andrekb/go-postgres/internal/order"
)

type OrderStore struct {
	pool *pgxpool.Pool
}

func NewOrderStore(pool *pgxpool.Pool) *OrderStore {
	return &OrderStore{pool: pool}
}

func (s *OrderStore) GetOrder(ctx context.Context, id string) (order.Order, error) {
	var o order.Order
	err := s.pool.QueryRow(ctx,
		`SELECT id, status FROM orders WHERE id = $1`, id,
	).Scan(&o.ID, &o.Status)

	if err != nil {
		// Translating error to be more readable.
		if errors.Is(err, pgx.ErrNoRows) {
			return order.Order{}, order.ErrNotFound
		}
		return order.Order{}, fmt.Errorf("get order %s: %w", id, err)
	}
	return o, nil
}

func (s *OrderStore) CreateOrder(ctx context.Context, o order.Order) error {
	_, err := s.pool.Exec(ctx,
		`INSERT INTO orders (id, status) VALUES ($1, $2)`, o.ID, o.Status,
	)
	if err != nil {
		return fmt.Errorf("create order %s: %w", o.ID, err)
	}
	return nil
}
