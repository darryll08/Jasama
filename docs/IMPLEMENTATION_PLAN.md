# Jasama Implementation Plan

_Last updated: 2026-08-01_

## Document authority

This document governs implementation sequencing, phase boundaries, entry gates,
exit gates, and delivery approval only.

This document does not independently approve product decisions, state
transitions, database behavior, security exceptions, or open P1/P2 decisions.
Those requirements remain governed by the authority order in `AGENTS.md`.

A phase is not considered implemented merely because it is described in this
plan. A phase is complete only after its implementation exists, its required
checks pass, its scope is audited, and its completion status is recorded.

## Implementation status

| Phase | Status | Completion date |
|---|---|---|
| Phase 0 — Repository and quality foundation | **Complete** | 2026-07-28 |
| Phase 1 — Supabase foundation, account profile, and authorization | **Hosted development verification complete; final approval pending** | — |
| Phase 2–10 | **Not started** | — |

### Phase 0 completion evidence

The following Phase 0 quality gates passed on the local development environment:

- `pnpm install --frozen-lockfile` passed.
- `pnpm lint` passed with zero warnings.
- `pnpm typecheck` passed with zero errors.
- `pnpm test` passed with 4 test files and 13 tests.
- `pnpm build` passed.
- Next.js successfully generated `/` and `/_not-found`.
- TypeScript strict mode is enabled.
- The application uses the Next.js App Router.
- Tailwind and the approved global design foundation are configured.
- The approved fonts are configured through the framework font mechanism.
- Environment validation rejects mock payment in production.
- Public environment access excludes server-only secrets.
- The root application shell includes an Indonesian document language, semantic
  landmarks, a skip link, visible focus treatment, and reduced-motion behavior.
- Git was initialized on branch `main`.
- `.gitignore` excludes dependencies, generated builds, environment files,
  coverage, TypeScript build information, and local review archives.
- No real secrets were detected in project source or configuration.
- No Supabase client, SQL migration, authentication, marketplace workflow,
  payment-provider integration, scheduler, or Phase 1 implementation exists.
- All approved product, design, technical, security, state-machine, testing,
  and implementation documents remain present.

This status update is intended to be included in the initial Phase 0 commit on
the `main` branch.

Phase 1 must not begin before:

1. the Phase 0 commit exists;
2. the repository status and staged files have been reviewed;
3. the Phase 1 entry gate is satisfied.

## Delivery rules

- Implement one phase at a time.
- Each phase must be implemented, tested, audited, reviewed, and approved before
  the next phase starts.
- Do not silently start work from a later phase.
- Do not create all database tables in one initial migration.
- Add domain migrations only when the phase owning that domain begins.
- A shared foundation may move earlier only when the phase records the concrete
  dependency and reviewers approve the narrower migration.
- Every database change must be delivered through a reviewed SQL migration.
- Regenerate database types after every approved database migration.
- Every state-changing command must follow
  `docs/TRANSITION_COMMAND_MATRIX.md`.
- Do not expose generic status setters or client-controlled state transitions.
- Demo data is staging-only, carries `is_demo`, and must be rejected by
  production.
- Mock payment must be rejected by production independently of UI
  configuration.
- Phone verification blocks Mitra onboarding until a mechanism is selected,
  implemented, and tested.
- PDF and Office uploads remain disabled until an approved content validator
  exists.
- High-risk administrator actions remain disabled until verified
  reauthentication exists.
- No open P1/P2 decision may be silently enabled.
- Public user-uploaded images remain unavailable until an approved rendition
  generator has been selected, tested, and connected to moderation.
- Initial administrator provisioning is deployment-controlled and must finish
  before any administrator queue test.
- Provisioning must never be exposed through application UI, runtime user/admin
  commands, public API routes, or client code.
- A phase is never considered implemented merely because it is described in
  this plan.

## Phase 0 — Repository and quality foundation

- **Status:** Complete.
- **Completion date:** 2026-07-28.
- **Objective:** Scaffold only the approved web project and establish the
  smallest enforceable repository and quality baseline.
- **In scope:** Next.js App Router, strict TypeScript, Tailwind, pnpm lockfile,
  lint/typecheck/unit/build scripts, test layout, CI workflow, formatting
  conventions, environment validation, framework security headers, and a
  minimal accessible application shell.
- **Excluded:** Supabase project wiring, database migrations, authentication,
  product screens, homepage sections, demo records, domain commands, product
  route handlers, and deployment.
- **Documents read:** `AGENTS.md`, `README.md`, `PRODUCT.md`, `DESIGN.md`,
  `.env.example`, `docs/TECHNICAL_SPEC.md`, `docs/TEST_STRATEGY.md`,
  `docs/IMPLEMENTATION_PLAN.md`, and the related approved project documents.
- **Database objects:** None.
- **Application areas:** Repository configuration, root layout, minimal
  non-product page, error boundary, not-found boundary, metadata shell, global
  design foundation, environment modules, and unit-test harness.
- **Commands/RPCs:** No application command or RPC. Repository commands
  established and verified:
  - `pnpm lint`
  - `pnpm typecheck`
  - `pnpm test`
  - `pnpm build`
- **RLS policies:** None. Future database tables must enable RLS and deny access
  by default.
- **Tests implemented:**
  - environment-schema combinations;
  - production mock-payment rejection;
  - public/server environment separation;
  - application-shell heading and skip-link behavior;
  - absence of fabricated marketplace claims;
  - accessible error retry behavior;
  - approved design-foundation and motion assumptions.
- **Quality results:**
  - frozen-lockfile installation passed;
  - lint passed with zero warnings;
  - typecheck passed with zero errors;
  - 4 test files and 13 tests passed;
  - production build passed.
- **Observability:** Structured server-log fields and secret-redaction
  requirements are defined by the technical contracts. No observability vendor
  was added in Phase 0.
- **Data/demo behavior:** No application data or demo records exist.
  Environment validation reserves production rejection of demo and mock modes.
- **Security checks:** No secret is present in browser code or committed
  configuration; server-only environment access is separated; the unnecessary
  framework-powered header is disabled; baseline security headers are
  configured; no service-role client, database client, analytics, or external
  tracking exists.
- **Accessibility checks:** The document language is Indonesian; semantic
  landmarks and a skip link exist; keyboard focus is visible; reduced-motion
  behavior is defined; the root shell has one clear primary heading.
- **Acceptance criteria:** The approved stack is reproducibly scaffolded;
  frozen-lockfile installation and all required quality commands pass; the
  application shell is accessible; environment guards work; no domain or
  marketplace behavior is present.
- **Entry gate:** Repository guidance was approved and no application scaffold
  existed.
- **Exit gate:** Frozen-lockfile installation, lint, typecheck, unit tests,
  production build, dependency review, security review, accessibility review,
  environment review, Git initialization, and scope audit passed.
- **Rollback or recovery:** Revert the Phase 0 scaffold and configuration commit
  as one unit. No persistent data requires recovery.
- **Resolved toolchain:** Node.js 24 LTS and pnpm 11.9.0.
- **Remaining action:** Include the Phase 0 source, configuration,
  documentation-status update, and tests in the initial reviewed commit.
- **Phase boundary:** No Phase 1 source code, Supabase package, migration,
  authentication logic, generated database type, or marketplace feature was
  started.

## Phase 1 — Supabase foundation, account profile, and authorization

- **Status:** Hosted development verification completed on 2026-08-01; final
  Phase 1 approval remains pending.
- **Objective:** Establish identity, base profiles, least-privilege
  authorization, and deployment-controlled initial administrator access.
- **In scope:** Supabase clients by runtime, Auth-to-profile lifecycle, contact
  verification facts, admin permission catalog and assignments,
  provisioning-only bootstrap and recovery, audit/idempotency/outbox
  foundations, environment kill switches, and generated database types.
- **Excluded:** Mitra onboarding, public discovery, administrator queue UI,
  high-risk grants, government-ID data, real payment, and user/admin runtime
  provisioning.
- **Documents to read:** Product and PRD identity and administration sections,
  `docs/OPEN_DECISIONS.md` OD-02/13/22/28/30/31/33,
  `docs/TECHNICAL_SPEC.md`, `docs/DATABASE_SCHEMA.md`,
  `docs/SECURITY_RULES.md`, `docs/API_EVENTS_AND_JOBS.md`,
  `docs/TEST_STRATEGY.md`, `docs/TRACEABILITY_MATRIX.md`, and
  `docs/TRANSITION_COMMAND_MATRIX.md`.
- **Database objects:** `profiles`, `contact_verifications`,
  `admin_permissions`, `admin_permission_assignments`, `audit_events`,
  `idempotency_records`, `outbox_events`, `outbox_event_deliveries`, and
  `app_environment`. Shared audit/idempotency/outbox tables are justified here
  because every later binding command depends on them.
- **Application areas:** Sign-in/session boundary, profile settings, safe
  account lifecycle, and server-only authorization helpers. No administrator
  queue is included.
- **Commands/RPCs:** Profile/contact lifecycle and ordinary
  `grantAdminPermission`/`revokeAdminPermission` where approved. Bootstrap is a
  reviewed migration or provisioning-owner operation, never an application
  command or RPC.
- **RLS policies:** Owners may read only approved profile and active-contact
  status columns; profile changes use the reviewed owner command; effective
  ordinary grants use the minimum safe function projection; base permission,
  assignment, audit, outbox, idempotency, and environment tables remain
  privileged-only.
- **Tests:** Auth/profile lifecycle, deny-by-default RLS, cross-user denial,
  self-grant denial, insufficient-manager denial, successful exact bootstrap,
  idempotent replay, runtime user/admin provisioning denial, set-expansion
  denial, and `system_provisioning` audit coverage. Create and pass
  `pnpm test:rls`.
- **Observability:** Correlation and causation IDs, append-only authorization
  audit, provisioning outcome alerts, outbox dead-letter visibility, and secret
  redaction.
- **Data/demo behavior:** Optional non-production profile fixtures are marked
  `is_demo`; production constraints reject them. The bootstrap target must be
  an existing active, non-demo, Auth-backed profile. The committed
  `app_environment` seed is local-development configuration only; staging uses
  the reviewed deployment-only environment operation. Callable production
  enablement remains unavailable until verified reauthentication is approved.
- **Security checks:** Service-role credentials and encryption material remain
  server-only; exact grant target, permission set, and change reference are
  reviewed; no generic role, generic `is_verified`, self-grant, or runtime
  provisioning surface exists.
- **Accessibility checks:** Auth and profile controls have labels, error
  summaries, a solid 3px focus outline with 2px offset, and status
  announcements.
- **Acceptance criteria:** A normal account can manage only its approved profile
  fields; authorization tests deny privilege escalation; reviewed provisioning
  can create the first exact administrator permission set without self-grant
  and is fully audited.
- **Entry gate:**
  - Phase 0 initial commit exists and has been reviewed.
  - Supabase development, staging, and production environments are identified.
  - Supabase project access and secret ownership are assigned.
  - The administrator bootstrap target is identified.
  - The initial permission set and provisioning change reference have named
    reviewers.
  - The contact-email mechanism is confirmed.
- **Exit gate:** Migrations, generated types, and all applicable lint,
  typecheck, unit, RLS, and build checks pass; initial staging administrator
  provisioning is completed and audited before any later queue test.
- **Rollback or recovery:** Use forward-fix migrations. Revoke compromised
  ordinary grants through audited management and use reviewed provisioning
  recovery only when no valid permission manager remains. Never delete audit
  history.
- **Dependencies and blockers:** The hosted-development Supabase access,
  contact-email delivery, bootstrap target, exact ordinary permission set, and
  provisioning audit/replay checks are complete. The exit gate still requires
  initial staging administrator provisioning and final Phase 1 approval. Phone
  verification may remain unimplemented here but blocks Phase 3 entry.

### Phase 1 hosted development verification evidence — 2026-08-01

- The Phase 1 migration is applied to the hosted `jasama-dev` Supabase project.
- Hosted signup, email confirmation, sign-in, sign-out, password recovery,
  password update, profile read, and profile update passed.
- Development email delivery through the Mailtrap sandbox passed.
- The verified hosted profile is Auth-backed, email-confirmed, active, and
  non-demo.
- `app_environment` is `development` with `demo_allowed=true` and
  `mock_payment_allowed=true`.
- `provisioning.bootstrap_admin` completed with change reference
  `JASAMA-PHASE1-BOOTSTRAP-001` and exactly these global ordinary permissions:
  `admin.permissions.manage`, `profile.support`, and `account.moderate`.
- The three assignments and the `system_provisioning` audit record were
  verified. Exact replay created no duplicate assignment, and each active
  permission has exactly one assignment.
- `admin.permissions.high_risk` remains inactive and unassigned.
- No production, real-money, government-ID, Phase 2, or high-risk
  administrator capability was enabled.

## Phase 2 — Public homepage and discovery with demo data

- **Status:** Not started.
- **Objective:** Deliver the approved Pemesan-first homepage and public
  discovery without implying marketplace traction or unsupported trust.
- **In scope:** Eight approved categories, consisting of four local and four
  digital categories; the concise eight-part homepage; simplified navigation;
  search and filter state; responsive Jasa-card specification;
  empty/loading/error states; demo banner and demo records.
- **Excluded:** Real Jasa publishing, Mitra onboarding, ratings, testimonials,
  fabricated counts, fabricated rankings, fabricated partners, public
  user-uploaded originals, and booking.
- **Documents to read:** `PRODUCT.md`, `DESIGN.md`,
  `docs/HOMEPAGE_SHAPE.md`, discovery PRD/schema/security/test/traceability
  sections, and OD-01/21/25/34.
- **Database objects:** `categories`, `task_tags`, `category_task_tags`, and
  `localities`. Public page content may remain typed staging fixtures. Do not
  create Jasa tables early merely to support mock cards.
- **Application areas:** Homepage, category routes, discovery results, public
  Jasa-card shell, and not-found/empty/error/loading states.
- **Commands/RPCs:** Read-only public discovery query or projection when
  required. No state-transition command.
- **RLS policies:** Active taxonomy is public; every public projection excludes
  private profile, contact, and address fields and rejects demo rows in
  production.
- **Tests:** Exact category labels, order, and families; homepage section order
  and CTA hierarchy; search/filter URL state; responsive layouts; production
  demo rejection; claims/content checks; metadata and indexing behavior.
  Create `pnpm test:e2e` and pass all applicable commands.
- **Observability:** Privacy-safe page/query errors and aggregate discovery
  events only. Do not create fabricated success metrics.
- **Data/demo behavior:** A persistent staging-only demo banner and `is_demo`
  marker are required. Production excludes every demo row. Per-object labels
  appear only when demo and real data are intentionally mixed.
- **Security checks:** No private identifiers or exact location appear in
  public data; query inputs are sanitized; no public Storage original is
  exposed; the production kill switch is tested server-side.
- **Accessibility checks:** Heading order, landmarks, skip link, keyboard
  filters, focus indicators, touch targets, Indonesian labels, card alt rules,
  reduced motion, contrast, and reflow at supported widths.
- **Acceptance criteria:** The approved homepage hierarchy and eight categories
  render across supported breakpoints; `Jelajahi Jasa` is the primary CTA and
  `Buat Permintaan` is a prominent companion or fallback; demo and claim
  controls pass.
- **Entry gate:** Phase 1 is approved; homepage and design authorities are
  synchronized; demo dataset and production exclusion are reviewed.
- **Exit gate:** Visual, content, accessibility, security, unit, applicable RLS,
  E2E, and build checks pass; product and design reviewers approve the
  homepage.
- **Rollback or recovery:** Disable discovery routes or revert presentation and
  seed changes while preserving production constraints.
- **Dependencies and blockers:** Approved copy, sample content, and category
  seeds. Media rendition generation is not required for designed placeholders
  but is required before real user-uploaded public images.

## Phase 3 — Mitra onboarding and Jasa moderation

- **Status:** Not started.
- **Objective:** Let an account activate Mitra capability, complete reviewed
  onboarding, and submit versioned Jasa for manual pre-publication moderation.
- **In scope:** Phone/contact gate, Mitra profile and service areas, onboarding
  review machine, Jasa versions and tags, favorites, moderation cases, safe
  feedback, approved public projection, and an image upload/rendition path only
  when its gate is met.
- **Excluded:** Government-ID or face data, unsupported verification claims,
  open publishing, PDF/Office media, real payment, and high-risk administrator
  actions.
- **Documents to read:** PRD Mitra/Jasa sections; state machines 1–2;
  OD-01/02/13/14/17/18/21/22/31/33; relevant schema, security, API, test, and
  traceability sections; full transition matrix.
- **Database objects:** `mitra_profiles`, `mitra_service_areas`,
  `mitra_onboarding_reviews`, review events, `jasa`, `jasa_versions`, version
  tags, `jasa_moderation_cases`, and `favorites`. Create `attachments`,
  `jasa_media`, and `media_renditions` only for the narrowly approved public
  image pipeline because public Jasa images depend on it.
- **Application areas:** Mitra onboarding and status, Jasa draft/version editor,
  owner workspace, scoped onboarding/listing queues, and public approved Jasa
  page.
- **Commands/RPCs:** Exact onboarding/review and Jasa/moderation commands from
  the API contracts and all corresponding transition pairs. Rendition
  creation and revocation remain server or worker controlled.
- **RLS policies:** Candidates own drafts and see safe feedback; scoped
  administrators see assigned queues; visitors see approved projections and
  renditions only; private source attachments never become public.
- **Tests:** Every implemented machine edge and invalid edge; stale version,
  self-case and scope rules, moderation, production demo rejection, upload
  signature/size/type checks, rendition privacy/cache revocation, and public
  projection cases.
- **Observability:** Queue age, command failures, moderation/audit correlation,
  rendition worker retries and dead letters, and privacy-safe user notices.
- **Data/demo behavior:** Staging demo Mitra and Jasa remain marked and
  bannered; real submissions are never silently relabeled; production rejects
  demos.
- **Security checks:** Phone mechanism threat review; no government-ID field or
  bucket; allowlisted image signatures; metadata stripping; approved rendition
  only; queue permissions; administrator non-self-action.
- **Accessibility checks:** Multi-step form labels, errors and progress;
  saved-state announcements; moderation feedback semantics; image-alt workflow;
  keyboard media ordering; focus, reflow, and contrast.
- **Acceptance criteria:** An eligible verified-contact account can complete
  onboarding and a scoped reviewer can approve safe Jasa content; only the
  exact approved version and renditions become public.
- **Entry gate:** Phase 2 is approved; the phone verification mechanism is
  selected and tested; initial administrator provisioning is completed; the
  rendition generator is selected and tested before any real uploaded image
  can publish.
- **Exit gate:** Machines 1–2 and queue workflows pass transition, RLS,
  security, accessibility, audit, E2E, and build checks; operations approves
  the safe-feedback and moderation runbook.
- **Rollback or recovery:** Unpublish or revoke renditions through approved
  commands, retain immutable versions and events, pause queues, retry workers
  idempotently, and forward-fix migrations.
- **Dependencies and blockers:** Phone mechanism or provider, content
  operations, and rendition generator. PDF and Office files remain disabled
  regardless of image readiness.

## Phase 4 — Permintaan, Penawaran, and offer conversion

- **Status:** Not started.
- **Objective:** Let Pemesan publish privacy-minimized requests, eligible Mitra
  submit immutable offers, and atomically convert an accepted offer into a base
  Pesanan.
- **In scope:** Permintaan versions, tags, expiry, and visibility; Penawaran
  immutable replacement chains; acceptance failure and recovery; accepted
  commercial snapshot; atomic offer-to-order conversion.
- **Excluded:** Existing-Jasa confirmation, payment attempts, work execution,
  messaging, deliveries, public indexing, and unapproved expiry policy changes.
- **Documents to read:** PRD request/offer/order-conversion sections; machines
  3–5; OD-03/06/15/16/26/29/34; relevant technical contracts and all mapped
  transitions.
- **Database objects:** `permintaan`, request versions and tags, `penawaran`,
  offer versions, and the minimum `pesanan`, participant, commercial snapshot,
  and snapshot-tag records required by atomic conversion. This narrow Pesanan
  foundation is explicitly early because a converted offer cannot safely exist
  without its immutable destination and accepted terms. Phase 5 owns all
  remaining order behavior.
- **Application areas:** Pemesan request composer and workspace, eligible-Mitra
  request view, offer composer and replacement history, comparison and
  acceptance result, and a base order receipt only.
- **Commands/RPCs:** Exact publish/edit/expire/close request,
  submit/replace/withdraw/accept/decline/expire offer, and atomic conversion
  commands defined by the API and transition matrix. No generic status setter.
- **RLS policies:** Owners control request drafts; visitors receive only the
  privacy-minimized, non-indexable projection; eligible authenticated Mitra may
  respond; offers and terms are parties-only; accepted terms are immutable.
- **Tests:** All machine 3–4 edges and conversion pairs; self-dealing,
  eligibility, expiry race, replacement chain, double acceptance, idempotent
  retry, immutable terms, tags and category, privacy projection, and atomic
  rollback.
- **Observability:** Conversion correlation across request, offer, order, audit,
  and outbox; expiry-job outcomes; acceptance failure reason codes without
  private-data leakage.
- **Data/demo behavior:** Staging fixtures are marked throughout propagated
  aggregates; production rejects demo requests, offers, and orders.
- **Security checks:** No exact address, contact information, or private
  attachment appears in public request reads; actor, eligibility, and price are
  server-derived; cross-machine writes share one transaction and idempotency
  key.
- **Accessibility checks:** Form error summary, clear price and scope language,
  comparison semantics, expiry/status announcements, confirmation focus
  management, and keyboard/mobile completion.
- **Acceptance criteria:** A valid request and one eligible offer convert
  exactly once into a parties-only base order with immutable accepted source,
  category, tags, scope, amount, timing, and revision terms.
- **Entry gate:** Phase 3 is approved; the conversion transaction and immutable
  snapshot design are reviewed against the state machines and transition
  matrix.
- **Exit gate:** Machines 3–4 and mapped conversion tests, RLS, concurrency,
  audit, accessibility, E2E, and build checks pass; no Phase 5 order action is
  exposed.
- **Rollback or recovery:** Expiry and acceptance jobs replay idempotently; a
  failed conversion leaves no partial order; accepted history is never
  overwritten; migrations are forward-fixed.
- **Dependencies and blockers:** Eligible Mitra/Jasa foundations, locality and
  taxonomy, and approved request expiry and visibility rules.

## Phase 5 — Pesanan, terms versioning, mock payment, and scheduled jobs

- **Status:** Not started.
- **Objective:** Complete both order-entry paths and enforce confirmation,
  immutable terms, non-production mock payment, and time-based commands.
- **In scope:** Existing-Jasa order creation, typed terms proposals and
  acceptance, final confirmation, order cancellation before work, payment
  attempts, scheduled reminders/timeouts/expiry, private minimum-address
  release, and disabled payout records.
- **Excluded:** Real payment, refund, settlement, payout, automatic completion,
  messaging, work and delivery, high-risk remedies, and every open P1/P2 policy.
- **Documents to read:** PRD Pesanan, payment, and address sections; machine 5
  and mock-payment/payout machines; OD-03–12/15/29/32; schema, security, API,
  jobs, test, traceability contracts, and transition matrix.
- **Database objects:** Complete `pesanan`, participants, commercial snapshots
  and tags, `mock_payment_attempts`, `scheduled_commands`,
  `order_private_locations`, and disabled payout records. Reuse the Phase 1
  audit, idempotency, and outbox foundations.
- **Application areas:** Order confirmation and terms review, Pemesan and Mitra
  order status, mock-payment test controls in allowed environments, private
  address reveal, and scheduled-job operations view.
- **Commands/RPCs:** Exact create/propose/accept/final-confirm/order-payment and
  allowed cancellation commands; mock-attempt commands; scheduled
  claim/execute/recovery commands. Refund and payout commands have no route or
  grant.
- **RLS policies:** Parties see their order and current or retained terms; exact
  addresses decrypt server-side only after the approved gate; payment records
  use a parties-safe projection and privileged writes; jobs and outbox are
  worker-only.
- **Tests:** Exact order, payment, and payout-disabled pairs; stale terms,
  timeout, retry, amount/currency, concurrency, address gate, encryption and
  key version, scheduled claim/recovery/idempotency, production mock hard
  failure, and absence of real-money routes.
- **Observability:** Job lag, retry, dead letter, mock notices, order/payment
  correlation, decryption-access audit, and environment-mismatch alerts.
- **Data/demo behavior:** Mock payment is visibly persistent and available only
  in approved non-production environments; production rejects mock mode and
  demo aggregates at multiple layers.
- **Security checks:** Server-derived money and terms; authenticated internal
  recovery; encryption keys supplied by the secret manager; no address or
  secret logging; real-money and payout capabilities remain absent.
- **Accessibility checks:** Terms changes are readable and explicitly accepted;
  timers do not rely on color; notices and status changes are announced;
  confirmation dialogs manage focus and remain usable at zoomed and mobile
  sizes.
- **Acceptance criteria:** Both order paths reach only valid machine states;
  terms remain immutable and versioned; scheduled events execute once; mock
  payment may advance an allowed test order but is impossible in production.
- **Entry gate:** Phase 4 is approved; environment kill-switch tests and the
  private-address key ownership and rotation runbook are reviewed.
- **Exit gate:** Applicable order, job, encryption, RLS, audit, unit,
  concurrency, E2E, accessibility, and build checks pass; finance and security
  confirm that no real-money path exists.
- **Rollback or recovery:** Pause job claims, replay by idempotency and
  correlation, retain terms/payment/audit history, rotate compromised keys and
  re-encrypt through a reviewed job, and never destructively roll back accepted
  terms.
- **Dependencies and blockers:** Secret manager, scheduler and recovery
  authentication. OD-10/11/12 remain disabled and cannot block users until
  approved.

## Phase 6 — Contextual messaging and private attachments

- **Status:** Not started.
- **Objective:** Enable messages only inside authorized marketplace contexts
  and private file access bound to current participation.
- **In scope:** Context threads, participants and successors; messages; upload
  grants; server-derived validation; attachment links; participant revocation;
  signed reads; approved safe file types.
- **Excluded:** Open direct messages, public originals, identity documents,
  server-fetching external links, PDF/Office files until validator approval,
  and cross-context history movement.
- **Documents to read:** PRD messaging and files; OD-15/16/17/33; messaging and
  attachment schema, security, API, test, and traceability sections; related
  transition-matrix pairs.
- **Database objects:** `message_threads`, thread participants, `messages`,
  `attachments`, `message_attachments`, and file-access grant/audit records.
  Reuse any existing narrowly introduced attachment records instead of
  duplicating them.
- **Application areas:** Contextual thread UI for Jasa inquiry, Permintaan,
  Penawaran, Pesanan, Report, and Dispute; upload and validation states;
  successor-history links.
- **Commands/RPCs:** `createContextThread`, `createSuccessorThread`,
  `revokeThreadParticipant`, `sendMessage`, `requestUploadGrant`,
  `finalizeUpload`, and authorized download grant, following the exact
  contracts.
- **RLS policies:** Active context participants only; revoked participants lose
  future reads and grants; the service validates objects; signed URLs are
  short-lived and never replace authorization.
- **Tests:** No-direct-message invariant; sole-context constraint; dedicated
  offer threads; successor access; revocation; five-file and 10 MB limits;
  MIME, signature, extension and SHA validation; quarantine and rejection; URL
  expiry; cross-context denial; PDF/Office denial until the approval gate.
- **Observability:** Safe message/upload errors, validation queue age,
  unauthorized-access audit, and object-cleanup/retry metrics without content
  logging.
- **Data/demo behavior:** Demo contexts and files remain non-production and
  marked; fixture objects use synthetic content; production cannot accept them.
- **Security checks:** Private bucket, path-bound short-lived grants,
  server-derived metadata and hashes, no browser checksum trust, no identity
  document purpose, content-validator gate, and download authorization on
  every request.
- **Accessibility checks:** Message chronology and name semantics, composer
  labels, upload progress and errors, keyboard file removal, focus after send,
  non-color status, and screen-reader announcements.
- **Acceptance criteria:** Only current context participants can message and
  read approved private files; revocation closes future access; unsafe or
  disabled file types never validate.
- **Entry gate:** Phase 5 is approved; the private Storage lifecycle and
  allowlist are reviewed; a content validator is selected before PDF/Office
  files can be enabled.
- **Exit gate:** Messaging/file RLS, security-abuse, lifecycle, accessibility,
  E2E, audit, worker, and build checks pass; privacy and security reviewers
  approve signed access and revocation.
- **Rollback or recovery:** Disable upload grants or thread creation, revoke
  access grants, quarantine objects, retry validation idempotently, and
  preserve message and audit history.
- **Dependencies and blockers:** Storage configuration and content validator.
  PDF and Office files remain disabled while the validator is absent or
  unverified.

## Phase 7 — Work execution, digital delivery, local proof, and revisions

- **Status:** Not started.
- **Objective:** Execute accepted orders through family-specific, immutable
  submission and revision workflows.
- **In scope:** Work machine, digital delivery versions, items and external
  links, local proof versions and items or customer confirmation, revision
  allowance and requests, and atomic order/work/submission synchronization.
- **Excluded:** GPS or EXIF proof, provider-hosted file fetching, unlimited
  revisions, automatic completion, and financial remedies.
- **Documents to read:** PRD fulfillment and revision sections; work, delivery,
  proof, revision and relevant order machines; OD-09/10/11/17/27; technical
  contracts and transition matrix.
- **Database objects:** `work_executions`, digital delivery versions and items,
  digital external links, local proof versions and items, and
  `revision_requests`. Existing private attachments and immutable commercial
  snapshots are reused.
- **Application areas:** Work status, digital delivery composer and review,
  local proof composer and confirmation, revision request, response, and
  progress.
- **Commands/RPCs:** Exact prepare/start/progress/submit/accept work,
  create/process/decide delivery and proof, request/respond/progress revision,
  and atomic synchronization commands from the approved contracts.
- **RLS policies:** Order parties see their own work and submissions; Mitra may
  write valid drafts; Pemesan decides exact submitted versions; scoped dispute
  access only; public access is denied.
- **Tests:** Every implemented transition pair; family mismatch; stale version;
  revision count and window; duplicate or open revision; external HTTPS
  validation and no-fetch guarantee; local evidence without GPS or EXIF;
  atomic order/work synchronization; cancellation race.
- **Observability:** Submission processing and retry, version correlation,
  revision counters, validation failures, safe notifications, and outbox
  delivery state.
- **Data/demo behavior:** Synthetic staging deliveries and proofs are marked
  through the parent aggregate and excluded from production.
- **Security checks:** Private object authorization, immutable submissions,
  sanitized links, metadata stripping, no implicit external fetch, and no
  client-controlled cross-machine writes.
- **Accessibility checks:** Status timelines, version labels, upload and link
  forms, proof alternatives, revision allowance and deadline copy, keyboard,
  focus and error behavior, and reduced motion.
- **Acceptance criteria:** A ready order follows only its local or digital
  fulfillment path, produces one immutable submitted version, and may complete
  or perform only the snapshotted allowed revisions.
- **Entry gate:** Phase 6 is approved; family-specific proof/delivery validation
  and revision snapshot rules are reviewed.
- **Exit gate:** Fulfillment and revision transition, atomicity, RLS,
  file/privacy, accessibility, E2E, audit, and build checks pass; operations
  approves both family runbooks.
- **Rollback or recovery:** Retry processors idempotently, supersede rather than
  overwrite submissions, return only through explicit machine edges, retain
  evidence and audit history, and disable submission creation when validator
  health fails.
- **Dependencies and blockers:** Approved attachment capabilities and the exact
  commercial revision snapshot. OD-10/11 remain disabled unless separately
  approved and synchronized.

## Phase 8 — Cancellation, reviews, reports, and disputes

- **Status:** Not started.
- **Objective:** Add governed post-commitment remedies and trustworthy feedback
  without inventing financial or policy outcomes.
- **In scope:** Cancellation cases and execution, genuine-order review
  eligibility, edit, withdrawal and moderation, reports and evidence, disputes
  and evidence, nonfinancial decisions, holds, and cross-machine
  synchronization.
- **Excluded:** Automatic refunds, payouts or settlements, provider responses
  to reviews, fabricated reviews or ratings, unapproved dispute deadlines or
  appeals, high-risk remedies, and financial remedies.
- **Documents to read:** PRD trust and remedy sections; cancellation, report,
  dispute, and review machines; OD-07/08/10–12/17/19/22/23/30/32; technical
  contracts and full transition matrix.
- **Database objects:** `cancellation_cases`, `reviews`, review versions,
  `reports`, report evidence, `disputes`, dispute evidence, and decision and
  implementation records. Reuse attachments, audit, and outbox foundations.
- **Application areas:** Party cancellation, review authoring and history,
  reporting, dispute evidence and case status, and scoped ordinary
  administrator case queues.
- **Commands/RPCs:** Exact cancellation, report, dispute, review, hold, and
  nonfinancial remedy commands. Refund, payout, and high-risk decision routes
  remain absent.
- **RLS policies:** Parties and case participants see safe scoped records;
  evidence is private; reviewers own their review actions; public users see
  only genuine visible reviews; scoped administrators cannot act on
  self-cases.
- **Tests:** Every allowed and denied edge; source-state restoration;
  cancellation versus work/payment races; one-review and edit-window rules;
  provenance and aggregates; duplicate reports; evidence disclosure; hold
  behavior; self-case and scope denial; unavailable deadline, refund, and
  high-risk paths.
- **Observability:** Case age, hold duration, decision/effect correlation,
  implementation failures, review aggregate provenance, and safe party
  notices.
- **Data/demo behavior:** Demo reviews never enter production or real
  aggregates; no testimonial, rating, or count fabrication; demo cases and
  evidence remain synthetic and excluded.
- **Security checks:** Evidence privacy, rate limits, sanitized safe notes,
  immutable decisions, nonfinancial-only remedies, and no inference that a
  report proves wrongdoing.
- **Accessibility checks:** Sensitive forms use clear language and error
  summaries; timelines and holds are announced; rating inputs are keyboard and
  screen-reader usable; evidence controls and dialogs preserve focus.
- **Acceptance criteria:** Approved nonfinancial cancellation, review, report,
  and dispute flows follow exact transitions and preserve evidence; public
  reviews derive only from genuine completed orders.
- **Entry gate:** Phase 7 is approved; operations, legal, and security reviewers
  approve closed-beta nonfinancial case runbooks and safe-copy boundaries.
- **Exit gate:** Remedy transition, RLS, abuse, evidence, concurrency,
  accessibility, E2E, audit, and build checks pass; no disabled P1/P2 or
  financial action is reachable.
- **Rollback or recovery:** Pause case commands, retry decision effects
  idempotently, use explicit reopen or recovery edges, hide unsafe public
  reviews through moderation while retaining history, and never delete
  evidence or audit records.
- **Dependencies and blockers:** Scoped case administrators and attachment
  validation. OD-08/10/11/12/22/32 remain gating decisions and are not assumed.

## Phase 9 — Administrator operations and closed-beta hardening

- **Status:** Not started.
- **Objective:** Complete least-privilege operational queues and harden the
  entire closed-beta system for controlled use.
- **In scope:** Queue navigation and projections, ordinary scoped decisions,
  account restrictions and appeals, permission management, audit/outbox/job
  diagnostics, rate limits, approved retention jobs, and incident runbooks.
- **Excluded:** Runtime provisioning, self-grant, high-risk grants or actions
  without verified reauthentication, permanent-ban paths when gated, financial
  actions, and unapproved P1/P2 behavior.
- **Documents to read:** All authorities, especially
  OD-19/20/22/24/28/30/31; administrator, security, API, job, test,
  traceability contracts; transition matrix.
- **Database objects:** `account_restrictions`, restriction decisions and
  appeals, and administrator-safe queue or read models only when review proves
  them necessary. Do not duplicate permission, audit, job, or outbox tables.
- **Application areas:** Scoped administrator shell, onboarding, listing,
  report, dispute, and account queues, permission management, operational
  diagnostics, and recovery.
- **Commands/RPCs:** Existing scoped administrator commands, account
  restriction and appeal commands, ordinary grant and revoke, and reviewed job
  replay. Provisioning remains deployment-only; high-risk commands remain
  unavailable.
- **RLS policies:** Permission and locality scope apply to every queue, record,
  and action; no self-case or self-grant; diagnostics expose minimal payloads;
  the provisioning owner has no runtime execute grant.
- **Tests:** Cross-scope matrix, confused-deputy and self-action denial,
  revoked-session effects, queue leakage, ordinary grant rules, runtime
  provisioning denial, high-risk route absence, append-only audit,
  outbox/job replay and dead letter, rate limits, and incident cases.
- **Observability:** Queue age and error budget, authorization denials,
  permission changes, provisioning-audit verification, dead letters, recovery
  outcomes, and redacted security alerts.
- **Data/demo behavior:** Staging queue fixtures are marked and bannered;
  production excludes demo rows; public metrics never mix demo evidence.
- **Security checks:** Least privilege, session invalidation, CSRF and origin
  protection, reauthentication gate, audit tamper resistance, secret and
  Storage review, provisioning-path inspection, and rate and abuse controls.
- **Accessibility checks:** Queue tables and cards reflow; ordinary actions are
  keyboard usable; scopes and reasons are clear; dialogs manage focus; outcomes
  are announced; priority and state do not rely only on color.
- **Acceptance criteria:** Administrators can perform only approved ordinary
  scoped operations; initial provisioning remains deployment-only; high-risk,
  financial, and disabled decision paths remain unreachable.
- **Entry gate:** Phase 8 is approved; initial administrator provisioning is
  completed and audited; named operations and security testers and scope
  assignments exist.
- **Exit gate:** Full authorization, queue, audit, job, security,
  accessibility, E2E, and build suites pass; the threat model and operations
  runbooks are approved.
- **Rollback or recovery:** Revoke ordinary assignments through audited
  management, use provisioning recovery only under reviewed ownership, disable
  affected queues or commands, replay jobs safely, and preserve all audit
  facts.
- **Dependencies and blockers:** Verified reauthentication blocks every
  high-risk behavior; support, notification, and retention P1/P2 decisions
  remain disabled.

## Phase 10 — Closed-beta deployment and acceptance

- **Status:** Not started.
- **Objective:** Deploy the approved closed-beta slice and prove operational,
  privacy, security, accessibility, and recovery readiness.
- **In scope:** Production configuration validation, migrations in phase order,
  smoke and acceptance tests, backup and recovery rehearsal, monitoring and
  alerts, runbooks, controlled access, and launch sign-off.
- **Excluded:** New domain features, real money or payouts, government ID,
  unapproved P1/P2 behavior, broad public launch, and fabricated evidence.
- **Documents to read:** All authorities and contracts, this plan, deployment,
  incident, and data runbooks, and every recorded phase approval.
- **Database objects:** No new domain tables. Apply only approved phase
  migrations and production constraints. Operational indexes or fixes require
  separate review.
- **Application areas:** Closed-beta deployment, health and error pages,
  operational acceptance, and rollback controls. Do not expand feature scope.
- **Commands/RPCs:** No new product command. Exercise approved smoke commands
  with synthetic controlled accounts and verify that disabled routes remain
  absent.
- **RLS policies:** Run the complete production-equivalent RLS suite and inspect
  grants, service roles, provisioning ownership, Storage policies, and public
  projections.
- **Tests:** All lint, typecheck, unit, RLS, E2E, and build checks; migration
  rehearsal; backup restoration; kill switches; secret-rotation drill;
  scheduled and outbox recovery; privacy, claims, accessibility acceptance;
  production smoke tests.
- **Observability:** Production dashboards and alerts for authentication,
  command failures, queues, jobs, outbox, Storage validation, security denials,
  and recovery; confirm log redaction.
- **Data/demo behavior:** Production rejects every `is_demo` row and
  `PAYMENT_MODE=mock`; acceptance fixtures use isolated synthetic accounts and
  are cleaned through approved lifecycle operations without falsifying public
  evidence.
- **Security checks:** Final threat review, grants, RLS, Storage, secrets, CSP,
  headers, rate limits, bootstrap isolation, absence of real-money and
  government-ID integrations, vulnerability review, and dependency review.
- **Accessibility checks:** Complete keyboard, screen-reader, zoom and reflow,
  contrast, focus, reduced motion, error and status, Indonesian content, and
  representative mobile acceptance.
- **Acceptance criteria:** Approved closed-beta journeys work in the controlled
  production environment; recovery and alerts are proven; every exclusion and
  kill switch is independently verified.
- **Entry gate:** Phases 0–9 each have recorded implementation, tests, audits,
  and approval; launch owners approve the scope, runbooks, and rollback
  thresholds.
- **Exit gate:** Product, design, engineering, security, privacy or legal, and
  operations reviewers sign off closed-beta acceptance. Unresolved blockers
  prevent launch instead of expanding scope.
- **Rollback or recovery:** Use the rehearsed deployment rollback, disable
  traffic or commands, pause workers, restore or forward-fix data as
  appropriate, rotate secrets, preserve audit and evidence, and communicate
  through the incident runbook.
- **Dependencies and blockers:** Hosting and Supabase production ownership,
  monitoring and on-call coverage, backup and restore proof, legal and privacy
  review, operations staffing, and every required phase approval.
