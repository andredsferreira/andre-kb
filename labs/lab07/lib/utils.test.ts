import { describe, expect, it } from "vitest";
import { formatDockerCommand, getAppGreeting } from "./utils";

describe("formatDockerCommand", () => {
  it("trims and normalizes whitespace", () => {
    expect(formatDockerCommand("  docker   build   -t   image  ")).toBe(
      "docker build -t image"
    );
  });

  it("returns single space between words", () => {
    expect(formatDockerCommand("docker run -p 3000:3000 app")).toBe(
      "docker run -p 3000:3000 app"
    );
  });
});

describe("getAppGreeting", () => {
  it("returns the welcome message", () => {
    expect(getAppGreeting()).toBe("Welcome to Next.js on Docker!");
  });
});
