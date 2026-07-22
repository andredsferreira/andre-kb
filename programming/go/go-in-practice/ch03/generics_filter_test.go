package ch03

import (
	"fmt"
	"testing"
	"unicode"
)

func Test_filter(t *testing.T) {
	strings := []string{"My", "name", "is", "Inigo", "Montoya"}

	strings = filter(strings, func(s string) bool {
		return unicode.IsUpper(rune(s[0]))
	})

	fmt.Println(strings)
}

func Test_filter_2(t *testing.T) {
	numbers := []int{1, 2, 3, 4, 5, 6}

	numbers = filter(numbers, func(n int) bool {
		return n%2 == 0
	})

	fmt.Println(numbers)
}
