import { readFileSync } from "node:fs";

import { describe, expect, it } from "vitest";

import {
  emailSchema,
  formValues,
  passwordSchema,
  passwordRequirementsHelp,
  profileSchema,
  signUpSchema,
} from "@/lib/auth/forms";

const authConfig = readFileSync("supabase/config.toml", "utf8");

describe("account form validation", () => {
  it("matches the reviewed hosted Auth password and email settings", () => {
    expect(authConfig).toMatch(/^minimum_password_length = 8$/m);
    expect(authConfig).toMatch(
      /^password_requirements = "lower_upper_letters_digits_symbols"$/m,
    );
    expect(authConfig).toMatch(/^secure_password_change = true$/m);
    expect(authConfig).toMatch(/^otp_length = 8$/m);
    expect(passwordRequirementsHelp).toContain(
      "huruf kecil, huruf besar, angka, dan simbol",
    );
  });

  it("requires a valid email and the reviewed Auth password policy", () => {
    expect(
      signUpSchema.safeParse({
        displayName: "D",
        email: "bukan-email",
        password: "pendek",
      }).success,
    ).toBe(false);
  });

  it("accepts a valid account registration", () => {
    expect(
      signUpSchema.safeParse({
        displayName: "Dewi Lestari",
        email: "dewi@example.test",
        password: "Kata-sandi-lokal1",
      }).success,
    ).toBe(true);
  });

  it("ignores only Next.js Server Action fields before strict validation", () => {
    const valid = new FormData();
    valid.set("$ACTION_ID_abc", "framework");
    valid.set("displayName", "Dewi Lestari");
    valid.set("email", "dewi@example.test");
    valid.set("password", "Kata-sandi-lokal1!");

    expect(signUpSchema.safeParse(formValues(valid)).success).toBe(true);

    const arbitraryDollarField = new FormData();
    for (const [key, value] of valid.entries()) {
      arbitraryDollarField.set(key, value);
    }
    arbitraryDollarField.set("$actorId", "attacker");

    expect(
      signUpSchema.safeParse(formValues(arbitraryDollarField)).success,
    ).toBe(false);
  });

  it.each([
    "actorId",
    "permissionCode",
    "state",
    "is_demo",
    "created_at",
    "lock_version",
  ])("rejects injected registration field %s", (field) => {
    expect(
      signUpSchema.safeParse({
        displayName: "Dewi Lestari",
        email: "dewi@example.test",
        password: "Kata-sandi-lokal1!",
        [field]: "injected",
      }).success,
    ).toBe(false);
  });

  it("keeps the approved profile lock field strict", () => {
    const profile = {
      displayName: "Dewi Lestari",
      expectedLockVersion: "4",
      locale: "id-ID",
      timezone: "Asia/Jakarta",
    };

    expect(profileSchema.safeParse(profile).success).toBe(true);
    expect(
      profileSchema.safeParse({ ...profile, lock_version: 4 }).success,
    ).toBe(false);
  });

  it.each([
    "KATA-SANDI1!",
    "kata-sandi1!",
    "Kata-sandi!",
    "KataSandi1",
  ])("rejects a password missing a required character class: %s", (password) => {
    expect(
      signUpSchema.safeParse({
        displayName: "Dewi Lestari",
        email: "dewi@example.test",
        password,
      }).success,
    ).toBe(false);
  });

  it("does not reveal account existence through reset input validation", () => {
    expect(emailSchema.safeParse({ email: "pengguna@example.test" }).success).toBe(
      true,
    );
  });

  it("rejects mismatched password confirmation", () => {
    expect(
      passwordSchema.safeParse({
        password: "Kata-sandi-baru1!",
        confirmation: "Berbeda-sekali2!",
      }).success,
    ).toBe(false);
  });

  it("allows only the approved profile locale and timezone", () => {
    expect(
      profileSchema.safeParse({
        displayName: "Dewi Lestari",
        expectedLockVersion: "0",
        locale: "en-US",
        timezone: "UTC",
      }).success,
    ).toBe(false);
    expect(
      profileSchema.safeParse({
        displayName: "Dewi Lestari",
        expectedLockVersion: "4",
        locale: "id-ID",
        timezone: "Asia/Jakarta",
      }).success,
    ).toBe(true);
  });

  it("rejects an invalid profile concurrency version", () => {
    expect(
      profileSchema.safeParse({
        displayName: "Dewi Lestari",
        expectedLockVersion: "-1",
        locale: "id-ID",
        timezone: "Asia/Jakarta",
      }).success,
    ).toBe(false);
  });
});
