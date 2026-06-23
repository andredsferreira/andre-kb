package main

import "testing"

func Test_longestPalindromicString(t *testing.T) {
	
	tests := []struct {
		inputString    string
		expectedAnswer string
	}{
		{
			inputString:    "babad",
			expectedAnswer: "bab",
		},
		{
			inputString:    "cbbd",
			expectedAnswer: "bb",
		},
	}

	for _, tt := range tests {
		result := longestPalindromicSubstring(tt.inputString)
		if result != tt.expectedAnswer {
			t.Errorf("\ngot: %v want: %v\n", result, tt.expectedAnswer)
		}
	}

}
