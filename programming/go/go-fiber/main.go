package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/static"
)

func main() {

	app := fiber.New()

	/********************************************************************************/
	// Start server concurrently on a go routine so it doesn't block main.
	/********************************************************************************/

	go func() {
		slog.Info("listening on port 8080")
		if err := app.Listen(":8080"); err != nil {
			slog.Error("server error", "error", err)
			return
		}
	}()

	/********************************************************************************/
	// Setup middleware (with Use method).
	/********************************************************************************/

	// If Use is called with no path then it matches every request: any method any
	// path.
	app.Use(func(c fiber.Ctx) error {
		c.Set("X-Powered-By", "Fiber")
		// Give control to the next middleware.
		return c.Next()
	})

	// If Use is called with a path however it matches every request with that
	// prefix (/api/users, /api/tokens, etc).
	app.Use("/api", func(c fiber.Ctx) error {
		return c.Next()
	})

	// Simple logger middleware example.
	app.Use(func(c fiber.Ctx) error {
		slog.Info("runs before request:", "", c.Method())
		err := c.Next()
		slog.Info("runs after request", "", c.MediaType())
		return err
	})

	// Serving static files (like images, scripts, etc).
	app.Use("/", static.New("./public"))

	/********************************************************************************/
	// Setup endpoints (with HTTP Method and a path).
	/********************************************************************************/

	app.Get("/", func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"msg": "Hello, world!",
		})
	})

	// Named parameter example.
	app.Get("/users/:id", func(c fiber.Ctx) error {
		id := c.Params("id")
		return c.JSON(fiber.Map{
			"user": id,
		})
	})

	// Optional named parameter example.
	app.Get("/users/:name?", func(c fiber.Ctx) error {
		name := c.Params("name")
		return c.JSON(fiber.Map{
			"user_name": name,
		})
	})

	// Multiple named parameters example.
	app.Get("/users/:id/:name", func(c fiber.Ctx) error {
		id := c.Params("id")
		name := c.Params("name")
		return c.JSON(fiber.Map{
			"id":   id,
			"name": name,
		})
	})

	// Multiple named parameters using a seperator (*, -, and : may be used).
	app.Get("/flights/:from-:to", func(c fiber.Ctx) error {
		from := c.Params("from")
		to := c.Params("to")
		return c.JSON(fiber.Map{
			"from": from,
			"to":   to,
		})
	})

	// Greedy wildcard parameter example.
	// Requires at least one character ("/books" wont work at least "/books/mybook").
	app.Get("/books/+", func(c fiber.Ctx) error {
		book := c.Params("+")
		return c.JSON(fiber.Map{
			"book": book,
		})
	})

	// Optional wildcard parameter example.
	// May match nothing ("/tokens" works for example).
	app.Get("/tokens/*", func(c fiber.Ctx) error {
		token := c.Params("*")
		return c.JSON(fiber.Map{
			"token": token,
		})
	})

	// All matches every method to the route (GET /ping, POST /ping, DELETE /ping,
	// etc).

	app.All("/ping", func(c fiber.Ctx) error {
		method := c.Method()
		return c.JSON(fiber.Map{
			"ping_method": method,
		})
	})

	/********************************************************************************/
	// Setup signal handling.
	/********************************************************************************/

	stop := make(chan os.Signal, 1)
	// SIGTERM is specially important here if the app is deployed on Kubernetes.
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	// Block main until some signal of the above is received.
	<-stop

	/********************************************************************************/
	// Graceful shutdown setup.
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
