package core

import (
	"context"
	"database/sql"
	"fmt"
	"io"
	"log"
	"os"
)

// Variadic parameters:
// Must be the only parameter or placed at the end. Under the hood it's just a slice.

func addToBase(base int, values ...int) int {
	answer := base
	for _, v := range values {
		answer += v
	}
	return answer
}

// Multiple return values:
// A function can return multiple values. When called, each value must be assigned to a
// variable.

func multipleValues() (int, int) {
	return 1, 2
}

// Functions are values, this means it's possible to assign variables to them.

func functionValues() {
	var funcVar func(int) int

	funcVar = a
	result := funcVar(2)
	fmt.Println("result from a", result)

	funcVar = b
	result = funcVar(2)
	fmt.Println("result from b", result)

}

func a(x int) int {
	return 2 * x
}

func b(x int) int {
	return 3 * x
}

// Anonymous functions don't have names and they are imediately declared and assigned.
// In the case bellow f() is an anonymous function.

func anonymousFunction() {
	f := func(x int) {
		res := x + 1
		fmt.Println(res)
	}
	for i := 0; i < 4; i++ {
		f(i)
	}
}

// Closures: are functions declared inside another function. Closures are able to access
// and modify variables declared in the outer function.

func closureFunction() {
	a := 20
	f := func() {
		fmt.Println(a)
		a = 30
	}
	f()
	fmt.Println(a)
}

// The defer keyword defers the execution of a function. The execution is defered until
// the surrounding function exits (in the case bellow deferingFunction()).It is used
// mostly to clean up resources. The following function is an example of opening a file
// and reading it's contents using a loop. The defer is used to close the file. It
// finishes reading if the EOF is encountered.

func DeferingFunction() {
	f, err := os.Open("filename")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	buffer := make([]byte, 2048)
	for {
		count, err := f.Read(buffer)
		os.Stdout.Write(buffer[:count])
		if err != nil {
			if err != io.EOF {
				log.Fatal(err)
			}
			break
		}
	}

}

// Named returns are useful when a defer function needs to access the returned value.
// This usually happens when analyzing errors. (See common_patterns.go)

func DoSomeInserts(ctx context.Context, db *sql.DB, value1 string) (err error) {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() {
		if err == nil {
			err = tx.Commit()
		}
		if err != nil {
			tx.Rollback()
		}
	}()
	_, err = tx.ExecContext(ctx, "INSERT INTO FOO (val) values $1", value1)
	if err != nil {
		return err
	}
	// use tx to do more database inserts here
	return nil
}

// Common pattern is when a using a function that allocates a resource. Then that function
// also returns a closure used to clean the resources. (See common_patterns.go)

func GetFile(name string) (*os.File, func(), error) {
	file, err := os.Open(name)
	if err != nil {
		return nil, nil, err
	}
	return file, func() {
		file.Close()
	}, nil
}
