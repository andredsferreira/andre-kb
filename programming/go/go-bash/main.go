package main

import (
	"bytes"
	"context"
	"log/slog"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	scriptPath, err := filepath.Abs("hello.sh")
	if err != nil {
		logger.Error("failed to resolve script path", "error", err)
		os.Exit(1)
	}

	name := "Andrew"

	if err := runHello(context.Background(), logger, scriptPath, name); err != nil {
		logger.Error("hello script failed", "error", err, "script", scriptPath)
		os.Exit(1)
	}
}

func runHello(ctx context.Context, logger *slog.Logger, scriptPath, name string) error {
	start := time.Now()

	logger.Info("running script",
		"script", scriptPath,
		"arg_name", name,
	)

	cmd := exec.CommandContext(ctx, scriptPath, name)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()
	duration := time.Since(start)

	// Structured fields describing the run, regardless of outcome
	attrs := []any{
		"script", scriptPath,
		"duration_ms", duration.Milliseconds(),
		"stdout", stdout.String(),
	}

	if err != nil {
		var exitErr *exec.ExitError
		exitCode := -1
		if ok := exitErrorAs(err, &exitErr); ok {
			exitCode = exitErr.ExitCode()
		}

		attrs = append(attrs,
			"error", err.Error(),
			"stderr", stderr.String(),
			"exit_code", exitCode,
		)
		logger.Error("script execution failed", attrs...)
		return err
	}

	logger.Info("script execution succeeded", attrs...)
	return nil
}

func exitErrorAs(err error, target **exec.ExitError) bool {
	if ee, ok := err.(*exec.ExitError); ok {
		*target = ee
		return true
	}
	return false
}
