const approvedCallbackDestinations = new Set([
  "/account",
  "/auth/update-password",
]);

export function resolveAuthCallbackDestination(requested: string | null) {
  return requested && approvedCallbackDestinations.has(requested)
    ? requested
    : "/account";
}
