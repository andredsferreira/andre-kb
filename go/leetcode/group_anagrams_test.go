package leetcode

import (
	"sort"
	"testing"
)

func Test_groupAnagrams(t *testing.T) {
	testCases := []struct {
		strs   []string
		expect [][]string
	}{
		{
			strs:   []string{"eat", "tea", "tan", "ate", "nat", "bat"},
			expect: [][]string{{"bat"}, {"nat", "tan"}, {"ate", "eat", "tea"}},
		},
		{
			strs:   []string{""},
			expect: [][]string{{""}},
		},
		{
			strs:   []string{"a"},
			expect: [][]string{{"a"}},
		},
	}
	for _, tC := range testCases {
		ans := groupAnagrams(tC.strs)
		if !areSlicesEqual(ans, tC.expect) {
			t.Errorf("\ngot: %v want: %v\n", ans, tC.expect)
		}
	}
}

func areSlicesEqual(a, b [][]string) bool {
	if len(a) != len(b) {
		return false
	}

	// Sort each inner slice of strings
	for i := range a {
		sort.Strings(a[i]) // Sort the strings within each slice
		sort.Strings(b[i]) // Sort the strings within each slice
	}

	// Sort the outer slices based on the content of each sub-slice
	sort.Slice(a, func(i, j int) bool {
		return len(a[i]) < len(a[j]) || (len(a[i]) == len(a[j]) && compareSlices(a[i], a[j]))
	})

	sort.Slice(b, func(i, j int) bool {
		return len(b[i]) < len(b[j]) || (len(b[i]) == len(b[j]) && compareSlices(b[i], b[j]))
	})

	// Compare the sorted slices
	for i := range a {
		if !compareSlices(a[i], b[i]) {
			return false
		}
	}

	return true
}

// Helper function to compare two slices of strings
func compareSlices(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}
