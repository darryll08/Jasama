import { createServerClient } from "@supabase/ssr";
import { NextRequest } from "next/server";
import { afterEach, describe, expect, it, vi } from "vitest";

import { refreshSession } from "@/lib/supabase/proxy";

vi.mock("@supabase/ssr", () => ({
  createServerClient: vi.fn(
    (
      _url: string,
      _key: string,
      options: {
        cookies: {
          setAll: (
            cookies: {
              name: string;
              value: string;
              options: { httpOnly?: boolean };
            }[],
            headers: Record<string, string>,
          ) => void;
        };
      },
    ) => ({
      auth: {
        getClaims: async () => {
          options.cookies.setAll(
            [
              {
                name: "sb-session",
                value: "refreshed",
                options: { httpOnly: true },
              },
            ],
            {
              "cache-control": "private, no-store",
              pragma: "no-cache",
              "x-supabase-auth": "refreshed",
            },
          );
        },
      },
    }),
  ),
}));

const originalUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const originalKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

afterEach(() => {
  process.env.NEXT_PUBLIC_SUPABASE_URL = originalUrl;
  process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY = originalKey;
  vi.clearAllMocks();
});

describe("Supabase Proxy session refresh", () => {
  it("returns refreshed cookies and every SSR response header", async () => {
    process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.supabase.co";
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY = "public-placeholder";
    const request = new NextRequest("https://jasama.example/account");

    const response = await refreshSession(request);

    expect(createServerClient).toHaveBeenCalledOnce();
    expect(request.cookies.get("sb-session")?.value).toBe("refreshed");
    expect(response.cookies.get("sb-session")?.value).toBe("refreshed");
    expect(response.headers.get("cache-control")).toBe("private, no-store");
    expect(response.headers.get("pragma")).toBe("no-cache");
    expect(response.headers.get("x-supabase-auth")).toBe("refreshed");
  });
});
