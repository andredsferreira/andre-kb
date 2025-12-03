package main

import (
	"log"
	"net/http"

	"andrekb.com/standard-http-server/middleware"
)

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello, World!"))
	})

	log.Println("listening on :8080...")
	err := http.ListenAndServe(":8080", middleware.ServerHeader(
		middleware.LoggerMiddleware(mux)))
		
	log.Fatal(err)
}
