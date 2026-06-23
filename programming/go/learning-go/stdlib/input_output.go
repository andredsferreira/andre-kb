package stdlib

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

func ReadStringWithReader() string {
	reader := bufio.NewReader(os.Stdin)
	inputString, err := reader.ReadString('\n')
	if err != nil {
		log.Fatal(err)
	}
	return inputString
}

func ReadStringWithScanner() string {
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	err := scanner.Err()
	if err != nil {
		log.Fatal(err)
	}
	return scanner.Text()
}

func ReadInteger() int {
	var num int
	_, err := fmt.Scanf("%d", &num)
	if err != nil {
		log.Fatal(err)
	}
	return num
}

func ReadMultipleLinesWithReader() []string {
	reader := bufio.NewReader(os.Stdin)
	var lines []string
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			log.Fatal(err)
		}
		if len(strings.TrimSpace(line)) == 0 {
			break
		}
		lines = append(lines, line)
	}
	return lines
}

func ReadMultipleLinesWithScanner() []string {
	fmt.Println("input text:")
	scanner := bufio.NewScanner(os.Stdin)
	var lines []string
	for {
		scanner.Scan()
		line := scanner.Text()
		if len(line) == 0 {
			break
		}
		lines = append(lines, line)
	}
	err := scanner.Err()
	if err != nil {
		log.Fatal(err)
	}
	return lines
}

// Counts the number of times letters appear on a reader , returns a map with the letters
// and number of times each letter appeared

func CountLetters(reader io.Reader) (map[string]int, error) {
	buffer := make([]byte, 2048)
	output := map[string]int{}
	for {
		n, err := reader.Read(buffer)
		for _, byte := range buffer[:n] {
			if (byte >= 'A' && byte <= 'Z') || (byte >= 'a' && byte <= 'z') {
				output[string(byte)]++
			}
		}
		if err == io.EOF {
			return output, nil
		}
		if err != nil {
			return nil, err
		}
	}
}
