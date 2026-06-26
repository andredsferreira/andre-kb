package main

import (
	"github.com/gofiber/fiber/v2"

	"andrekb/lab08/db"
)

func main() {
	db.Setup()
	defer db.PostgresDB.Close()

	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	app.Listen(":8080")

}
