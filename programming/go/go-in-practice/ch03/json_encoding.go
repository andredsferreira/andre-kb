package ch03

import (
	"encoding/json"
	"fmt"
)

type person struct {
	// Fields must be capitalized in order to be accessed by encoding/json.
	Name   string `json:"name"`
	Height int    `json:"height"`
}

func jsonEncoding() {
	p := person {
		Name: "André",
		Height: 170,
	}

	out, err := json.Marshal(p)
	if err != nil {
		panic("couldn't encode json")
	}

	fmt.Println(string(out))
}

