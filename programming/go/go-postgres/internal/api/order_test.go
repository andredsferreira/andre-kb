package httpapi_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"andrekb/go-postgres/internal/api"
	"andrekb/go-postgres/internal/order"
)

// reuse the same fakeStore approach as order_test.go; in a real project this
// would likely live in a shared internal test helper package, e.g. order/ordertest.
type fakeStore struct {
	orders map[string]order.Order
}

func newFakeStore() *fakeStore {
	return &fakeStore{orders: make(map[string]order.Order)}
}

func (f *fakeStore) GetOrder(ctx context.Context, id string) (order.Order, error) {
	o, ok := f.orders[id]
	if !ok {
		return order.Order{}, order.ErrNotFound
	}
	return o, nil
}

func (f *fakeStore) CreateOrder(ctx context.Context, o order.Order) error {
	f.orders[o.ID] = o
	return nil
}

func TestGetOrder_OK(t *testing.T) {
	store := newFakeStore()
	store.orders["123"] = order.Order{ID: "123", Status: "pending"}
	handler := httpapi.NewHandler(order.NewService(store))

	req := httptest.NewRequest(http.MethodGet, "/orders/123", nil)
	resp, err := handler.App().Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("got status %d, want %d", resp.StatusCode, http.StatusOK)
	}

	var got order.Order
	if err := json.NewDecoder(resp.Body).Decode(&got); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if got.ID != "123" || got.Status != "pending" {
		t.Errorf("got %+v, want ID=123 Status=pending", got)
	}
}

func TestGetOrder_NotFound(t *testing.T) {
	store := newFakeStore()
	handler := httpapi.NewHandler(order.NewService(store))

	req := httptest.NewRequest(http.MethodGet, "/orders/missing", nil)
	resp, err := handler.App().Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("got status %d, want %d", resp.StatusCode, http.StatusNotFound)
	}
}

func TestCreateOrder_Created(t *testing.T) {
	store := newFakeStore()
	handler := httpapi.NewHandler(order.NewService(store))

	body, _ := json.Marshal(order.Order{ID: "789", Status: "new"})
	req := httptest.NewRequest(http.MethodPost, "/orders", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := handler.App().Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("got status %d, want %d", resp.StatusCode, http.StatusCreated)
	}

	if _, err := store.GetOrder(context.Background(), "789"); err != nil {
		t.Errorf("order was not persisted in store: %v", err)
	}
}

func TestCreateOrder_InvalidBody(t *testing.T) {
	store := newFakeStore()
	handler := httpapi.NewHandler(order.NewService(store))

	req := httptest.NewRequest(http.MethodPost, "/orders", bytes.NewReader([]byte("not json")))
	req.Header.Set("Content-Type", "application/json")

	resp, err := handler.App().Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("got status %d, want %d", resp.StatusCode, http.StatusBadRequest)
	}
}