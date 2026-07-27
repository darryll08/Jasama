import { readFileSync } from "node:fs";

import { describe, expect, it } from "vitest";

const globalStyles = readFileSync("app/globals.css", "utf8");

describe("design foundation", () => {
  it("defines the approved focus tokens and solid focus treatment", () => {
    expect(globalStyles).toContain("--color-action-focus: #0b6f6a");
    expect(globalStyles).toContain(
      "--color-action-focus-inverse: #f2b84b",
    );
    expect(globalStyles).toMatch(/outline:\s*3px solid/);
    expect(globalStyles).toMatch(/outline-offset:\s*2px/);
    expect(globalStyles).toMatch(
      /\.skip-link:focus-visible\s*\{[^}]*outline-color:\s*var\(--color-action-focus-inverse\)/s,
    );
  });

  it("defines reduced-motion behavior", () => {
    expect(globalStyles).toContain("@media (prefers-reduced-motion: reduce)");
    expect(globalStyles).toMatch(/transition-duration:\s*0\.01ms/);
    expect(globalStyles).toMatch(/animation-iteration-count:\s*1/);
  });

  it("defines the approved global surface and typography tokens", () => {
    for (const token of [
      "--color-brand-900",
      "--color-surface-canvas",
      "--color-text-primary",
      "--color-border-subtle",
      "--font-heading",
      "--font-sans",
    ]) {
      expect(globalStyles).toContain(token);
    }
  });
});
