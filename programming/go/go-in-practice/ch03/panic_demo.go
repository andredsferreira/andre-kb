package ch03

import (
	"errors"
	"fmt"
	"log"
)

func a() {
	defer fmt.Println("defered a")
	c()
	fmt.Println("Never reaches this line!")
}

func b() {
	defer fmt.Println("defered b")
	d()
	fmt.Println("Reaches this line (recovered panic)!")
}


func c() {
	defer fmt.Println("defered c")
	e()
	fmt.Println("Never reaches this line!")
}

func d() {
	defer func() {
		if err := recover(); err != nil {
			log.Println("trapped panic")
		}
	}()
	e()
	fmt.Println("Never reaches this line!")
}

func e() {
	panic(errors.New("panic at e"))
}