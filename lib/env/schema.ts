import { z } from "zod";

const appEnvironmentSchema = z.enum([
  "development",
  "test",
  "staging",
  "production",
]);

const paymentModeSchema = z.enum(["disabled", "mock"]);

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
  NEXT_PUBLIC_SUPABASE_ANON_KEY: optionalStringSchema,
});

export const serverEnvironmentSchema = publicEnvironmentSchema
  .extend({
    APP_ENV: appEnvironmentSchema.default("development"),
    PAYMENT_MODE: paymentModeSchema.default("disabled"),
    SUPABASE_SERVICE_ROLE_KEY: optionalStringSchema,
    PRIVATE_ADDRESS_KEY_VERSION: optionalStringSchema,
    PRIVATE_ADDRESS_KEY_V1_BASE64: optionalStringSchema,
    INTERNAL_JOB_RECOVERY_SECRET: optionalStringSchema,
  })
  .superRefine((environment, context) => {
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
