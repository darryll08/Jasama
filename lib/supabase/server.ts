import "server-only";

import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

import { requireSupabaseEnvironment } from "@/lib/env/schema";
import { serverEnvironment } from "@/lib/env/server";

import type { Database } from "./database.types";

export async function createClient() {
  const cookieStore = await cookies();
  const environment = requireSupabaseEnvironment(serverEnvironment);

  return createServerClient<Database>(
    environment.NEXT_PUBLIC_SUPABASE_URL,
    environment.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll(cookiesToSet) {
          try {
            for (const { name, value, options } of cookiesToSet) {
              cookieStore.set(name, value, options);
            }
          } catch {
            // Server Components cannot write cookies; Proxy refreshes them.
          }
        },
      },
    },
  );
}
