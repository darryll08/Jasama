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

- **Phase 1 — Local verification**
  The local Supabase foundation, account profile, authorization, audit,
  idempotency/outbox schema and transaction foundations, environment guard,
  and accessible email/password Auth flows are implemented. Remote deployment,
  external outbox delivery, asynchronous workers, and administrator bootstrap
  remain pending review.

Phase 0 provides the root Next.js application and quality foundation. Phase 1A
adds a reproducible local database, deny-by-default RLS, generated database
types, request-scoped Supabase clients, Next.js Proxy session refresh, and the
minimal account interface needed to verify the foundation.

The hosted Supabase project has not received these migrations, and no hosted
administrator has been provisioned. Marketplace data, payment processing, the
public homepage, and every marketplace workflow remain later-phase work.

Future contributors and Codex agents must read [AGENTS.md](./AGENTS.md) before
making changes. Work must stay inside one approved phase from
`docs/IMPLEMENTATION_PLAN.md`.

## Local development setup

### Prerequisites

- Node.js 24 LTS
- pnpm 11.9.0, as pinned by `package.json`
- Docker Desktop with a running Docker daemon

### Install

```sh
pnpm install --frozen-lockfile
```

The application builds without real secrets. To exercise Auth locally, create
an ignored `.env.local` from `.env.example` and use the local URL and
publishable key reported by the local Supabase CLI. Never copy hosted values
into source control. `APP_ENV` accepts
`development`, `test`, `staging`, or `production`; `PAYMENT_MODE` accepts
`disabled` or `mock`, but production rejects `mock`. Set the server-only
`APP_BASE_URL` to the application's trusted absolute HTTP(S) origin; local
origins are accepted only in development and test, while staging and
production require a non-local origin.

The browser contract uses `NEXT_PUBLIC_SUPABASE_URL` and
`NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`. `SUPABASE_SECRET_KEY` is server-only
and is not required for ordinary local account requests. Never commit
`.env.local`, secret-key values, recovery secrets, or encryption
keys.

Local email Auth mirrors the reviewed hosted policy: passwords contain at
least 8 characters with lowercase and uppercase letters, a digit, and a
symbol; secure password changes are enabled; and email OTPs contain 8
characters.

Before hosted deployment, configure the Auth redirect allowlist with both
exact trusted destinations derived from `APP_BASE_URL`:
`${APP_BASE_URL}/auth/confirm` and
`${APP_BASE_URL}/auth/confirm?next=/auth/update-password`. Do not use a
wildcard callback.

### Working commands

```sh
pnpm supabase:start
pnpm supabase:status
pnpm db:reset
pnpm db:lint
pnpm db:types
pnpm test:rls
pnpm dev
pnpm lint
pnpm typecheck
pnpm test
pnpm build
pnpm start
pnpm supabase:stop
```

`pnpm dev` starts the local development server. `pnpm start` serves a completed
production build. `pnpm db:reset` recreates the local database from committed
migrations, `pnpm db:types` regenerates the checked-in TypeScript database
types, and `pnpm test:rls` runs the real local pgTAP suite. Lint fails on
warnings, tests run once, and typecheck emits no files.

Local Studio, Auth, and Mailpit start with the Supabase stack. Mailpit supports
manual confirmation and recovery-email testing without an external email
provider.

The migration seeds `app_environment` for local development only. Staging
requires the deployment-only reviewed environment-provisioning operation.
Callable production enablement remains unavailable until the approved
reauthentication decision is resolved; the development seed is not production
configuration.

### Implemented account flows

- email/password registration and email confirmation callback;
- email/password sign-in and local-session sign-out;
- non-enumerating forgot-password request and password recovery;
- authenticated base-profile display and updates to approved fields only;
- owner-only profile and contact-fact access through RLS;
- exact, server-side administrator permission checks.

OAuth, phone login, anonymous login, administrator provisioning UI, and
marketplace navigation are intentionally absent.

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
Components are the default. Phase 1A provides deny-by-default RLS plus
idempotency and outbox schema/transaction foundations; later privileged
mutations and asynchronous workers will use those foundations when their
owning phases begin.

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
- Supabase PostgreSQL, Auth, local SQL migrations, pgTAP tests, and generated
  database types
- pnpm
- GitHub
- Vercel

Phase 1A adds only the official Supabase browser/SSR clients and project-scoped
CLI. It adds no payment, analytics, icon, state-management, component-library,
ORM, or marketplace dependency.

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
