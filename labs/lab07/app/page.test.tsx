import { expect, test, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import Home from "./page";

vi.mock("next/link", () => ({
  default: ({
    children,
    href,
  }: {
    children: React.ReactNode;
    href: string;
  }) => <a href={href}>{children}</a>,
}));

vi.mock("next/image", () => ({
  default: (props: { alt: string; src: string }) => (
    // eslint-disable-next-line @next/next/no-img-element -- mock for tests
    <img alt={props.alt} src={props.src} />
  ),
}));

test("renders main heading with welcome message", () => {
  render(<Home />);
  const heading = screen.getByRole("heading", { level: 1 });
  expect(heading.textContent).toContain("Welcome to Next.js on");
  expect(heading.textContent).toContain("Docker");
});

test("renders frontend production Dockerfiles link in Docker Resources", () => {
  render(<Home />);
  const links = screen.getAllByRole("link", { name: /Front-end Production Dockerfiles/i });
  expect(links.length).toBeGreaterThanOrEqual(1);
  expect(links[0].getAttribute("href")).toBe("https://github.com/kristiyan-velkov/frontend-production-dockerfiles");
});
