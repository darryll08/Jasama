# Jasama Closed-Beta Test Strategy

Status: release-quality verification contract for the approved P0 scope.

## 1. Quality goals

Testing must prove:

- user-visible behavior matches `PRODUCT.md`, `DESIGN.md`, `HOMEPAGE_SHAPE.md`, and `PRD.md`;
- the database accepts exactly the documented state transitions and preserves cross-machine invariants;
- authorization cannot be bypassed by role/capability confusion, direct API use, stale clients, or Storage URLs;
- commercial snapshots, audit, outbox, and version history are immutable and correlated;
- OD-29 jobs are timezone-correct, idempotent, and stale-version safe;
- mock payment and demo data cannot enter production behavior;
- no government-ID data path or real-money path exists;
- mobile, keyboard, assistive technology, Indonesian copy, recovery states, and performance meet the approved contract.

## 2. Test layers and ownership

| Layer | Scope | Primary tools | Runs |
|---|---|---|---|
| Static/contract | TypeScript strict, generated DB types, boundary schemas, dependency/client-bundle checks, forbidden copy/schema terms | `tsc`, ESLint, repository scripts | every change |
| Unit | Pure validation, money/time formatting, decision gates, permission composition, error mapping, transition predicates | Vitest | every change |
| Database | migrations, constraints, functions, all 266 pairs, transaction rollback, concurrency, RLS, immutable triggers | Supabase local PostgreSQL + pgTAP/SQL harness | every change |
| Component | forms, combobox/filter, status/error/loading/unavailable, focus, keyboard, reduced motion | Testing Library | every change |
| Integration | Server Action/Route Handler to local Supabase, Storage grants, outbox/jobs, generated types | Vitest/HTTP harness + Supabase local | every change |
| E2E | multi-user browser journeys and admin queues | Playwright | pull request and release |
| Accessibility | automated rules plus manual keyboard/screen reader/zoom/reflow | axe + Playwright + manual checklist | PR automation; manual release |
| Performance/resilience | public rendering, browse query indexes, job backlog, retry/failure, upload boundaries | browser metrics, SQL `EXPLAIN`, fault injection | release and material query change |
| Security/privacy | authorization matrix, direct-object attacks, secret/client bundle, Storage, abuse, production kill switches | RLS tests, Playwright/API requests, CI scripts | every release |

## 3. Test data and environments

- Unit/database tests create isolated records with deterministic factories and clocks.
- Development/staging synthetic domain records always set `is_demo=true`.
- Staging displays the persistent demo banner. Per-object demo labels appear only in intentional mixed-data suites.
- Production test probes create no demo records and assert the database rejects them.
- Genuine-flow tests use ephemeral non-demo fixtures only in isolated test databases, never public production.
- Test names/data must not contain government-ID numbers/images or realistic identity documents.
- Mock payment uses fixed scenarios (`success`, `failure`, `expiry`, `cancel`) outside production only.
- No suite fabricates testimonial, partner, ranking, usage count, response speed, or performance proof.

Use a controllable database clock interface for deadline calculations while retaining `timestamptz` storage. At least one integration suite uses the real PostgreSQL clock to catch abstraction drift.

## 4. State-machine and transition coverage

A required contract suite materializes the exact sixteen catalogs and all 266 allowed `(machine, from, to)` pairs from `STATE_MACHINES.md`.

For every pair it proves:

1. a mapped domain command can represent it;
2. authorized actor + valid preconditions succeeds if its decision gate is approved;
3. conditional P1/P2 transition returns `DECISION_NOT_APPROVED` in closed beta;
4. wrong actor, wrong object, stale version, missing sibling precondition, and invalid source state fail without writes;
5. state, append-only history, audit, outbox, and scheduled records agree after commit;
6. idempotent replay returns the same result and creates no duplicate history/event.

For every state, generate negative tests for all destinations absent from its catalog. The database—not only TypeScript—must reject them. Machine-specific state columns are tested for invalid text/domain values.

Coverage report groups the 266 pairs by machine and fails if the documented catalog, command registry, SQL allowlist, or tests differ.

The executable fixture is generated from `TRANSITION_COMMAND_MATRIX.md`. It must contain exactly 266 unique rows and zero extras. The `pending_confirmation→pending_confirmation` row must map to accepted changed terms, a new immutable pending version, replacement OD-29 jobs with the new expected version, and separate proposal/acceptance audit. A reminder must not appear as a transition.

## 5. Database and concurrency tests

Required SQL/integration cases:

- two concurrent acceptances on one Permintaan produce exactly one winner/order/snapshot; the loser gets conflict;
- retry during acceptance cannot duplicate order, participants, competitor closure, audit, or outbox;
- concurrent existing-Jasa confirmation and terms edit produces either a valid exact-version confirmation or `STALE_VERSION`;
- mock-payment success races with cancellation and results in one valid machine combination, never work-start-before-payment;
- two work-start requests produce one paired Pesanan/Work transition;
- delivery/proof finalization races with cancellation/revision without orphaning an immutable version;
- revision sequence cannot exceed snapshotted allowance;
- two review publications create one order/reviewer review; the single edit deadline is enforced;
- duplicate dispute/cancellation active cases are constrained;
- outbox/job workers using `SKIP LOCKED` do not process a row twice;
- transaction fault after each write boundary rolls back the entire initiating transition;
- snapshot/version/audit rows reject update/delete;
- integer rupiah constraints reject fractional, negative, overflow/out-of-range input and non-IDR currency;
- production triggers reject all demo and mock-payment writes even through privileged application functions.

Use `EXPLAIN (ANALYZE, BUFFERS)` on representative browse, owner dashboard, admin queue, due-job, thread, and audit queries with realistic closed-beta cardinality. Require index use or a documented reason for a bounded sequential scan.

## 6. RLS and authorization tests

For every row of the RLS matrix, test anonymous, unrelated authenticated account, owner, contextual counterpart, reviewed/unreviewed Mitra, limited/suspended/banned account, wrong-scope admin, correct-scope admin, self-targeting admin, and server job.

Minimum attacks:

- substitute another profile/object UUID in every query and mutation;
- call database functions and Route Handlers directly without the UI;
- use an old signed URL after expiry, removal from a thread, cancellation, and restriction;
- reuse an upload grant for another bucket/parent/file;
- attempt unsolicited messaging or cross-thread attachment reuse;
- read exact address before confirmation/mock-payment release;
- enumerate public Permintaan owner/contact/offer fields;
- access report/dispute evidence as the other party without disclosure authorization;
- grant oneself administrator authority or act outside assignment scope;
- use the non-admin half of a dual-capability account to bypass suspension;
- mutate state/audit/version tables directly;
- submit client-controlled actor, admin, demo, state, price, or review fields.

All denials must leave no domain/audit/outbox side effect except a rate-limited safe security signal where designed.

## 7. Mock payment, demo, and disabled-feature tests

### Mock payment

- local/preview/staging with both environment switches can create fixed simulation attempts;
- production database rejects attempts and deployment assertion rejects `PAYMENT_MODE=mock`;
- there is no provider callback route, credential name, bank/card field, refund command, or payout transition;
- amount/currency come from immutable order terms, not browser input;
- UI, receipt/history, and notifications say simulation and make no protection/refund claim.

### Demo data

- production triggers reject `is_demo=true` on every bearing table;
- public/participant production queries filter demo rows even if a trigger is intentionally bypassed in a test transaction;
- production rejects a demo base profile and every descendant of a demo account;
- deployment scan fails on an injected demo row;
- staging banner is persistent across public/authenticated routes;
- mixed-data fixtures label each demo object; demo-only staging does not require noisy per-object labels;
- public claims never derive from synthetic data.

### Disabled decisions

Feature/command tests assert closed-beta denial for real payment/refund/payout, auto-completion, submission timer policy, dispute deadline, verification expiry, production identity verification, exact-retention deletion automation, email/WhatsApp notification, service fees, and any other P1/P2 item. Absence is tested at UI, server command, SQL grant/function, and job registration layers.

## 8. OD-29 time and job tests

Use `Asia/Jakarta` and at least two other IANA zones, including one with daylight-saving transitions, even though the pilot zone has no DST.

- deadline instants equal requested instant + 12/24 elapsed hours;
- Surabaya uses `Asia/Jakarta`; digital orders default to the Pemesan timezone or snapshot an explicitly agreed IANA timezone;
- display shows the saved IANA zone and correct Indonesian date/time;
- dispatcher just before due does nothing; first run at/after due acts;
- repeated/concurrent reminder produces one notification;
- repeated/concurrent timeout produces one cancellation;
- accepted/rejected/cancelled order makes both jobs successful no-ops;
- terms-version change makes stale jobs no-op;
- job delay changes execution time, not the original deadline or audit meaning;
- transient failure retries with the same idempotency/correlation identity;
- exhausted retry budget alerts with no contradictory success state;
- clock skew beyond the operational tolerance alerts.

## 9. Storage and upload tests

- each bucket/purpose accepts only its authorized actor/context/state;
- actual file signature, MIME, extension, byte size, item count, and checksum are verified;
- target allowlist contract covers JPEG/`image/jpeg`, PNG/`image/png`, PDF/`application/pdf`, TXT/`text/plain`, CSV/`text/csv`, DOCX/`application/vnd.openxmlformats-officedocument.wordprocessingml.document`, XLSX/`application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`, and PPTX/`application/vnd.openxmlformats-officedocument.presentationml.presentation`; PDF/Office positive tests and enablement wait for the content-validator blocker;
- 10 MB per-file and five-files-per-message-or-submission boundaries pass; a sixth file or one byte over fails, while the eight allowed types remain independently recognized;
- SVG, HTML, executable, archive, macro-enabled office file, password-protected file, polyglot/mismatched file, and path traversal fail;
- EXIF/GPS is stripped from local proof; no GPS column/event remains;
- government-ID filename/content classification triggers safe restriction/removal flow and no extraction/storage;
- lifecycle is exactly `pending_upload|uploaded|validating|validated|quarantined|rejected`; object is unreadable before validation and after authorization ends;
- no UI, event, test name, or policy claims malware scanning; scanner behavior remains disabled;
- signed URLs are short-lived and object-specific;
- source Jasa media is private; only approved rendition becomes public;
- large audio/video uses a typed HTTPS delivery link with label, access note, creator, immutable version, and optional expiration; the server never fetches it and UI disclaims third-party availability;
- deletion/legal hold preserves relational integrity and audit without logging private names/paths.

## 9A. Schema-hardening contract tests

- Jasa and Permintaan task tags attach to immutable version IDs; changing current content cannot rewrite historical or accepted tags.
- Jasa and Permintaan versions retain category IDs; order snapshots copy exact source category and task tags so later discovery reclassification cannot rewrite history.
- One Pesanan accepts multiple immutable snapshot rows under `UNIQUE(pesanan_id, version_no)`; only one is pending/accepted. Initial creation, changed proposal, Pemesan acceptance, final Mitra confirmation, and cancellation assert the exact `terms_version` and lifecycle fields without payload overwrite or a circular FK.
- Jasa, Penawaran, and order snapshots preserve typed scope, exclusions, price, timing, revision allowance, fulfillment mode, and locality/online basis; assumptions are preserved where applicable.
- Existing-Jasa snapshots have only a real `source_jasa_version_id`; accepted-Penawaran snapshots have real Permintaan and Penawaran version FKs and no Jasa version.
- Penawaran replacement leaves the old aggregate terminal `replaced`, creates a new linked aggregate with the same chain/next sequence and dedicated successor thread, and permits only one active/selectable link. Acceptance points to the new exact version.
- All six OD-16 contexts create exactly-one-context threads. Penawaran never silently reuses a Permintaan thread; conversion creates a linked successor with explicit participant creation and revocation.
- Pending/uploaded attachments allow `sha256=NULL`; validated attachments require server-derived actual MIME, signature, extension, byte size, and SHA-256. Browser-declared size/MIME/checksum cannot become final metadata.
- Two consumers of one outbox event have independent delivery rows/retries; parent completion waits for both, and one dead letter keeps it incomplete and alerts.
- Public Jasa/portfolio/avatar media resolves only active approved renditions in `approved-public-media`; originals/evidence never enter it. Replacement, revocation, cache purge, and fallback are exercised.
- `pesanan.mitra_profile_id` and snapshot Mitra references target `mitra_profiles(id)`; participant base-profile mapping matches that capability owner.
- Exact-address ciphertext, IV, auth tag, and key version round-trip only server-side; logs contain none of them or plaintext; key rotation preserves the address.
- `app_environment` has no ordinary administrator write policy, UI, or runtime command; production flags cannot change.
- Supabase Cron is the only primary dispatcher, claims bounded rows with `SKIP LOCKED`, records run history, and alerts on backlog/terminal failure; manual fallback calls the same function.
- Without verified reauthentication, permanent bans, high-risk grants, restricted-evidence export, financial remedies, and production-environment changes remain unavailable; JWT issue/refresh time cannot satisfy the gate.
- An administrator cannot self-grant; the grantor must already hold permission-management capability; successes and denials audit; high-risk grants remain disabled.
- Initial provisioning succeeds only for a pre-existing active non-demo profile and the exact reviewed permission/scope set.
- Repeating the same provisioning change reference, target, and set is idempotent and creates no duplicate effective grants.
- Ordinary users, the runtime application role, and ordinary/scoped administrators cannot invoke the provisioning path.
- Self-grant and an admin-source grantor without permission-management capability are rejected.
- Reusing a provisioning change reference to expand, reduce, or retarget the bootstrap set is rejected atomically.
- Every provisioning success, replay result, and denial has an append-only `system_provisioning` audit event.
- Onboarding phone-verification tests remain blocked until a mechanism/provider is selected and integrated. PDF/Office enablement tests remain blocked until the content validator detects unsupported, macro-enabled, encrypted, and password-protected files. Neither capability may be claimed before its tests pass.

## 10. Accessibility and responsive testing

Automated checks run on homepage, browse/results, Jasa/Mitra/Permintaan detail, auth, dashboards, editors, order/message/delivery/revision/cancellation, review, report/dispute, notifications, and admin queues.

Manual release checks cover:

- complete keyboard operation and logical focus order;
- visible solid 3px outline with 2px offset using the light/inverse token;
- focus return after sheet/dialog and restoration after detail navigation;
- screen-reader labels, landmarks, headings, status/live announcements, and error summary;
- native control semantics and ARIA combobox behavior;
- 44×44 CSS pixel targets;
- 320px reflow and 200% zoom without clipped dynamic Indonesian text;
- light/dark-green focus contrast and all WCAG 2.2 AA text/component contrast;
- reduced motion with no hidden content or shimmer;
- long labels, empty/error/unavailable states, and preserved draft/query/filter values.

## 11. Required end-to-end journeys

At least these fourteen Playwright journeys are release-blocking:

1. **Public Pemesan-first discovery:** homepage eight categories, `Jelajahi Jasa` primary, `Buat Permintaan` companion, search/filter/back-state restoration, no fabricated trust claim.
2. **Browse-to-request fallback:** no results, clear filters, create Permintaan with meaningful query/filter prefill, review/edit before publish.
3. **Dual-capability account:** one account uses Pemesan features, starts/submits Mitra onboarding, receives `Profil Mitra diperiksa`, and retains both capabilities without a role switch field.
4. **Mitra review denial path:** unreviewed candidate cannot publish/offer; admin requests changes; candidate resubmits; no identity document/copy path appears.
5. **Jasa moderation and immutable terms:** create, submit, manual approve, publish; material edit re-enters review; an earlier order keeps its original snapshot.
6. **Custom Permintaan to Pesanan:** publish privacy-minimized/noindex request, eligible Mitra submits/replaces offer, Pemesan accepts, competitors close, one order/snapshot results.
7. **Existing-Jasa OD-29 acceptance:** create order, 12-hour reminder, Mitra accepts exact terms, mock payment succeeds, work becomes ready; reruns do not duplicate.
8. **Existing-Jasa timeout/stale terms:** terms change or no response; stale reminder/timeout no-op as appropriate; exact 24-hour timeout cancels once with clear history.
9. **Digital work and revision:** start paid-ready work, upload/finalize immutable digital delivery, request one in-scope revision, submit superseding version, accept, complete, create review eligibility.
10. **Local work and proof:** start local order, reveal minimum address only after conditions, submit note plus allowed proof/customer confirmation with no GPS, accept and complete.
11. **Cancellation:** request/respond/admin-review where required, execute exactly once, stop work/cancel order, and show state-based outcome without refund/payout promise.
12. **Report and account restriction:** report is triaged/investigated, proportionate restriction blocks new activity, active orders receive explicit individual handling, appeal restores/changes access as decided.
13. **Dispute and recovery:** open dispute on immutable submission, collect private evidence, issue versioned remedy, inject side-effect failure, retry to resolution without duplicate effect.
14. **Review provenance and moderation:** completed-order review publishes once, edits once within seven days with marker, withdrawal/moderation works, no provider response or demo-derived aggregate appears.

Each journey runs at mobile and representative desktop widths where the UI differs. Journeys 1, 2, 7, 9, 10, and 11 include keyboard-only assertions; journeys 1, 6, 9, 12, and 13 include automated accessibility scans.

## 12. Indonesian content and trust tests

Snapshot/semantic assertions cover the approved terms: `Pemesan`, `Mitra`, `Jasa`, `Permintaan`, `Penawaran`, `Pesanan`, `Profil Mitra diperiksa`, `Jelajahi Jasa`, and `Buat Permintaan`.

CI searches rendered copy/content fixtures for prohibited unsupported claims including `Identitas terverifikasi`, payment protection, guaranteed refund, guarantee, 24-hour support, all-Mitra verification, fabricated “best/popular” ranking, partner, usage count, response speed, and performance proof. A lexical match is reviewed for legitimate policy explanation rather than blindly replaced.

## 13. Performance and resilience criteria

- Public/home/discovery HTML is server-rendered and useful before client hydration.
- No unbounded list/query or N+1 retrieval exists on covered routes.
- Initial media has dimensions and responsive sources; below-fold media is lazy.
- Client bundle review catches accidental service-role/secrets and unnecessary client components/dependencies.
- Core actions preserve entered data on validation/network failure and produce one recoverable next step.
- Outbox/job backlog age and failure rate have alerts; restore drills prove migrations/backups can recover binding data.
- Offline or transient database/Storage failure never presents a binding success before commit.

Numeric public performance/business claims remain prohibited. Engineering budgets are internal release controls and should be baselined against the implemented pages before setting hard numbers.

## 14. CI and release gates

Pull-request pipeline:

1. format/lint/typecheck and forbidden-boundary scans;
2. start clean local Supabase and apply every migration;
3. schema/type drift and generated-type check;
4. unit, pgTAP/database, RLS, integration, component, and accessibility suites;
5. build production bundle and scan environment/client artifacts;
6. run critical Playwright subset.

Release pipeline adds all fourteen journeys, production demo/mock kill-switch probes, migration forward-fix review, representative query plans, manual accessibility checklist, job/alert smoke tests, backup/restore evidence, and administrator permission review.

No flaky test is silently retried to green. A retry may gather diagnostics, but the original failure remains visible and release-blocking until classified.
