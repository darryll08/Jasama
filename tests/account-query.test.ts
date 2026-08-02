import { readFileSync } from "node:fs";

import { describe, expect, it } from "vitest";

const accountPage = readFileSync("app/account/page.tsx", "utf8");
const migration = readFileSync(
  "supabase/migrations/20260729090000_phase_1_foundation.sql",
  "utf8",
);

describe("account data contracts", () => {
  it("relies on owner RLS and selects only an active email fact", () => {
    expect(accountPage).not.toContain('.eq("auth_user_id"');
    expect(accountPage).not.toContain("destination_hash");
    expect(accountPage).toContain('.in("state", ["pending", "verified"])');
    expect(accountPage).toContain("Status email belum dapat dimuat.");
    expect(accountPage).toContain("Belum ada email aktif");
  });

  it("returns before the profile update when normalized values are unchanged", () => {
    const noOp = migration.indexOf("if changed_fields = '[]'::jsonb then");
    const update = migration.indexOf("update public.profiles", noOp);
    const audit = migration.indexOf("'profile.updated'", update);

    expect(noOp).toBeGreaterThan(-1);
    expect(update).toBeGreaterThan(noOp);
    expect(audit).toBeGreaterThan(update);
    expect(migration.slice(noOp, update)).toContain("current_lock_version");
    expect(migration.slice(update, audit)).toContain(
      "returning lock_version into resulting_lock_version",
    );
    expect(migration.slice(audit, audit + 500)).toContain(
      "jsonb_build_object('changed_fields', changed_fields)",
    );
  });
});
