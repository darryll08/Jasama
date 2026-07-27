import { describe, expect, it } from "vitest";

import {
  createPublicEnvironment,
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

  it("accepts disabled payment in production", () => {
    expect(
      validateEnvironment({
        APP_ENV: "production",
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
      NEXT_PUBLIC_SUPABASE_ANON_KEY: "public-placeholder",
      SUPABASE_SERVICE_ROLE_KEY: "server-secret",
    });

    expect(publicEnvironment).toEqual({
      NEXT_PUBLIC_SUPABASE_URL: "https://example.supabase.co",
      NEXT_PUBLIC_SUPABASE_ANON_KEY: "public-placeholder",
    });
    expect(publicEnvironment).not.toHaveProperty("SUPABASE_SERVICE_ROLE_KEY");
  });
});
