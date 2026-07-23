package main

import (
	"errors"
	"fmt"
	"log/slog"
	"strings"
)

func main() {
	str := "Hello, world!"
	strUpper, err := myUppercase(str)
	if err != nil {
		slog.Error("failed to uppercase string", "error", err)
		return
	}
	fmt.Println(strUpper)
}

func myUppercase(s string) (string, error) {
	if s == "" {
		return "", errors.New("string cannot be empty")
	}
	return strings.ToUpper(s), nil
}
