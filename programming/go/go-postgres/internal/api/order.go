package httpapi

import (
	"errors"

	"github.com/gofiber/fiber/v2"

	"andrekb/go-postgres/internal/order"
)

func (h *Handler) getOrder(c *fiber.Ctx) error {
	id := c.Params("id")

	o, err := h.orderSvc.GetOrder(c.Context(), id)
	if err != nil {
		if errors.Is(err, order.ErrNotFound) {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "order not found"})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "internal error"})
	}

	return c.Status(fiber.StatusOK).JSON(o)
}

func (h *Handler) createOrder(c *fiber.Ctx) error {
	var o order.Order
	if err := c.BodyParser(&o); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid body"})
	}

	if err := h.orderSvc.CreateOrder(c.Context(), o); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "internal error"})
	}

	return c.SendStatus(fiber.StatusCreated)
}