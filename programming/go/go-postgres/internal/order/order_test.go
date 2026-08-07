package order_test

import (
	"context"
	"errors"
	"testing"

	"andrekb/go-postgres/internal/order"
)

// fakeStore is a minimal in-memory implementation of order.Store, used only in tests.
type fakeStore struct {
	orders map[string]order.Order

	// optional hooks to force specific error paths
	getErr    error
	createErr error
}

func newFakeStore() *fakeStore {
	return &fakeStore{orders: make(map[string]order.Order)}
}

func (f *fakeStore) GetOrder(ctx context.Context, id string) (order.Order, error) {
	if f.getErr != nil {
		return order.Order{}, f.getErr
	}
	o, ok := f.orders[id]
	if !ok {
		return order.Order{}, order.ErrNotFound
	}
	return o, nil
}

func (f *fakeStore) CreateOrder(ctx context.Context, o order.Order) error {
	if f.createErr != nil {
		return f.createErr
	}
	f.orders[o.ID] = o
	return nil
}

func TestService_GetOrder_Found(t *testing.T) {
	store := newFakeStore()
	store.orders["123"] = order.Order{ID: "123", Status: "pending"}
	svc := order.NewService(store)

	got, err := svc.GetOrder(context.Background(), "123")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got.Status != "pending" {
		t.Errorf("got status %q, want %q", got.Status, "pending")
	}
}

func TestService_GetOrder_NotFound(t *testing.T) {
	store := newFakeStore()
	svc := order.NewService(store)

	_, err := svc.GetOrder(context.Background(), "does-not-exist")
	if !errors.Is(err, order.ErrNotFound) {
		t.Errorf("got err %v, want order.ErrNotFound", err)
	}
}

func TestService_GetOrder_StoreErrorPropagates(t *testing.T) {
	store := newFakeStore()
	store.getErr = errors.New("connection reset")
	svc := order.NewService(store)

	_, err := svc.GetOrder(context.Background(), "123")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
	if errors.Is(err, order.ErrNotFound) {
		t.Error("unexpected ErrNotFound for an unrelated store error")
	}
}

func TestService_CreateOrder(t *testing.T) {
	store := newFakeStore()
	svc := order.NewService(store)

	err := svc.CreateOrder(context.Background(), order.Order{ID: "456", Status: "new"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	got, err := store.GetOrder(context.Background(), "456")
	if err != nil {
		t.Fatalf("order was not persisted: %v", err)
	}
	if got.Status != "new" {
		t.Errorf("got status %q, want %q", got.Status, "new")
	}
}