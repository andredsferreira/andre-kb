package main

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
)

func TestHelloWorld(t *testing.T) {
	testCases := []struct {
		method       string
		route        string
		expectedCode int
		expectedBody map[string]string
	}{
		{
			method:       "GET",
			route:        "/",
			expectedCode: http.StatusOK,
			expectedBody: map[string]string{
				"message": "Hello, World!",
			},
		},
	}

	app := fiber.New()
	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "Hello, World!",
		})
	})

	for _, tc := range testCases {
		req := httptest.NewRequest(tc.method, tc.route, nil)
		resp, err := app.Test(req)
		if err != nil {
			t.Fatalf("Failed to send request: %v", err)
		}

		if resp.StatusCode != tc.expectedCode {
			t.Errorf("Expected status code %d, got %d", tc.expectedCode, resp.StatusCode)
		}

		bodyBytes, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Fatalf("Failed to read response body: %v", err)
		}

		var bodyJSON map[string]string
		if err := json.Unmarshal(bodyBytes, &bodyJSON); err != nil {
			t.Fatalf("Failed to parse JSON: %v", err)
		}

		if bodyJSON["message"] != tc.expectedBody["message"] {
			t.Errorf("Expected body '%v', got '%v'", tc.expectedBody, bodyJSON)
		}
	}
}
