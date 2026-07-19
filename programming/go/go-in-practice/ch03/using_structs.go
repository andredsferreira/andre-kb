package ch03

import "fmt"

// Lowercase "car" makes the struct accessible only in this package. To make it
// globally accessible it needs to be "Car".

type car struct {
	// Same lowercase/uppercase logic applies to the fields.
	make  string
	model string
	year  int
}

func (c car) description() {
	fmt.Printf("Make = %s\nModel = %s\nYear = %d\n", c.make, c.model, c.year)
}


