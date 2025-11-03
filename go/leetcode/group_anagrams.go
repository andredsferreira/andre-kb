package leetcode

import "sort"

func groupAnagrams(strs []string) [][]string {
	m := make(map[string][]string)
	ans := make([][]string, 0)
	for _, str := range strs {
		str2 := []rune(str)
		sort.Slice(str2, func(i int, j int) bool { return str2[i] < str2[j] })
		m[string(str2)] = append(m[string(str2)], str)
	}
	for k := range m {
		ans = append(ans, m[k])
	}
	return ans
}
