package httpapi

import (
	"github.com/gofiber/fiber/v2"

	"andrekb/go-postgres/internal/order"
)

type Handler struct {
	app      *fiber.App
	orderSvc *order.Service
}

func NewHandler(orderSvc *order.Service) *Handler {
	h := &Handler{
		app:      fiber.New(),
		orderSvc: orderSvc,
	}
	h.routes()
	return h
}

func (h *Handler) routes() {
	h.app.Get("/orders/:id", h.getOrder)
	h.app.Post("/orders", h.createOrder)
}

func (h *Handler) App() *fiber.App {
	return h.app
}