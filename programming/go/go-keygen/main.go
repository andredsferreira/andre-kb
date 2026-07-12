package main

import (
	"crypto/rand"
	"encoding/base64"
	"log"

	"github.com/gofiber/fiber/v3"
)

type keyResponse struct {
	Key string `json:"key"`
}

func generateKey(n int) (string, error) {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return base64.URLEncoding.EncodeToString(b), nil
}

func main() {
	app := fiber.New()

	app.Get("/", func(c fiber.Ctx) error {
		key, err := generateKey(32)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "failed to generate key",
			})
		}

		return c.JSON(keyResponse{Key: key})
	})

	log.Fatal(app.Listen(":8080"))
}
