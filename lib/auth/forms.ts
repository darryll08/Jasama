import { z } from "zod";

const email = z.email("Masukkan alamat email yang valid.").max(254);

export const passwordRequirementsHelp =
  "Gunakan minimal 8 karakter dengan huruf kecil, huruf besar, angka, dan simbol.";

const password = z
  .string()
  .min(8, "Kata sandi harus berisi minimal 8 karakter.")
  .regex(/[a-z]/, "Kata sandi harus memuat huruf kecil.")
  .regex(/[A-Z]/, "Kata sandi harus memuat huruf besar.")
  .regex(/[0-9]/, "Kata sandi harus memuat angka.")
  .regex(/[^A-Za-z0-9\s]/, "Kata sandi harus memuat simbol.")
  .max(72, "Kata sandi terlalu panjang.");

export const signInSchema = z.object({ email, password }).strict();

export const signUpSchema = signInSchema.extend({
  displayName: z
    .string()
    .trim()
    .min(2, "Nama tampilan harus berisi minimal 2 karakter.")
    .max(80, "Nama tampilan terlalu panjang."),
}).strict();

export const emailSchema = z.object({ email }).strict();

export const passwordSchema = z
  .object({
    password,
    confirmation: z.string(),
  })
  .strict()
  .refine(({ confirmation, password: value }) => confirmation === value, {
    message: "Konfirmasi kata sandi tidak cocok.",
    path: ["confirmation"],
  });

export const profileSchema = z.object({
  displayName: z
    .string()
    .trim()
    .min(2, "Nama tampilan harus berisi minimal 2 karakter.")
    .max(80, "Nama tampilan terlalu panjang."),
  locale: z.literal("id-ID"),
  timezone: z.literal("Asia/Jakarta"),
  expectedLockVersion: z.coerce
    .number()
    .int()
    .nonnegative()
    .max(Number.MAX_SAFE_INTEGER),
}).strict();

export function formValues(formData: FormData) {
  return Object.fromEntries(
    [...formData.entries()].filter(([key]) => !key.startsWith("$ACTION_")),
  );
}
