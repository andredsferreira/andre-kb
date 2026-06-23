package basics

import (
	"context"
	"database/sql"
	"errors"
	"io"
	"os"
)

// Eventhough go is a garbage collected language having a slice as a buffer to store the
// readed data is the way to go! This avoids new memory allocations each time we are
// processing a piece of data. Instead, we have one buffer that stores that data and
// only process the readed bytes each time (remember count is the number of bytes
// readed).

func slicesAsBuffers() error {
	file, err := os.Open("filename")
	if err != nil {
		return err
	}
	defer file.Close()
	data := make([]byte, 100)
	for {
		count, err := file.Read(data)
		processData(data[:count])
		if err != nil {
			if errors.Is(err, io.EOF) {
				return nil
			}
			return err
		}
	}
}

func processData(data []byte) {

}

// This is a common pattern for database transactions where we have a named return
// for the error (named err). The named returned is used so the defer anonymous
// function can access the error.

func DbTransaction(ctx context.Context, db *sql.DB, val string) (err error) {
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
	_, err = tx.ExecContext(ctx, "INSERT INTO FOO (val) values $1", val)
	if err != nil {
		return err
	}
	// Use tx to do more database inserts here
	return nil
}
