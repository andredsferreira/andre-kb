package ch03

import (
	"fmt"
	"testing"
)

func Test_bite(t *testing.T) {
	var a animal

	// If the method bite expected a pointer receiver then the assignment of the
	// variable a should be like this:
	// a = &tiger{}
	// Notice the "&". If you wan't you can experiment going to interface_showcase.go
	// and adding a "*" to the method on the tiger, making it a pointer receiver. Then
	// return here to see the error message.

	a = tiger{}

	a.bite()

	a = dog{
		friendly: false,
	}
	biteForce := a.bite()
	// Cannot do this (method is specific to dog not animal interface):
	// a.turnFriendly()

	d := dog{
		friendly: true,
	}
	d.bite()

	fmt.Printf("The bite force of dog 1 was: %d\n", biteForce)
}
