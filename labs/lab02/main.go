package main

import (
	"github.com/gofiber/fiber/v2"

	"andrekb/lab02/db"
	"andrekb/lab02/handler"
)

func main() {
	db.Setup()
	defer db.CockroachDB.Close()

	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("LAB03: Containerizing Go Application")
	})

	app.Get("/users", handler.GetUsers)

	app.Listen(":8080")

}
