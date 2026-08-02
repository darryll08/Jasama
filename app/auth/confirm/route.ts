import { type NextRequest, NextResponse } from "next/server";

import { resolveAuthCallbackDestination } from "@/lib/auth/callback";
import { serverEnvironment } from "@/lib/env/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const code = request.nextUrl.searchParams.get("code");
  const next = resolveAuthCallbackDestination(
    request.nextUrl.searchParams.get("next"),
  );

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(new URL(next, serverEnvironment.APP_BASE_URL));
    }
  }

  const destination = new URL(
    "/auth/sign-in",
    serverEnvironment.APP_BASE_URL,
  );
  destination.searchParams.set(
    "error",
    "Tautan konfirmasi tidak berlaku lagi. Buka halaman daftar untuk memulai lagi.",
  );
  return NextResponse.redirect(destination);
}
