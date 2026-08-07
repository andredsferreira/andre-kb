package order

import (
	"context"
	"errors"
)

var ErrNotFound = errors.New("order not found")

type Order struct {
	ID     string
	Status string
}

// Store is the interface Service needs. Defined here, in the consuming
// package, not in postgres. postgres.OrderStore will satisfy it implicitly.
type Store interface {
	GetOrder(ctx context.Context, id string) (Order, error)
	CreateOrder(ctx context.Context, o Order) error
}

type Service struct {
	store Store
}

func NewService(store Store) *Service {
	return &Service{store: store}
}

func (s *Service) GetOrder(ctx context.Context, id string) (Order, error) {
	return s.store.GetOrder(ctx, id)
}

func (s *Service) CreateOrder(ctx context.Context, o Order) error {
	// business rules/validation would go here
	return s.store.CreateOrder(ctx, o)
}