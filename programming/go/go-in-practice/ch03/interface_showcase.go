package ch03

import (
	"fmt"
	"math/rand"
)

type animal interface {
	bite() int
}

type tiger struct {
}

type dog struct {
	friendly bool
}

// Value receiver in this method.
func (t tiger) bite() int {
	fmt.Println("Im a tiger bitting!")
	return rand.Intn(10)
}

// Value receiver in this method.
func (d dog) bite() int {
	fmt.Println("Im a dog bitting!")
	if d.friendly {
		fmt.Println("But i'm friendly.")
		return rand.Intn(2)
	}
	return rand.Intn(5)
}

// Pointer receiver in this method (changes the object)
func (d *dog) turnFriendly() {
	if !d.friendly {
		d.friendly = true
	}
}
