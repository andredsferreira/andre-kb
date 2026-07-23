package handler

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/adaptor"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	HttpRequestTotal = prometheus.NewCounterVec(prometheus.CounterOpts{
		Name: "api_http_requests_total",
		Help: "Total number of requests processed by the API",
	}, []string{"path", "method", "status"})
)

// Custom registry (without default Go metrics).
var CustomRegistry = prometheus.NewRegistry()

func PrometheusHandler() fiber.Handler {
	h := promhttp.HandlerFor(CustomRegistry, promhttp.HandlerOpts{})
	// We need an adaptor since Prometheus expects handler from net/http but fiber
	// is built on a different http engine entirely.
	return adaptor.HTTPHandler(h)
}
