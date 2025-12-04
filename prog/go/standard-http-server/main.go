package main

import (
	"log"
	"net/http"

	"andrekb/standard-http-server/handlers"
	"andrekb/standard-http-server/middleware"
)

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/", handlers.HelloHandler)

	log.Println("listening on :8080...")
	err := http.ListenAndServe(":8080", middleware.ServerHeader(
		middleware.LoggerMiddleware(mux)))

	log.Fatal(err)
}
