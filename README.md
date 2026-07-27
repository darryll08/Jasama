# Jasama

Jasama is a mobile-first marketplace for finding and commissioning local and
digital services in Indonesia. Its core flow keeps the `Pemesan` perspective
first: people can explore approved `Jasa`, publish a `Permintaan`, compare
`Penawaran`, and continue into a governed `Pesanan`.

## Development status

- **Phase 0 — Complete**  
  Completed on 28 July 2026. All repository and quality-foundation gates passed:
  frozen-lockfile installation, lint, typecheck, 13 unit tests, production
  build, environment validation, and CI configuration.

- **Phase 1 — Ready, not started**  
  Supabase foundation, account profiles, and authorization have not been
  implemented yet.

Phase 0 provides the root Next.js application and quality foundation. The
repository now has a minimal, non-product application shell, strict TypeScript,
Tailwind design tokens, environment validation, unit tests, and CI checks.

Supabase is not connected. Authentication, database migrations, marketplace
data, payment processing, the public homepage, and every marketplace workflow
begin in later approved phases.

Future contributors and Codex agents must read [AGENTS.md](./AGENTS.md) before
making changes. Work must stay inside one approved phase from
`docs/IMPLEMENTATION_PLAN.md`.

## Phase 0 setup

### Prerequisites

- Node.js 24 LTS
- pnpm 11.9.0, as pinned by `package.json`

### Install

```sh
pnpm install --frozen-lockfile
```

The application builds without real secrets. To set local values, create an
ignored `.env.local` from `.env.example` and replace its markers. In Phase 0,
the Supabase variables are optional and unused. `APP_ENV` accepts
`development`, `test`, `staging`, or `production`; `PAYMENT_MODE` accepts
`disabled` or `mock`, but production rejects `mock`.

Never commit `.env.local`, service-role values, recovery secrets, or encryption
keys.

### Working commands

```sh
pnpm dev
pnpm lint
pnpm typecheck
pnpm test
pnpm build
pnpm start
```

`pnpm dev` starts the local development server. `pnpm start` serves a completed
production build. Lint fails on warnings, tests run once, and typecheck emits no
files.

## Closed-beta scope

The closed beta covers:

- public homepage discovery and eight approved service categories;
- account profiles and optional Mitra capability;
- moderated Jasa publishing;
- Permintaan and Penawaran workflows;
- Pesanan with immutable accepted terms;
- mock-payment-only testing outside production;
- contextual messaging, controlled attachments, delivery, proof, revisions,
  cancellation, reviews, reports, and disputes;
- scoped administrator operations and append-only audit.

The beta does not collect government IDs, claim identity verification, process
real payments, refunds, settlements, or payouts, or enable unapproved P1/P2
behavior. High-risk administrator actions remain disabled until verified
reauthentication exists.

## Architecture summary

The planned system uses Next.js App Router with strict TypeScript and Tailwind,
backed by Supabase PostgreSQL, Auth, and private-by-default Storage. Server
Components are the default. Privileged mutations run through server-controlled
commands or RPCs with deny-by-default RLS, transaction boundaries,
idempotency, append-only audit, and an outbox for asynchronous effects.

State transitions follow the authoritative state machines and the exact
transition-command matrix. Accepted commercial terms are immutable and
versioned. Public media can use only approved generated renditions; private
objects are served through authorized, short-lived access.

## Documentation map

- `PRODUCT.md` — product authority and closed-beta promise.
- `DESIGN.md` — current visual, interaction, content, responsive, and
  accessibility authority.
- `docs/HOMEPAGE_SHAPE.md` — homepage structure and discovery flow.
- `docs/PRD.md` — detailed functional requirements.
- `docs/STATE_MACHINES.md` — authoritative states and transitions.
- `docs/OPEN_DECISIONS.md` — decisions, blockers, and approval gates.
- `docs/TECHNICAL_SPEC.md` — system architecture and implementation contracts.
- `docs/DATABASE_SCHEMA.md` — planned data model and integrity rules.
- `docs/SECURITY_RULES.md` — authorization, privacy, and threat controls.
- `docs/API_EVENTS_AND_JOBS.md` — command, event, outbox, and job contracts.
- `docs/TEST_STRATEGY.md` — required test layers and critical cases.
- `docs/TRACEABILITY_MATRIX.md` — requirement-to-control coverage.
- `docs/TRANSITION_COMMAND_MATRIX.md` — exact transition-to-command mappings.
- `docs/IMPLEMENTATION_PLAN.md` — gated Phase 0–10 delivery sequence.
- `docs/CODEX_PROMPTS.md` — reusable prompts for phase-bound work.

When documents conflict, use the authority order in `AGENTS.md`; do not silently
rewrite an authority to match an implementation.

## Stack

- Next.js App Router
- TypeScript in strict mode
- Tailwind CSS
- Supabase PostgreSQL, Auth, Storage, SQL migrations, and generated database
  types beginning in Phase 1
- pnpm
- GitHub
- Vercel

Phase 0 installs no Supabase, payment, analytics, icon, state-management,
component-library, or marketplace dependency.

## Environment overview

`.env.example` documents the planned public browser configuration, server-only
Supabase credentials, deployment environment, payment kill switch,
private-address encryption, scheduled-job recovery authentication, and future
disabled integrations. It contains placeholders only.

Secrets belong in the deployment secret manager, never source control.
Production must reject demo records and mock-payment mode. Encryption-key
rotation adds a new version in secret storage while retaining older keys only
for controlled decryption and re-encryption.

## Safety boundaries

- Deny access by default and keep privileged credentials server-side.
- Never expose provisioning through application UI, runtime user/admin
  commands, public API, or client code.
- Never accept a generic status setter or client-controlled state transition.
- Keep private addresses and attachments private and purpose-bound.
- Do not fabricate testimonials, ratings, usage counts, rankings, partners, or
  performance evidence.
- Keep demo and mock-payment data impossible in production.
- Do not enable PDF or Office attachments before a content validator exists.

## Planned phases

1. Repository and quality foundation
2. Supabase foundation, account profile, and authorization
3. Public homepage and discovery with demo data
4. Mitra onboarding and Jasa moderation
5. Permintaan, Penawaran, and offer conversion
6. Pesanan, terms versioning, mock payment, and scheduled jobs
7. Contextual messaging and private attachments
8. Work execution, digital delivery, local proof, and revisions
9. Cancellation, reviews, reports, and disputes
10. Administrator operations and closed-beta hardening
11. Closed-beta deployment and acceptance

Each numbered item corresponds to Phase 0 through Phase 10 in
`docs/IMPLEMENTATION_PLAN.md`. A phase starts only after its entry gate is met
and the preceding phase has been implemented, tested, audited, and approved.
