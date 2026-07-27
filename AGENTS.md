# Jasama Agent Instructions

These instructions apply to the entire repository. Read them before every task.

## Authority

Resolve conflicts in this order:

1. `PRODUCT.md` — product authority.
2. `DESIGN.md` — visual, interaction, content, responsive, and accessibility authority.
3. `docs/HOMEPAGE_SHAPE.md` — homepage structure and discovery flow.
4. `docs/PRD.md` — detailed functional requirements.
5. `docs/STATE_MACHINES.md` — authoritative states and transitions.
6. `docs/OPEN_DECISIONS.md` — decision status and closed-beta gates.
7. `docs/TECHNICAL_SPEC.md`, `docs/DATABASE_SCHEMA.md`, `docs/SECURITY_RULES.md`, `docs/API_EVENTS_AND_JOBS.md`, `docs/TEST_STRATEGY.md`, and `docs/TRACEABILITY_MATRIX.md` — implementation contracts.
8. `docs/TRANSITION_COMMAND_MATRIX.md` — exact 266 transition-to-command mappings.
9. `docs/IMPLEMENTATION_PLAN.md` — approved phase sequence, not product authority.
10. `docs/CODEX_PROMPTS.md` — reusable execution guidance, not product authority.

Never silently change an authority or approve an open decision.

## Closed-beta boundaries

- No government-ID, identity-document, face-match, real-payment, refund, settlement, or payout capability.
- Mock payment and demo data are impossible in production.
- P1/P2 behavior remains disabled until explicitly approved and synchronized across authorities.
- Use `Profil Mitra diperiksa`, never unsupported verification, safety, guarantee, refund, ranking, partner, support, or performance claims.

## Engineering rules

- Binding stack: Next.js App Router, strict TypeScript, Tailwind, Supabase PostgreSQL/Auth/Storage/generated types/migrations, GitHub, Vercel, pnpm.
- Use pnpm only. Do not use `any` without a localized documented justification.
- Server Components by default; Client Components only when actual browser interaction requires browser state or effects.
- Use reviewed Supabase SQL migrations and commit regenerated database types. Add domain migrations only in their implementation phase.
- Deny-by-default RLS. Keep service-role, provisioning, privileged mutations, private-file access, and encryption server-side.
- Model base profiles, optional Mitra capability, and scoped admin assignments. Never add a generic user role or generic `is_verified`.
- Never expose a generic `setStatus` API, accept client-controlled transitions, or perform independent client writes for cross-machine events.
- Keep accepted/commercial terms and source category/tags immutable and versioned. Audit is append-only.
- Binding commands require authorization, validation, transaction boundaries, idempotency, correlation, audit, and outbox handling. Each outbox consumer has independent delivery state.
- Storage is private by default. Public media uses approved generated renditions only.
- Write natural Indonesian user-facing copy and implement `DESIGN.md` exactly, including accessibility.

## Scope and completion

- Work only inside the selected implementation-plan phase. Stop at its boundary.
- Inspect existing files before creating new ones. Avoid speculative abstractions and dependencies.
- Update affected technical contracts and traceability when implementation changes an approved contract; do not rewrite product decisions to match code.
- Before declaring work complete, run the checks that exist and apply to the selected phase. The plan schedules:
  - `pnpm lint`
  - `pnpm typecheck`
  - `pnpm test`
  - `pnpm test:rls` where applicable
  - `pnpm test:e2e` where applicable
  - `pnpm build`
- Report files changed, checks run, failures, assumptions, and remaining blockers. Never claim an unavailable command or integration passed.
