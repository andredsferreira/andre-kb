package middleware

import (
	"log"
	"net/http"
	"time"
)

// customResponseWriter wraps http.ResponseWriter to capture the status code

type customResponseWriter struct {
	http.ResponseWriter
	statusCode int
}

func LoggerMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		cw := &customResponseWriter{
			ResponseWriter: w,
			statusCode:     http.StatusOK,
		}
		s := time.Now()
		next.ServeHTTP(cw, r)
		d := time.Since(s).Seconds()
		log.Printf("HTTP %s %s %d %fs\n", r.Method, r.URL.String(), cw.statusCode, d)
	})
}
