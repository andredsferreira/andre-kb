package main

import (
	"context"
	"log"
	"os"

	"andrekb/go-postgres/internal/api"
	"andrekb/go-postgres/internal/order"
	"andrekb/go-postgres/internal/postgres"
)

func main() {
	ctx := context.Background()

	pool, err := postgres.NewPool(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatalf("connect to db: %v", err)
	}
	defer pool.Close()

	orderStore := postgres.NewOrderStore(pool)
	orderSvc := order.NewService(orderStore)
	handler := httpapi.NewHandler(orderSvc)

	log.Println("listening on :8080")
	if err := handler.App().Listen(":8080"); err != nil {
		log.Fatal(err)
	}
}