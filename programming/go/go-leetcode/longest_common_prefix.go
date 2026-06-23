package main

func longestCommonPrefix(strs []string) string {
	shortest := strs[0]
	for _, str := range strs {
		if len(str) < len(shortest) {
			shortest = str
		}
	}
	for index, val := range shortest {
		for _, str := range strs {
			if rune(str[index]) != val {
				return shortest[:index]
			}
		}
	}
	return shortest
}
