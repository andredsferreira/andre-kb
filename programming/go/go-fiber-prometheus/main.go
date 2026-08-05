package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/adaptor"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/collectors"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

/********************************************************************************/
/* Prometheus metrics
/********************************************************************************/

var (
	reg = prometheus.NewRegistry()

	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "go_app_http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "path", "status"},
	)

	httpRequestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "go_app_http_request_duration_seconds",
			Help:    "HTTP request duration in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"method", "path"},
	)

	// Add more metrics here...
)

/********************************************************************************/
/* Prometheus metrics middleware
/********************************************************************************/

func metricsMiddleware(c fiber.Ctx) error {
	start := time.Now()

	err := c.Next()

	status := c.Response().StatusCode()
	httpRequestsTotal.WithLabelValues(c.Method(), c.Route().Path, fmt.Sprint(status)).Inc()
	httpRequestDuration.WithLabelValues(c.Method(), c.Route().Path).Observe(time.Since(start).Seconds())

	return err
}

/********************************************************************************/
/* Main
/********************************************************************************/

func init() {
	reg.MustRegister(httpRequestsTotal, httpRequestDuration)
	// These are added by the default registry, but since im using a custom one i
	// explictily code them here:
	reg.MustRegister(collectors.NewGoCollector())
	reg.MustRegister(collectors.NewProcessCollector(collectors.ProcessCollectorOpts{}))
}

func main() {
	app := fiber.New(fiber.Config{
		ServerHeader: "Fiber",
		AppName:      "Go & Fiber & Prometheus",
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	})

	app.Get("/metrics", adaptor.HTTPHandler(promhttp.HandlerFor(reg, promhttp.HandlerOpts{})))
	app.Use(metricsMiddleware)

	/********************************************************************************/
	/* Routes
	/********************************************************************************/

	app.Get("/", func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"msg": "Hello, world!",
		})
	})

	app.Get("/health", func(c fiber.Ctx) error {
		return c.SendStatus(fiber.StatusOK)
	})

	/********************************************************************************/
	/* Start server
	/********************************************************************************/

	go func() {
		slog.Info("listening on port 8080")
		if err := app.Listen(":8080"); err != nil {
			slog.Error("server error", "error", err)
			return
		}
	}()

	/********************************************************************************/
	/* Setup signal handling
	/********************************************************************************/

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	/********************************************************************************/
	/* Handle shutdown
	/********************************************************************************/

	slog.Info("shutting down server")
	// Timeout of 10 seconds for pending requests to finish.
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := app.ShutdownWithContext(ctx); err != nil {
		slog.Error("forced shutdown", "error", err)
		os.Exit(1)
	}

	slog.Info("server stopped")
}
