package core

import (
	"fmt"
	"testing"
)

func TestFunctions(t *testing.T) {
	addToBase(1, 0)
	a, b := multipleValues()
	fmt.Println(a, b)
	functionValues()
	anonymousFunction()
	fmt.Println("Closure function:")
	closureFunction()
	// deferingFunction()
	// doSomeInserts(context.TODO(), nil, "nothing")

	//  Demonstrating the pattern on the getFile() function.

	// _, closer, err := getFile("filename")
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// defer closer()

}