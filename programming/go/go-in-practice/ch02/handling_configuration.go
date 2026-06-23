package ch02

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/go-yaml/yaml"

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

// Handling configuration in YAML files.

func loadYAMLConfig() {
	file, err := os.Open("config.yaml")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	decoder := yaml.NewDecoder(file)
	conf := configuration{}
	if err := decoder.Decode(&conf); err != nil {
		log.Fatal(err)
	}
	fmt.Println(conf.Path)
}


/********************************************************************************/
