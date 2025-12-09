package ch02

import (
	"bytes"
	"strings"
	"testing"
)

func Test_helloCommand(t *testing.T) {
	testCases := []struct {
		desc     string
		args     []string
		expected string
	}{
		{
			desc:     "default english greeting",
			args:     []string{"--name", "Alice", "--language", "en"},
			expected: "Hello Alice!",
		},
		{
			desc:     "spanish greeting",
			args:     []string{"-n", "Carlos", "-l", "es"},
			expected: "Hola Carlos!",
		},
		{
			desc:     "portuguese greeting",
			args:     []string{"-n", "André", "-l", "pt"},
			expected: "Olá André!",
		},
		{
			desc:     "french greeting",
			args:     []string{"-n", "Emilie", "-l", "fr"},
			expected: "Bonjour Emilie!",
		},
	}

	for _, tc := range testCases {
		t.Run(tc.desc, func(t *testing.T) {
			cmd := initCommand()

			// Capture output to a buffer for testing
			buf := new(bytes.Buffer)
			cmd.SetOut(buf)
			cmd.SetErr(buf)

			// Inject args
			cmd.SetArgs(tc.args)

			// Execute the command
			err := cmd.Execute()
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			out := strings.TrimSpace(buf.String())
			if out != tc.expected {
				t.Fatalf("expected %q, got %q", tc.expected, out)
			}
		})
	}
}
