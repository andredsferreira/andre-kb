package ch02

import (
	"fmt"

	"github.com/spf13/cobra"
)

// Simple command showcase using Cobra library.
// Link: https://github.com/spf13/cobra

func initHelloCommand() *cobra.Command {
	helloCommand := &cobra.Command{
		Use:   "hello",
		Short: "Print hello world",
		Run:   sayHello,
	}
	helloCommand.Flags().StringP("name", "n", "World", "Who to say hello to.")
	helloCommand.MarkFlagRequired("name")
	helloCommand.Flags().StringP("language", "l", "en", "Which language to say hello in.")
	return helloCommand
}

func sayHello(cmd *cobra.Command, args []string) {
	name, _ := cmd.Flags().GetString("name")
	greeting := "Hello"
	language, _ := cmd.Flags().GetString("language")
	switch language {
	case "en":
		greeting = "Hello"
	case "es":
		greeting = "Hola"
	case "pt":
		greeting = "Olá"
	case "fr":
		greeting = "Bonjour"
	}
	fmt.Fprintf(cmd.OutOrStdout(), "%s %s!\n", greeting, name)
}

/*
	In a production scenario the command would be wraped in the main function
	like this:

	func main() {
	    rootCmd := initCommand()
	    if err := rootCmd.Execute(); err != nil {
	        fmt.Println(err)
	        os.Exit(1)
	    }
	}
*/

