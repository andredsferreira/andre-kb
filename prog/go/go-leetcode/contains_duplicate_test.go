package main

import (
	"testing"
)

func Test_hasDuplicate(t *testing.T) {
	testCases := []struct {
		nums   []int
		expect bool
	}{
		{
			nums:   []int{1, 2, 3, 1},
			expect: true,
		},
		{
			nums:   []int{1, 2, 3, 4},
			expect: false,
		},
		{
			nums:   []int{1, 1, 1, 3, 3, 4, 3, 2, 4, 2},
			expect: true,
		},
	}
	for _, tC := range testCases {
		ans := hasDuplicate(tC.nums)
		if ans != tC.expect {
			t.Errorf("\ngot: %v want: %v\n", ans, tC.expect)
		}
	}
}
