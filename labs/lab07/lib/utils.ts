/**
 * Format a Docker command for display (e.g. in UI).
 */
export function formatDockerCommand(command: string): string {
  return command.trim().replace(/\s+/g, " ");
}

/**
 * Return a greeting for the app.
 */
export function getAppGreeting(): string {
  return "Welcome to Next.js on Docker!";
}
