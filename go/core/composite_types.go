package core

import (
	"fmt"
	"strings"
)

func arrays() {
	// Different ways of declaring arrays.

	var a [3]int
	fmt.Println(a)

	var b = [3]int{10, 20, 30}
	fmt.Println(b)

	var c = [...]int{40, 50, 60}
	fmt.Println(c)

	d := [3]int{1, 2, 3}
	fmt.Println(d)

	e := [...]int{4, 5, 6}
	fmt.Println(e)

	// Accessing individual elements.

	fmt.Println("a[1] =", a[1])
	fmt.Println("c[:2] =", c[:2])

	fmt.Println(strings.Repeat("-", 50))
}

func slices() {
	// Different ways of declaring slices.

	var a []string
	fmt.Println(a)

	var b = []string{"Andrew", "Maria", "Jesse"}
	fmt.Println(b)

	c := []int{1, 2, 3}
	fmt.Println(c)

	// Accessing elements.

	fmt.Println("a[1] =", b[0])
	fmt.Println("c[:2] =", c[:2])

	// Iteration (len returns the number of elements in array or slice).

	for i := 0; i < len(b); i++ {
		fmt.Printf("b[%d] = %s\n", i, b[i])
	}

	for k, v := range c {
		fmt.Printf("c[%d] = %d\n", k, v)
	}

	// Appending values with the append function which returns a new slice
	// with the appended element.

	d := append(b, "Celine")
	fmt.Println(d)

	c = append(c, 4)
	fmt.Println("Appended one element to c ->", c)

	e := []int{5, 6, 7, 8, 9, 10}
	c = append(c, e...)
	fmt.Println("Appended a slice to c ->", c)

	// Creating a slice with make allows us to specify its initial capacity.
	// When trying to append to a slice with len = cap the go subroutine
	// extends the capacity of the slice.
	// The make function -> make(slice, initialLen, initialCap)

	f := make([]int, 50)
	fmt.Printf("len(f) = %d  cap(f) = %d\n", len(f), cap(f))

	g := make([]int, 5, 10)
	fmt.Printf("len(g) = %d  cap(g) = %d\n", len(g), cap(g))

	// Example of go subroutine modifying cap when len() = cap()

	var h []rune
	fmt.Printf("len(h) = %d  cap(h) = %d\n", len(h), cap(h))
	h = append(h, 'a')
	fmt.Printf("len(h) = %d  cap(h) = %d\n", len(h), cap(h))
	h = append(h, 'b')
	fmt.Printf("len(h) = %d  cap(h) = %d\n", len(h), cap(h))
	h = append(h, 'c')
	fmt.Printf("len(h) = %d  cap(h) = %d\n", len(h), cap(h))
	h = append(h, 'd')
	fmt.Printf("len(h) = %d  cap(h) = %d\n", len(h), cap(h))
	h = append(h, 'e')
	fmt.Printf("len(h) = %d  cap(h) = %d\n", len(h), cap(h))

	// Emptying slice with clear() keeps the length and capacity.
	// The clear() function actually makes all elements the default value.

	clear(h)
	fmt.Println(h)
	fmt.Printf("len(h) = %d  cap(h) = %d\n", len(h), cap(h))

	fmt.Println(strings.Repeat("-", 50))
}

func slicingSclices() {
	// Basic slicing: the last specified element is not included.

	x := []string{"a", "b", "c", "d"}

	a := x[:2] // index 2 not included
	b := x[1:]
	c := x[1:3]
	d := x[:]

	fmt.Println("x:", x)
	fmt.Println("a:", a)
	fmt.Println("b:", b)
	fmt.Println("c:", c)
	fmt.Println("d:", d)

	// Slicing does not make a copy of the data. If more than one variable
	// slices the same array then changes to one variable may modify the other.
	// This happens if they overlap.

	e := x[:2]
	f := x[1:]

	x[1] = "y"
	e[0] = "x"
	f[1] = "z"

	fmt.Println("x:", x)
	fmt.Println("e:", e)
	fmt.Println("f:", f)

	// When needing a new slice that's independent of the original use the
	// copy() function: copy(src, dest)

	var y []string
	copy(y, x)

	fmt.Println(strings.Repeat("-", 50))
}

func maps() {
	// Declaring maps

	// Before calling or assigning values to a map you need to initialize it.
	// The declaration bellow is a nil map, meaning no values can be called or
	// assigned.

	var a map[int]string
	fmt.Println("nil map:", a)

	b := map[string]int{}
	fmt.Println(b)

	c := map[string]int{
		"apple":     5,
		"banana":    3,
		"orange":    5,
		"pear":      4,
		"peach":     4,
		"pineapple": 1,
	}
	fmt.Println(c)

	// Iterating maps, done with the for range loop

	for k, v := range c {
		fmt.Println(k, v)
	}

	fmt.Println(strings.Repeat("-", 50))

}