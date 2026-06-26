package main

import (
	"github.com/gofiber/fiber/v2"

	"andrekb/lab08/db"
	"andrekb/lab08/handler"
)

func main() {
	db.Setup()
	defer db.CockroachDB.Close()

	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("LAB08: Containerizing Go Application")
	})

	app.Get("/users", handler.GetUsers)

	app.Listen(":8080")

}
