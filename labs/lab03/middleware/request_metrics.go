package middleware

import (
	"andrekb/lab03/handler"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

func RequestMetricsMiddleware() fiber.Handler {
	return func(c *fiber.Ctx) error {
		err := c.Next()

		path := c.Route().Path
		method := c.Method()
		status := strconv.Itoa(c.Response().StatusCode())

		handler.HttpRequestTotal.WithLabelValues(path, method, status).Inc()

		return err
	}
}
