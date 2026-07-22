// Demonstration of Go generics for filtering (their main use case).
// IMPORTANT: You can't access individual fields with Go generics!

package ch03

func filter[T any](items []T, fx func(T) bool) []T {
	var filtered []T
	for _, v := range items {
		if fx(v) {
			filtered = append(filtered, v)
		}
	}
	return filtered
}

type Numeric interface {
	int8 | int16 | int32 | int64 | float32 | float64
}

func filterPositive[T Numeric](nums []T) []T {
	var filtered []T
	for _, v := range nums {
		if v > 0 {
			filtered = append(filtered, v)
		}
	}
	return filtered
}
