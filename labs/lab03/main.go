package main

import (
	"andrekb/lab03/db"
	"andrekb/lab03/service"
	"log"

	"github.com/gofiber/fiber/v3"
)

func main() {
	db.Setup()

	app := fiber.New()

	app.Get("/", func(c fiber.Ctx) error {
		return c.SendString("Lab03")
	})

	app.Get("/users", func(c fiber.Ctx) error {
		users, err := service.GetUsers()
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": err.Error(),
			})
		}
		return c.JSON(users)
	})

	app.Get("/users/:username", func(c fiber.Ctx) error {
		username := c.Params("username")
		user, err := service.GetUserByUsername(username)
		if err != nil {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": err.Error(),
			})
		}
		return c.JSON(user)
	})

	log.Fatal(app.Listen(":3000"))
}
