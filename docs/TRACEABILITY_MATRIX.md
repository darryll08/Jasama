# Jasama Closed-Beta Traceability Matrix

Status: coverage map from product/design requirements and decisions to technical controls and verification.

Abbreviations: `TS` = `TECHNICAL_SPEC.md`; `DB` = `DATABASE_SCHEMA.md`; `SEC` = `SECURITY_RULES.md`; `API` = `API_EVENTS_AND_JOBS.md`; `TEST` = `TEST_STRATEGY.md`. Status values are **P0 approved**, **Open/disabled**, **Deferred**, or **Covered**. Rows map requirements without changing their authority.

## 1. Product authority

| ID / requirement | Status | Technical control | Schema / command / RLS | Verification |
|---|---|---|---|---|
| PROD-Platform — web marketplace for local and digital services | Covered | TS scope/runtime; server-rendered mobile web | categories/service-family typed throughout; public queries | E2E 1, 6, 9, 10 |
| PROD-Users — Pemesan, optional Mitra capability, scoped admin | P0 approved | no role field; capability/permission composition | `profiles`, `mitra_profiles`, assignments; auth matrix | E2E 3, 4; full RLS actor matrix |
| PROD-Purpose — discover/order or post request/receive offer | P0 approved | public discovery and two order-source paths | Jasa/Permintaan/Penawaran/Pesanan commands | E2E 1, 2, 5–8 |
| PROD-Context — Indonesian, mobile-first, varied digital literacy, Surabaya local pilot | P0 approved | `id-ID`, responsive/accessibility contract, locality/timezone model | `localities`, IANA timezone, route/query projections | E2E widths; accessibility/manual copy tests |
| PROD-Capabilities — auth/profile/dashboards/listings/requests/offers/messages/orders/delivery/reviews/favorites/safety | P0 approved | TS route/boundary map | domain tables/commands/RLS for every capability | E2E 1–14 and PRD matrix below |
| PROD-Constraints — no AI, wallet, GPS, video, complex bidding | Covered | no proposed subsystem/dependency/field | no wallet/GPS/video/AI schema; one contextual offer model | schema/route/dependency forbidden scans |
| PROD-Brand — trustworthy, practical, inclusive, local/digital | Covered | design authority preserved; claims require evidence | public safe projections and provenance | content/trust, a11y, E2E 1 |
| PROD-P1 Trust is operational | P0 approved | typed history, proof, review provenance, report/dispute, no unsupported claims | snapshots, proof, review, report/dispute, audit | E2E 5, 9–14 |
| PROD-P2 Simple practical path | Covered | Server Components/default platform patterns; direct commands | discovery/order command/query contract | E2E 1, 2, 6–10 |
| PROD-P3 Local and digital together | Covered | shared order core, family-specific submission | `service_family`, digital delivery/local proof | E2E 9, 10 |
| PROD-P4 Indonesian/inclusive | Covered | Indonesian terms/formatting; semantic/native UI | locale/timezone profile fields | content and accessibility suites |
| PROD-P5 Safety before growth | P0 approved | deny default, manual moderation, restrictions, evidence | review/moderation/report/dispute/audit domains | E2E 4, 5, 12, 13; RLS tests |
| PROD-A11Y — semantics, keyboard, focus, contrast, labels/errors, non-color, touch | Covered | DESIGN binding; TS accessibility | UI only; safe state/error payloads | automated + manual accessibility section |

## 2. Design authority

| DESIGN constraint | Status | Technical control | Schema/API relationship | Verification |
|---|---|---|---|---|
| 70% Koperasi Modern / 30% Papan Jasa Kota; modest corners/depth | Covered | Tailwind tokens/components follow DESIGN; no extra visual authority here | none | visual/component review |
| Color/action/focus tokens; 3px solid outline, 2px offset; light/inverse focus | Covered | semantic tokens, no opacity-only ring | errors/status include text codes | manual focus/contrast; component tests |
| Border subtle/default/strong roles | Covered | token implementation by interaction role | none | visual regression/component review |
| Typography and Indonesian formatting | Covered | server/localized formatter; no image text | money bigint/IDR; timezone | formatting units and E2E |
| Spacing, breakpoints, containers, 320px reflow | Covered | mobile-first CSS; RSC content | paginated projections bound content | 320px/200% manual and browser suite |
| Dashboard/dense-data hierarchy | Covered | route groups and task-first server queries | owner/admin queues paginated | dashboard/admin E2E |
| Buttons/forms: one primary, native controls, labels, errors, persistence | Covered | Server Actions + boundary errors; local state only where needed | stable error codes, expected version | component tests; E2E recovery |
| Simplified public navigation and Pemesan-first hierarchy | Covered | public route/navigation contract | public discovery queries | E2E 1 |
| `Jelajahi Jasa` primary; `Buat Permintaan` prominent fallback | Covered | homepage/browse contract | browse-to-request prefill | E2E 1, 2 |
| Eight homepage categories, four local/four digital | P0 approved | category seed/query | `categories`, tags | seed contract test; E2E 1 |
| Jasa/Mitra card order, genuine review/price/provenance | Covered | safe public projection | public queries; review provenance; listing versions | E2E 1, 5, 14 |
| Search/filter, ARIA combobox, manual location, state restoration | Covered | URL params and client interaction only | indexed search projections; `localities` | component + E2E 1, 2 |
| Loading/empty/no-results/error/success/unavailable | Covered | typed result/error states and recovery | stable error contract | component suites and E2E failures |
| Status/trust copy; no guarantees/protection/24h/false verification | P0 approved | allowlisted copy and provenance | Mitra review and audit/history facts | prohibited-copy scan; E2E |
| Material Symbols Sharp only | Covered | asset family; no icon abstraction dependency | none | UI review |
| Documentary imagery; factual alt/captions; no fabricated testimonial | Covered | approved renditions and explicit alt text | `jasa_media`, moderation | media/content tests |
| Demo banner, `is_demo`, production exclusion, conditional per-object label | P0 approved | environment and DB kill switches | demo columns/guards/public queries | demo suite |
| Motion and reduced motion | Covered | CSS-native duration/reduction | none | reduced-motion tests |
| WCAG 2.2 AA and inclusive Indonesian copy | Covered | TS/TEST accessibility contract | safe messages/status labels | automated/manual release gate |
| Reusable semantic naming; no premature abstractions | Covered | TS dependencies/boundaries; Tailwind token roles | typed domain names | static review |
| Prohibited decorative/claim patterns | Covered | DESIGN remains direct implementation authority | evidence-backed projections only | visual/content release review |

## 3. PRD section coverage

| PRD section | Status | Technical control | Schema / API / RLS | Verification |
|---|---|---|---|---|
| 1 Product Summary | Covered | TS scope | all domain roots | full suite |
| 2 Problem Statement | Covered | two discovery/order paths | public/Jasa/Permintaan flows | E2E 1, 2, 6 |
| 3 Goals | P0 approved | scope boundaries and metrics events | outbox/audit safe facts | journey and event tests |
| 4 Non-Goals | Deferred | no native apps/AI/wallet/GPS/video/complex auction | absent schema/API/deps | forbidden-surface scan |
| 5 Target Users | Covered | capability model and inclusive UI | profiles/Mitra/admin grants | E2E 3; a11y |
| 6 Roles/Permissions | P0 approved | compositional authorization | profile/capability/grant RLS | RLS matrix |
| 7 Multiple Non-Admin Roles + deactivation/restrictions | P0 approved | no role switch; explicit restrictions | profile/account state commands | E2E 3, 12 |
| 8 Local vs Digital | P0 approved | shared core + family-specific delivery | family checks, delivery/proof | E2E 9, 10 |
| 9 Category Model | P0 approved | eight seeds plus version-bound category/tags copied into order snapshots | category/version/tag/snapshot joins | seed/history/order reproducibility tests |
| 10 Terminology | Covered | Indonesian domain names/copy contract | domain types/events | content scan |
| 11 User Stories | Covered | route/query/command map | all participant/admin commands | E2E 1–14 |
| 12 Public Pages | Covered | public Server Components/projections | homepage/search/public queries | E2E 1, 2 |
| 13 Auth/Onboarding | P0 approved | Supabase Auth + separated review | profile/contact/Mitra review | E2E 3, 4 |
| 14 Pemesan Dashboard | Covered | owner server queries | requests/orders/favorites/notifs | E2E 2, 6–11, 14 |
| 15 Mitra Dashboard | Covered | Mitra capability queries | Jasa/offers/work/review state | E2E 4–10 |
| 16 Admin Dashboard | P0 approved | least-privilege queues; deployment-only initial bootstrap before queue testing | sourced permission assignments and scoped queries | bootstrap/RLS plus E2E 4, 5, 12, 13 |
| 17 Jasa Management | P0 approved | immutable versions/manual moderation | Jasa tables/commands/RLS | E2E 5 |
| 18 Permintaan Management | P0 approved | privacy-minimized 14-day flow | Permintaan versions/expiry job | E2E 2, 6 |
| 19 Penawaran | P0 approved | replacement creates a new linked aggregate/sequence and successor thread; old remains replaced | offer-chain FKs/partial uniqueness/versioned terms | E2E 6; chain concurrency/history |
| 20 Messaging/Attachments | P0 approved | six exactly-one contexts; explicit participant lifecycle; eight upload types; five files per message/submission | thread/message/attachment/link RLS | RLS/storage/schema-hardening tests |
| 21 Pesanan | P0 approved | one-to-many immutable terms versions, `terms_version` current pointer by number, explicit source/category/tag provenance | Pesanan/snapshot versions/history; Mitra FK to capability | E2E 6–11; snapshot lifecycle tests |
| 22 Digital Delivery/Local Proof | P0 approved | immutable family-specific submissions | machines 8/9 tables/commands | E2E 9, 10 |
| 23 Revisions | P0 approved | snapshotted allowance | revision machine | E2E 9 |
| 24 Cancellation | P0 approved | state-based, finance separate | cancellation/order/work commands | E2E 11 |
| 25 Payment Assumptions | P0 mock / real open | multi-layer mock kill switch | mock attempts; payout disabled | mock/disabled tests |
| 26 Ratings/Reviews | P0 approved | completed-order provenance, one edit | reviews/versions | E2E 14 |
| 27 Favorites/Rebooking | P0 favorites; rebooking direct path | owner-only favorites; new order snapshot | favorites/RLS; order create | E2E dashboard/discovery |
| 28 Verification | P0 closed-beta review | no ID path; separate contact/review | Mitra review only | E2E 4; identity scans |
| 29 Listing Moderation | P0 approved | manual pre-publication/material-edit review | moderation cases/commands | E2E 5 |
| 30 Reports/Disputes | P0 approved | private evidence/versioned remedies | machines 12/13 | E2E 12, 13 |
| 31 Notifications | P0 in-app; external channels open | outbox → recipient notifications | notifications/RLS/jobs | event/query tests |
| 32 Location/Privacy | P0 approved | locality taxonomy, exact-address release, no GPS | private locations/service areas | E2E 10; privacy tests |
| 33 Academic Integrity/Prohibited Services | P0 approved | listing/request/report moderation reason codes | moderation/report domains | policy fixture tests |
| 34 Accessibility | Covered | WCAG 2.2 AA binding | safe status/error payloads | a11y suite |
| 35 Development/Staging Data | P0 approved | banner/marker/production guard | `is_demo`, environment triggers | demo suite |
| 36 Analytics Events | Covered with privacy | versioned safe outbox/audit facts; no public claims | outbox payload allowlist | event-schema/privacy tests |
| 37 Success Metrics | Baseline only | measurement without fabricated thresholds | safe event facts | OD-25 gate tests |
| 38 Functional Acceptance | P0 approved | command/query/state contract | all domains | fourteen E2E journeys |
| 39 Non-Functional Acceptance | Covered | security/a11y/performance/observability and independent outbox delivery state | RLS/jobs/outbox deliveries/audit/indexes | release gates |
| 40 Deferred Features | Deferred | decision gates/absent routes and schema | no real finance/identity/advanced features | disabled-feature suite |

## 4. State-machine coverage

| Machine | Status | State storage | Commands / cross-machine control | RLS / tests |
|---|---|---|---|---|
| 1 Mitra onboarding | P0 approved; expiry conditional | `mitra_onboarding_reviews` + events | onboarding/review commands | owner/reviewer RLS; E2E 3–4; pair suite |
| 2 Jasa | P0 approved | `jasa`, versions, moderation | draft/submit/moderate/availability | owner/public/moderator; E2E 5 |
| 3 Permintaan | P0 approved | `permintaan`, versions | publish/close/select/convert/expiry | privacy/eligible RLS; E2E 2, 6 |
| 4 Penawaran | P0 approved | `penawaran`, versions | draft/replace/decide/accept transaction | author/request owner; E2E 6 |
| 5 Pesanan | P0 approved | `pesanan`, snapshot/history | create/confirm/start/submit/complete/cancel sync | parties/admin; E2E 6–11 |
| 6 Payment | P0 mock subset only | `mock_payment_attempts` | create/resolve simulation; refund absent | parties/test server; E2E 7; kill-switch tests |
| 7 Work | P0 approved | `work_executions` | prepare/progress/revision/finish | parties; E2E 9–11 |
| 8 Digital delivery | P0 approved | delivery versions/items | draft/process/decide | parties/dispute admin; E2E 9 |
| 9 Local proof | P0 approved | proof versions/items | draft/submit/decide | parties/dispute admin; E2E 10 |
| 10 Revision | P0 approved | `revision_requests` | request/respond/progress/fulfill sync | parties; E2E 9 |
| 11 Cancellation | P0 approved | `cancellation_cases` | request/respond/decide/execute | parties/admin; E2E 11 |
| 12 Report | P0 approved | reports/evidence | submit/triage/investigate/close | reporter/scoped admin; E2E 12 |
| 13 Dispute | P0 approved; deadline open | disputes/evidence | submit/review/collect/decide/implement | parties/scoped admin; E2E 13 |
| 14 Review | P0 approved | reviews/versions | eligibility/draft/publish/edit/moderate | public/owner/moderator; E2E 14 |
| 15 Account moderation | P0 approved | profile state/restriction history | deactivate/restrict/appeal/decide | subject/scoped admin; E2E 12 |
| 16 Payout | Open/disabled | disabled-only placeholder | ensure disabled; management absent | server diagnostic; disabled tests |

`TRANSITION_COMMAND_MATRIX.md` contains exactly one explicit row for each of the 266 documented pairs and no extra pair. Contract tests compare it with the state catalogs and database allowlist and deny decision-conditional rows during closed beta.

## 5. Open-decision coverage

| Decision | Status | Closed-beta control | Schema / command / RLS | Verification |
|---|---|---|---|---|
| OD-01 Geography | P0 approved | digital where supported; local Surabaya pilot; extensible taxonomy | localities/service areas/timezone | locality eligibility and E2E 1, 10 |
| OD-02 One account, Pemesan + Mitra | P0 approved | base account + optional capability | profiles/Mitra; no role | E2E 3; schema scan |
| OD-03 Pricing | P0 approved | Jasa fixed/base and exact active-chain offer terms; all order terms versions retained | typed source/versioned snapshots | E2E 5, 6; money/snapshot tests |
| OD-04 Service fee | Open P2 / disabled | no fee | no fee column/command | absent-feature scan |
| OD-05 Initial payment | Open P2 / disabled for real money | mock only outside production | mock attempts; no adapter | kill-switch suite |
| OD-06 Payment timing | P0 approved | confirm, mock if required, then work | order/payment/work synchronized commands | E2E 7; impossible-transition tests |
| OD-07 Cancellation | P0 approved | state-based; finance outcomes separate | cancellation machine | E2E 11 |
| OD-08 Refund | Open P2 / disabled | no automatic/manual money movement | refund command absent | disabled tests |
| OD-09 Revision limits | P0 approved | immutable snapshotted allowance; digital/local behavior | snapshot/revision constraint | E2E 9, 10 |
| OD-10 Submission approval period | Open P1 / disabled | no 72h enforcement/reminder | job absent | job registry denial |
| OD-11 Auto completion | Open P1 / disabled | explicit acceptance only | no auto-complete job/command | E2E 9/10; disabled tests |
| OD-12 Dispute deadline | Open P1 / disabled | do not deny by unapproved seven-day rule | dispute command decision gate | boundary tests |
| OD-13 Verification evidence | P0 approved | contact/profile/portfolio/manual review; no ID | review schema/Storage exclusion | E2E 4; identity scans |
| OD-14 Verification expiry | Open P1 / disabled | no annual expiry job | conditional state, job absent | disabled tests |
| OD-15 Exact address | P0 approved | minimum address after condition; server-only authenticated encryption and rotation | typed encrypted private location | E2E 10; RLS/log/rotation tests |
| OD-16 Messaging | P0 approved | six contexts; Penawaran replacement creates a dedicated successor context/thread; no DM | context/predecessor/participant FKs | direct-object/RLS/chain tests |
| OD-17 Attachments | P0 approved | declaration untrusted; checksum nullable before validation and server-required after; PDF/Office gated on content validator | attachment lifecycle/link/rendition constraints | Storage boundary suite |
| OD-18 Content moderation | P0 approved | manual pre-publication and material edit | Jasa moderation cases | E2E 5 |
| OD-19 Suspension | P0 approved | graduated/proportional; active orders individual | restrictions + linked commands | E2E 12 |
| OD-20 Support model | Open P1 / disabled claim | no 24-hour claim | copy policy only | prohibited-copy scan |
| OD-21 Taxonomy | P0 approved | eight top-level + tags | category/tag seeds | seed and E2E 1 |
| OD-22 Admin reauth/MFA | Open P1 / not approved | JWT age/refresh is insufficient; high-risk actions unavailable until verified reauthentication | no high-risk grant/ban/export/financial/environment command | unavailable-action tests |
| OD-23 Review edit/response | P0 approved | one review, one edit in seven days, withdrawal, no response | review/version constraints | E2E 14 |
| OD-24 Notification channels | Open P1 / external disabled | in-app only | notifications/outbox; email job absent | query/event/disabled tests |
| OD-25 Numeric success thresholds | Open P3 | baseline measurement only, no public claims | safe analytics events | metric/copy tests |
| OD-26 Request/offer expiry | P0 approved | request 14 days; offer no later than request | expiry fields/jobs | E2E 6; job tests |
| OD-27 Local proof | P0 approved | note + appropriate file/document or customer confirmation; no GPS | proof tables/Storage | E2E 10 |
| OD-28 Deactivation/retention | P0 behavior; duration P2 | reversible deactivation; manual deletion; no fixed promise | account state; retention classes | deactivation/deletion-integrity tests |
| OD-29 Existing-Jasa confirmation | P0 approved | Supabase Cron; self-transition inserts N+1 snapshot and supersedes N without payload overwrite; reminder has no transition | versioned snapshots/order deadlines/private Cron | E2E 7, 8; lifecycle/time/matrix suite |
| OD-30 Audit history | P0 scope; duration P2 | append-only sensitive/binding history | audit/events/immutable triggers | mutation-denial/audit coverage |
| OD-31 Admin permissions | P0 approved | no self-grant; ordinary admin-source grants require existing manager; initial bootstrap/recovery is reviewed provisioning-only and idempotent; high-risk grants unavailable | source-dependent assignments, provisioning deny gate, `system_provisioning` audit | bootstrap/admin/RLS matrix |
| OD-32 Settlement/payout | Open P2 / disabled | provider-neutral disabled sentinel only | payout placeholder check | disabled-machine tests |
| OD-33 Verification retention/deletion | P0 no-ID; future P2 | collect/store no ID; no identity bucket | absent identity schema/purpose | schema/Storage/content scans |
| OD-34 Permintaan visibility/eligibility | P0 approved | minimized visitor/noindex; eligible reviewed Mitra responses | public/eligible projections and RLS | E2E 6; enumeration tests |

OD-17 target MIME contract: JPEG/`image/jpeg`, PNG/`image/png`, PDF/`application/pdf`, TXT/`text/plain`, CSV/`text/csv`, DOCX/`application/vnd.openxmlformats-officedocument.wordprocessingml.document`, XLSX/`application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`, and PPTX/`application/vnd.openxmlformats-officedocument.presentationml.presentation`. The independent limits are 10 MB per file and five files per message or submission. PDF/Office remain disabled until the required content validator is implemented and tested.

## 6. Architectural warning traceability

| Warning | Control | Verification |
|---|---|---|
| Role confusion | Base profile + optional Mitra + grants; no role field | schema scan and dual-capability/RLS tests |
| Verification overclaim | Separate contact/review; no identity subsystem; provenance copy | identity/copy scans and E2E 4 |
| Snapshot mutation | one-to-many immutable terms versions; append-only lifecycle fields; no circular one-to-one FK | multi-version/update-delete/lifecycle tests |
| Duplicate acceptance | locks, unique constraints, idempotency | concurrent acceptance test |
| Cross-machine drift | atomic DB functions or durable visible recovery; one correlation | fault injection and event tests |
| Service-role leakage | server-only key, client-bundle secret scan | build/security gate |
| RLS gaps | deny default, explicit projection, actor matrix | per-domain RLS suite |
| File exposure | private originals, approved derivative-only bucket, nullable prevalidation checksum, typed HTTPS links | Storage/rendition attack suite |
| Demo leakage | base-profile marker, descendant propagation, production triggers/filter/scan | demo suite |
| Mock payment accidentally production | build/start assertion + DB environment deny + no adapter | kill-switch suite |
| Scheduler idempotency/timezone | sole Supabase Cron primary, bounded locked batches, `Asia/Jakarta`/snapshotted digital zone, expected version | OD-29 time/concurrency/run-history tests |
| Audit tampering | append-only trigger/grants and safe metadata | direct mutation tests |
| Open-decision creep | decision gates and absent routes/jobs/grants | disabled-feature suite |
| Sensitive logging | structured allowlist and hashing | log capture/privacy tests |
| Outbox fan-out loss | composite per-consumer delivery state; parent completes only after all consumers | independent retry/dead-letter tests |
| Mitra FK ambiguity | every `mitra_profile_id` targets `mitra_profiles(id)`; participant base profile is explicitly mapped | schema/FK/RLS tests |
| Administrator bootstrap gap | pre-existing profile plus exact deployment-controlled provisioning set; no runtime/admin invocation; set expansion rejected | provisioning/idempotency/audit tests |

## 7. Coverage and unresolved dependencies

Covered now:

- every PRODUCT principle and accessibility commitment;
- all DESIGN constraint groups relevant to implementation;
- all forty PRD sections;
- all sixteen state machines and the exact-coverage requirement for 266 allowed pairs;
- all thirty-four open decisions with their current status;
- every database domain, command family, RLS domain, cross-machine event, job, and required test journey.

Remaining technical dependencies are the same as TS section 17. Phase-specific blockers now explicitly include: select/integrate phone verification before onboarding; select/integrate an Office/PDF content validator before enabling those formats; provision/monitor Supabase Cron; define interim evidence retention; select a malware scanner before any scanning claim; and implement verified reauthentication before gated high-risk actions. None is claimed operational and none authorizes an open product decision.
