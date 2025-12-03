package main

import (
	"github.com/ansrivas/fiberprometheus/v2"
	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New()

	prom := fiberprometheus.New("production_ready_hello_world")

	prom.RegisterAt(app, "/metrics")
	app.Use(prom.Middleware)

	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "Hello, World!",
		})
	})

	app.Listen(":8080")
}
