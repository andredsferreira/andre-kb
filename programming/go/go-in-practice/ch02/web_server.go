package ch02

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func gracefulShutdownsUsingSignals() {

	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		query := r.URL.Query()
		name := query.Get("name")
		if name == "" {
			name = "Inigo Montoya"
		}
		fmt.Fprint(w, "Hello, my name is ", name)
	})

	server := &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	// Setting up a channel to listen for specific signals.
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, os.Interrupt, syscall.SIGTERM)

 // Run server in separate go routine so it doesn't block the listening of
 // signals above.
	go func() {
		log.Println("listening on :8080...")
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	time.Sleep(5 * time.Second)
	// Block until signal is received.
	<-ch

	// Shutting down the server.
	// It will handle current HTTP requests tho.
	if err := server.Shutdown(context.Background()); err != nil {
		panic(err)
	}
}
