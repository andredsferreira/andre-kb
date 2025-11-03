package core

import (
	"fmt"
	"testing"
)

func TestDependencyInjection(t *testing.T) {
	fmt.Println("\nDependency injection demonstration")
	fmt.Println()
	basicCar := NewCar("Basic car", BasicEngine{})
	sportsCar := NewCar("Sports car", SportsEngine{})
	racingCar := NewCar("Racing car", RacingEngine{})
	basicCar.Engine.Run()
	sportsCar.Engine.Run()
	racingCar.Engine.Run()
	fmt.Println()
}
