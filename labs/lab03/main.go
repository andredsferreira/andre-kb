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


// Setup default logger to output JSON (aswell as extra field service).
func init() {
	logHandler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelDebug,
	})
	logger := slog.New(logHandler).With("service", "lab03")
	slog.SetDefault(logger)
}

// Register metrics with custom registry.
func init() {
	handler.CustomRegistry.MustRegister(handler.HttpRequestTotal)
}

func main() {

	app := fiber.New(fiber.Config{
		ServerHeader: "Fiber",
		AppName:      "LAB03",
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	})

	// Register before middleware so it's excluded from tracking.
	app.Get("/metrics", handler.PrometheusHandler())

	/********************************************************************************/
	/* Middleware
	/********************************************************************************/

	app.Use(middleware.RequestMetricsMiddleware())

	/********************************************************************************/
	/* Routes
	/********************************************************************************/

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("LAB03: Fiber Service with Prometheus and Grafana")
	})

	app.Get("/health", func(c *fiber.Ctx) error {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status": "ok",
		})
	})

	/********************************************************************************/
	/* Server process
	/********************************************************************************/

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
