package core

import (
	"crypto/rsa"
	"fmt"
	"io"
	"testing"
)

func TestDivisionWithNewErrorHandling(t *testing.T) {
	result, err := divisionWithNewErrorHandling(2, 0)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(result)
	}
}

func TestEvenPowerWithErrorfHandling(t *testing.T) {
	result, err := evenPowerWithErrofHandling(3)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(result)
	}
}

// Refer to go-notes.md to read about sentinel errors.
// Common examples incldue the io.EOF that indicates the end of file has been reached.
// Or the rsa.ErrMessageTooLong that indicates a message cannot be encrypted because
// it is too long for the provided public key.

func TestSentinelErrors(t *testing.T) {
	fmt.Println(io.EOF)
	fmt.Println(rsa.ErrMessageTooLong)
}
