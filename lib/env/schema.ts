import { z } from "zod";

const appEnvironmentSchema = z.enum([
  "development",
  "test",
  "staging",
  "production",
]);

const paymentModeSchema = z.enum(["disabled", "mock"]);

const appBaseUrlSchema = z
  .url()
  .refine((value) => ["http:", "https:"].includes(new URL(value).protocol), {
    message: "APP_BASE_URL harus memakai http atau https.",
  })
  .refine(
    (value) => {
      const url = new URL(value);
      return (
        !url.username &&
        !url.password &&
        !url.search &&
        !url.hash &&
        /^\/+$/.test(url.pathname)
      );
    },
    {
      message:
        "APP_BASE_URL harus berupa origin tanpa kredensial, path, query, atau fragmen.",
    },
  )
  .transform((value) => value.replace(/\/+$/, ""));

const optionalUrlSchema = z.preprocess(
  (value) => (value === "" ? undefined : value),
  z.url().optional(),
);

const optionalStringSchema = z.preprocess(
  (value) => (value === "" ? undefined : value),
  z.string().min(1).optional(),
);

export const publicEnvironmentSchema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: optionalUrlSchema,
  NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: optionalStringSchema,
});

export const serverEnvironmentSchema = publicEnvironmentSchema
  .extend({
    APP_ENV: appEnvironmentSchema.default("development"),
    APP_BASE_URL: appBaseUrlSchema.default("http://127.0.0.1:3000"),
    PAYMENT_MODE: paymentModeSchema.default("disabled"),
    SUPABASE_SECRET_KEY: optionalStringSchema,
    PRIVATE_ADDRESS_KEY_VERSION: optionalStringSchema,
    PRIVATE_ADDRESS_KEY_V1_BASE64: optionalStringSchema,
    INTERNAL_JOB_RECOVERY_SECRET: optionalStringSchema,
  })
  .superRefine((environment, context) => {
    const baseHostname = new URL(environment.APP_BASE_URL).hostname;
    const baseUrlIsLocal =
      baseHostname === "localhost" ||
      baseHostname.endsWith(".localhost") ||
      baseHostname.startsWith("127.") ||
      baseHostname === "[::1]" ||
      baseHostname === "0.0.0.0";
    if (
      ["staging", "production"].includes(environment.APP_ENV) &&
      baseUrlIsLocal
    ) {
      context.addIssue({
        code: "custom",
        path: ["APP_BASE_URL"],
        message:
          "APP_BASE_URL staging dan production harus berupa URL non-lokal.",
      });
    }

    if (
      environment.APP_ENV === "production" &&
      environment.PAYMENT_MODE === "mock"
    ) {
      context.addIssue({
        code: "custom",
        path: ["PAYMENT_MODE"],
        message: "PAYMENT_MODE harus disabled di lingkungan production.",
      });
    }
  });

export type EnvironmentInput = Readonly<
  Record<string, string | undefined>
>;

export function createPublicEnvironment(input: EnvironmentInput) {
  return publicEnvironmentSchema.parse(input);
}

export function validateEnvironment(input: EnvironmentInput) {
  return serverEnvironmentSchema.parse(input);
}

export function requireSupabaseEnvironment(input: EnvironmentInput) {
  return z
    .object({
      NEXT_PUBLIC_SUPABASE_URL: z.url(),
      NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: z.string().min(1),
    })
    .parse(input);
}
