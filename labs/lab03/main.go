package main

import (
	"andrekb/lab03/handler"
	"andrekb/lab03/middleware"
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Register metrics with custom registry.
func init() {
	handler.CustomRegistry.MustRegister(handler.HttpRequestTotal)
}

func main() {
	app := fiber.New()

	// Register before middleware so it's excluded from tracking.
	app.Get("/metrics", handler.PrometheusHandler())

	app.Use(middleware.RequestMetricsMiddleware())

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("LAB03: Fiber Service with Prometheus and Grafana")
	})

	app.Get("/health", func(c *fiber.Ctx) error {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status": "ok",
		})
	})

	// Other routes...

	go func() {
		slog.Info("listening on port 8080")
		if err := app.Listen(":8080"); err != nil {
			slog.Error("server error", "error", err)
			return
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	<-stop
	slog.Info("shutting down server")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := app.ShutdownWithContext(ctx); err != nil {
		slog.Error("forced shutdown", "error", err)
		os.Exit(1)
	}

	slog.Info("server stopped")
}
