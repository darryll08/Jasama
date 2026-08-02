import { readFileSync } from "node:fs";

import { describe, expect, it } from "vitest";

import { resolveAuthCallbackDestination } from "@/lib/auth/callback";

const authActions = readFileSync("app/auth/actions.ts", "utf8");
const authConfig = readFileSync("supabase/config.toml", "utf8");

describe("Auth callback destination", () => {
  it.each(["/account", "/auth/update-password"])(
    "accepts the approved internal destination %s",
    (destination) => {
      expect(resolveAuthCallbackDestination(destination)).toBe(destination);
    },
  );

  it.each([
    "//evil.example",
    "/\\evil.example",
    "\\\\evil.example",
    "https://evil.example",
    "http://evil.example/account",
    "/account?next=https://evil.example",
    "/account#evil",
    "/account\u0000",
    "/",
  ])("defaults unsafe destination %j to /account", (destination) => {
    expect(resolveAuthCallbackDestination(destination)).toBe("/account");
  });

  it.each([
    "next=%2F%2Fevil.example",
    "next=%2F%5Cevil.example",
    "next=%5C%5Cevil.example",
    "next=https%3A%2F%2Fevil.example",
  ])("rejects decoded encoded destination from %s", (query) => {
    const requested = new URLSearchParams(query).get("next");
    const destination = resolveAuthCallbackDestination(requested);
    const result = new URL(destination, "https://jasama.example");

    expect(destination).toBe("/account");
    expect(result.origin).toBe("https://jasama.example");
  });

  it("uses only the two exact APP_BASE_URL callbacks", () => {
    expect(authActions).toContain(
      "emailRedirectTo: `${serverEnvironment.APP_BASE_URL}/auth/confirm`",
    );
    expect(authActions).toContain(
      "redirectTo: `${serverEnvironment.APP_BASE_URL}/auth/confirm?next=/auth/update-password`",
    );
    expect(authConfig).toContain(
      'additional_redirect_urls = ["http://127.0.0.1:3000/auth/confirm", "http://127.0.0.1:3000/auth/confirm?next=/auth/update-password"]',
    );
  });

  it("does not derive redirect origins from request headers", () => {
    expect(authActions).not.toMatch(/\bheaders\s*\(/);
    expect(authActions).not.toContain("origin");
    expect(authActions).not.toContain("referer");
    expect(authActions).not.toContain("x-forwarded-host");
  });
});
