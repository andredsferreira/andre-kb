package main

func longestPalindromicSubstring(input string) string {
	var answer string
	for i := 0; i < len(input); i++ {
		for j := i + 1; j < len(input); j++ {
			substring := input[i:j]
			if isPalindrome(substring) && len(substring) > len(answer) {
				answer = substring
			}
		}
	}
	return answer
}

func isPalindrome(input string) bool {
	if len(input) == 1 || len(input) == 0 {
		return true
	}
	for i := 0; i < len(input)/2; i++ {
		if input[i] != input[len(input)-1-i] {
			return false
		}
	}
	return true
}
