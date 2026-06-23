package basics

import "fmt"

// Declare behaviour of Engine.

type Engine interface {
	Run()
}

// Different engines for testing.

type BasicEngine struct {
}

type SportsEngine struct {
}

type RacingEngine struct {
}

// Implementing the interface engine on the different engines.

func (basicEngine BasicEngine) Run() {
	fmt.Println("Running a basic engine...")
}

func (sportsEngine SportsEngine) Run() {
	fmt.Println("Running a sports engine...")
}

func (racingEngine RacingEngine) Run() {
	fmt.Println("Running a racing engine...")
}

// Car depends on the interface not concrete implementation.

type Car struct {
	Name   string
	Engine Engine
}

// Inject the dependency through the constructor.

func NewCar(name string, engine Engine) Car {
	return Car{
		Name:   name,
		Engine: engine,
	}
}
