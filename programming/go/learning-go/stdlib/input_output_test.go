package stdlib

import (
	"fmt"
	"log"
	"strings"
	"testing"
)

func TestReadStringWithScanner(t *testing.T) {
	fmt.Println("\nTest read string with scanner")
	ReadStringWithScanner()
	fmt.Println()
}

func TestCountLetters(t *testing.T) {
	fmt.Println("\nTest count letters")
	stringReader := strings.NewReader("My name is André and im an okay programmer. Im loving learning the Go programming language!")
	lettersMap, err := CountLetters(stringReader)
	if err != nil {
		log.Println(err)
	}
	for k, v := range lettersMap {
		fmt.Printf("Letter : %v -> %v\n", k, v)
	}
	fmt.Println()
}
