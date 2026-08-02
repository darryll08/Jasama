"use client";

import { createBrowserClient } from "@supabase/ssr";

import { publicEnvironment } from "@/lib/env/public";
import { requireSupabaseEnvironment } from "@/lib/env/schema";

import type { Database } from "./database.types";

export function createClient() {
  const environment = requireSupabaseEnvironment(publicEnvironment);

  return createBrowserClient<Database>(
    environment.NEXT_PUBLIC_SUPABASE_URL,
    environment.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY,
  );
}
