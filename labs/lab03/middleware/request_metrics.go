package middleware

import (
	"andrekb/lab03/handler"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
)

func RequestMetricsMiddleware() fiber.Handler {
	return func(c *fiber.Ctx) error {
		start := time.Now()
		err := c.Next()

		path := c.Route().Path
		method := c.Method()

		code := c.Response().StatusCode()
		if err != nil {
			code = fiber.StatusInternalServerError
			if fe, ok := err.(*fiber.Error); ok {
				code = fe.Code
			}
		}
		status := strconv.Itoa(code)

		handler.HttpRequestTotal.WithLabelValues(path, method, status).Inc()
		handler.HttpRequestDuration.WithLabelValues(c.Method(), c.Route().Path).Observe(time.Since(start).Seconds())

		return err
	}
}
