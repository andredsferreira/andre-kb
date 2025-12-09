package ch02

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
)

/********************************************************************************/

// Handling configuration in JSON files.

// Same structure as the JSON.
type configuration struct {
	Enabled bool
	Path    string
}

func loadJSONConfig() {
	file, err := os.Open("config.json")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	decoder := json.NewDecoder(file)
	conf := configuration{}
	if err := decoder.Decode(&conf); err != nil {
		log.Fatal(err)
	}
	fmt.Println(conf.Path)
}

/********************************************************************************/
