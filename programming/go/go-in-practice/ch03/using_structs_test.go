package ch03

import (
	"fmt"
	"testing"
)

func Test_description(t *testing.T) {
	myCar := car{
		make:  "Mitsubishi",
		model: "Lancer",
		year:  2004,
	}

	cars := []car{
		{make: "Toyota", model: "Corolla", year: 2020},
		{make: "Honda", model: "Civic", year: 2021},
		{make: "Ford", model: "Focus", year: 2019},
	}

	fmt.Println("My car: ")
	myCar.description()
	fmt.Println()

	fmt.Println("Available cars:")
	for i, c := range cars {
		fmt.Println(i + 1, "==============")
		c.description()
	}


}
