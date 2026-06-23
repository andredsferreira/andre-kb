package main

import "testing"

func Test_longestCommonPrefix(t *testing.T) {
	tests := []struct {
		strings  []string
		expected string
	}{
		{
			strings:  []string{"flower", "flow", "flight"},
			expected: "fl",
		},
		{
			strings:  []string{"dog", "racecar", "car"},
			expected: "",
		},
		{
			strings:  []string{"", "b", "c"},
			expected: "",
		},
		{
			strings:  []string{"abc", "abcd", "abcde"},
			expected: "abc",
		},
		{
			strings:  []string{"prefix", "prefixed", "prefixes"},
			expected: "prefix",
		},
	}

	for _, tt := range tests {
		result := longestCommonPrefix(tt.strings)
		if result != tt.expected {
			t.Errorf("\ngot: %v; want: %v\n", result, tt.expected)
		}
	}
}
