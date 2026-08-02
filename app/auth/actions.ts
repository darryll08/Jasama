"use server";

import { redirect } from "next/navigation";

import {
  emailSchema,
  formValues,
  passwordSchema,
  profileSchema,
  signInSchema,
  signUpSchema,
} from "@/lib/auth/forms";
import { serverEnvironment } from "@/lib/env/server";
import { createClient } from "@/lib/supabase/server";

function messageUrl(path: string, kind: "error" | "status", message: string) {
  const query = new URLSearchParams({ [kind]: message });
  return `${path}?${query.toString()}`;
}

export async function signUp(formData: FormData) {
  const result = signUpSchema.safeParse(formValues(formData));
  if (!result.success) {
    redirect(
      messageUrl(
        "/auth/sign-up",
        "error",
        result.error.issues[0]?.message ?? "Periksa kembali isian Anda.",
      ),
    );
  }

  const supabase = await createClient();
  const { error } = await supabase.auth.signUp({
    email: result.data.email,
    password: result.data.password,
    options: {
      data: { display_name: result.data.displayName },
      emailRedirectTo: `${serverEnvironment.APP_BASE_URL}/auth/confirm`,
    },
  });

  if (error) {
    redirect(
      messageUrl(
        "/auth/sign-up",
        "error",
        "Pendaftaran belum berhasil. Periksa data Anda lalu coba lagi.",
      ),
    );
  }

  redirect(
    messageUrl(
      "/auth/sign-in",
      "status",
      "Periksa email Anda untuk mengonfirmasi akun sebelum masuk.",
    ),
  );
}

export async function signIn(formData: FormData) {
  const result = signInSchema.safeParse(formValues(formData));
  if (!result.success) {
    redirect(
      messageUrl(
        "/auth/sign-in",
        "error",
        result.error.issues[0]?.message ?? "Periksa kembali isian Anda.",
      ),
    );
  }

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword(result.data);

  if (error) {
    redirect(
      messageUrl(
        "/auth/sign-in",
        "error",
        "Email atau kata sandi tidak cocok.",
      ),
    );
  }

  redirect("/account");
}

export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut({ scope: "local" });
  redirect(
    messageUrl("/auth/sign-in", "status", "Anda telah keluar dari akun."),
  );
}

export async function requestPasswordReset(formData: FormData) {
  const result = emailSchema.safeParse(formValues(formData));
  if (result.success) {
    const supabase = await createClient();
    await supabase.auth.resetPasswordForEmail(result.data.email, {
      redirectTo: `${serverEnvironment.APP_BASE_URL}/auth/confirm?next=/auth/update-password`,
    });
  }

  redirect(
    messageUrl(
      "/auth/forgot-password",
      "status",
      "Jika akun tersebut tersedia, petunjuk pemulihan telah dikirim.",
    ),
  );
}

export async function updatePassword(formData: FormData) {
  const result = passwordSchema.safeParse(formValues(formData));
  if (!result.success) {
    redirect(
      messageUrl(
        "/auth/update-password",
        "error",
        result.error.issues[0]?.message ?? "Periksa kembali isian Anda.",
      ),
    );
  }

  const supabase = await createClient();
  const { data: claims } = await supabase.auth.getClaims();
  if (!claims?.claims.sub) {
    redirect(
      messageUrl(
        "/auth/sign-in",
        "error",
        "Tautan pemulihan tidak berlaku lagi. Minta tautan baru.",
      ),
    );
  }

  const { error } = await supabase.auth.updateUser({
    password: result.data.password,
  });
  if (error) {
    redirect(
      messageUrl(
        "/auth/update-password",
        "error",
        "Kata sandi belum dapat diperbarui. Minta tautan pemulihan baru.",
      ),
    );
  }

  redirect(
    messageUrl(
      "/account",
      "status",
      "Kata sandi berhasil diperbarui.",
    ),
  );
}

export async function updateProfile(formData: FormData) {
  const result = profileSchema.safeParse(formValues(formData));
  if (!result.success) {
    redirect(
      messageUrl(
        "/account",
        "error",
        result.error.issues[0]?.message ?? "Periksa kembali isian Anda.",
      ),
    );
  }

  const supabase = await createClient();
  const { data, error } = await supabase.rpc("update_current_profile", {
    expected_lock_version: result.data.expectedLockVersion,
    new_display_name: result.data.displayName,
    new_locale: result.data.locale,
    new_timezone: result.data.timezone,
  });

  if (error || !data) {
    redirect(
      messageUrl(
        "/account",
        "error",
        "Profil belum dapat disimpan. Coba lagi.",
      ),
    );
  }

  if (!data.success) {
    const messages = {
      forbidden: "Profil ini tidak dapat diperbarui.",
      stale_version:
        "Profil telah berubah sejak halaman dibuka. Muat ulang lalu coba lagi.",
      validation_failed: "Periksa kembali data profil Anda.",
    } as const;
    const message =
      !data.code || data.code === "ok"
        ? "Profil belum dapat disimpan. Coba lagi."
        : messages[data.code];
    redirect(messageUrl("/account", "error", message));
  }

  redirect(messageUrl("/account", "status", "Profil berhasil disimpan."));
}
