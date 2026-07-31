import "server-only";

import { createClient } from "@/lib/supabase/server";

export type OrdinaryPermissionCode =
  | "admin.permissions.manage"
  | "profile.support"
  | "account.moderate";

export async function hasPermission(
  permissionCode: OrdinaryPermissionCode,
  scopeType: "global" | "locality" = "global",
  scopeId: string | null = null,
) {
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("has_admin_permission", {
    permission_code: permissionCode,
    requested_scope_id: scopeId ?? undefined,
    requested_scope_type: scopeType,
  });

  return error ? false : data;
}
