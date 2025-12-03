package middleware

import (
	"net/http"
)

func ServerHeader(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Server", "Andre KB's Go Server")
		next.ServeHTTP(w, r)
	})
}