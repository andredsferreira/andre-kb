package main

import (
	"context"

	"github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	StatusCode int    `json:"statusCode"`
	Body       string `json:"body"`
}

func handler(ctx context.Context) (Response, error) {
	resp := Response{
		StatusCode: 200,
		Body:       "Hello, World!",
	}
	return resp, nil
}

func main() {
	lambda.Start(handler)
}
