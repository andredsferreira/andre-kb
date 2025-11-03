package stdlib

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// Making a simple request with the http client. The steps are:
// 1. Instantiate a client type.
// 2. Create the request.
// 3. Attach any headers to the request (optional).
// 4. Send the request from client.

func httpClientRequest() {
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	req, err := http.NewRequest(http.MethodGet, "https://ifconfig.me", nil)
	if err != nil {
		panic(err)
	}

	req.Header.Add("My-Client", "Im learning Go!")

	res, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		panic(fmt.Sprintf("unexpected status: %v", res.Status))
	}

	fmt.Println(res)
}

// Making a request to a REST API and unmarshalling the body to a struct.

func httpClientRequestRestApi() {
	type Post struct {
		UserID int    `json:"userId"`
		ID     int    `json:"id"`
		Title  string `json:"title"`
		Body   string `json:"body"`
	}

	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	req, err := http.NewRequest(http.MethodGet,
		"https://jsonplaceholder.typicode.com/posts", nil)
	if err != nil {
		panic(err)
	}

	res, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		panic(err)
	}

	var posts []Post
	err = json.Unmarshal(body, &posts)
	if err != nil {
		panic(err)
	}

	for _, post := range posts {
		fmt.Printf("Post ID: %d, Title: %s\n", post.ID, post.Title)
	}

}

// To serve http with the server we need to associate handlers with the server.
// The response writer allows to set important fields for the response of an associated
// request. The fields need to be setted in this order: Header, WriteHeader, Write.
// Header is for the header content; WriteHeader allows to set the status code (not
// needed for status code 200); Write sets the body for the response.
// The first example only handles one request.

func simpleHttpServer() {
	helloHandler := func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello!\n"))
	}

	s := http.Server{
		Addr:         "localhost:8080",
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 90 * time.Second,
		IdleTimeout:  120 * time.Second,
		Handler:      http.HandlerFunc(helloHandler),
	}
	err := s.ListenAndServe()
	if err != nil {
		if err != http.ErrServerClosed {
			panic(err)
		}
	}
}
