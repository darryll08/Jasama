import { describe, expect, it } from "vitest";

import {
  createPublicEnvironment,
  requireSupabaseEnvironment,
  validateEnvironment,
} from "@/lib/env/schema";

describe("environment validation", () => {
  it("rejects mock payment in production", () => {
    expect(() =>
      validateEnvironment({
        APP_ENV: "production",
        PAYMENT_MODE: "mock",
      }),
    ).toThrow(/PAYMENT_MODE harus disabled/);
  });

  it("accepts mock payment in development", () => {
    expect(
      validateEnvironment({
        APP_ENV: "development",
        PAYMENT_MODE: "mock",
      }).PAYMENT_MODE,
    ).toBe("mock");
  });

  it("normalizes a trusted application base URL", () => {
    expect(
      validateEnvironment({
        APP_ENV: "development",
        APP_BASE_URL: "http://127.0.0.1:3000///",
      }).APP_BASE_URL,
    ).toBe("http://127.0.0.1:3000");
  });

  it.each(["ftp://example.com", "https://user:pass@example.com", "https://example.com/base", "https://example.com?next=bad", "https://example.com#bad"])(
    "rejects unsafe application base URL %s",
    (APP_BASE_URL) => {
      expect(() =>
        validateEnvironment({ APP_ENV: "development", APP_BASE_URL }),
      ).toThrow();
    },
  );

  it.each([
    ["staging", "http://localhost:3000"],
    ["production", "http://127.0.0.1:3000"],
    ["production", "http://[::1]:3000"],
  ] as const)(
    "rejects local application base URL %s in %s",
    (APP_ENV, APP_BASE_URL) => {
      expect(() =>
        validateEnvironment({
          APP_ENV,
          APP_BASE_URL,
        }),
      ).toThrow(/URL non-lokal/);
    },
  );

  it("accepts an explicit non-local application base URL in production", () => {
    expect(
      validateEnvironment({
        APP_ENV: "production",
        APP_BASE_URL: "https://jasama.example/",
      }).APP_BASE_URL,
    ).toBe("https://jasama.example");
  });

  it("accepts disabled payment in production", () => {
    expect(
      validateEnvironment({
        APP_ENV: "production",
        APP_BASE_URL: "https://jasama.example",
        PAYMENT_MODE: "disabled",
      }),
    ).toMatchObject({
      APP_ENV: "production",
      PAYMENT_MODE: "disabled",
    });
  });

  it("rejects an unsupported application environment", () => {
    expect(() =>
      validateEnvironment({
        APP_ENV: "preview",
        PAYMENT_MODE: "disabled",
      }),
    ).toThrow();
  });

  it("rejects an unsupported payment mode", () => {
    expect(() =>
      validateEnvironment({
        APP_ENV: "test",
        PAYMENT_MODE: "real",
      }),
    ).toThrow();
  });

  it("does not expose server-only values through the public interface", () => {
    const publicEnvironment = createPublicEnvironment({
      NEXT_PUBLIC_SUPABASE_URL: "https://example.supabase.co",
      NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: "public-placeholder",
      SUPABASE_SECRET_KEY: "server-secret",
      APP_BASE_URL: "https://jasama.example",
    });

    expect(publicEnvironment).toEqual({
      NEXT_PUBLIC_SUPABASE_URL: "https://example.supabase.co",
      NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: "public-placeholder",
    });
    expect(publicEnvironment).not.toHaveProperty("SUPABASE_SECRET_KEY");
    expect(publicEnvironment).not.toHaveProperty("APP_BASE_URL");
  });

  it("fails closed when the public Supabase runtime contract is incomplete", () => {
    expect(() =>
      requireSupabaseEnvironment({
        NEXT_PUBLIC_SUPABASE_URL: "https://example.supabase.co",
      }),
    ).toThrow();
  });

  it("does not substitute the server secret for a missing publishable key", () => {
    expect(() =>
      requireSupabaseEnvironment({
        NEXT_PUBLIC_SUPABASE_URL: "https://example.supabase.co",
        SUPABASE_SECRET_KEY: "server-secret",
      }),
    ).toThrow();
  });
});
