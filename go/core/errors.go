package core

import (
	"errors"
	"fmt"
)

// There are two ways to create errors from strings: using errors.New() and
// using the fmt.Errorf()

func divisionWithNewErrorHandling(numerator int, denominator int) (int, error) {
	if denominator == 0 {
		return 0, errors.New("denominator is 0")
	}
	return numerator / denominator, nil
}

func evenPowerWithErrofHandling(num int) (int, error) {
	if num%2 != 0 {
		return 0, fmt.Errorf("%d is not even", num)
	}
	return num * num, nil
}
