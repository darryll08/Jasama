# Jasama Commands, Queries, Events, and Jobs

Status: implementation contract for server-side product behavior. Names are logical TypeScript/SQL names, not a promise of a public REST API.

## 1. Transport and envelope

The browser uses Server Actions for same-origin UI commands and Route Handlers only for Auth callbacks, Storage grants, and internal scheduled invocations. Atomic commands call domain-specific PostgreSQL functions. There is no generic client-facing state setter.

Every command input has:

- `idempotencyKey: string` for binding/retryable actions;
- `expectedVersion: bigint` for an existing aggregate;
- `correlationId?: uuid`, accepted only from trusted internal callers and otherwise server-generated;
- command-specific fields with unknown keys rejected.

Every result has `ok`, `code`, `correlationId`, and an allowlisted object/version result. Errors use `AUTH_REQUIRED`, `FORBIDDEN`, `ACCOUNT_RESTRICTED`, `NOT_FOUND`, `VALIDATION_FAILED`, `STALE_VERSION`, `INVALID_TRANSITION`, `CONFLICT`, `IDEMPOTENCY_CONFLICT`, `FILE_REJECTED`, `RATE_LIMITED`, or `INTERNAL_ERROR`.

Unless a row below says otherwise, a command:

1. authenticates the actor and verifies ownership/context/capability/scoped permission;
2. validates input, current state, expected version, and cross-machine prerequisites;
3. locks the aggregate, writes state/data/history/audit/outbox/scheduled rows atomically;
4. stores/replays the idempotency result; a same key/different input fails;
5. emits `{aggregate}.{action}.v1` after commit with safe IDs, versions, correlation/causation, and no private content.

The “Edges” column is the allowed transition set handled by the command family. Its union across a machine must equal that machine's catalog in `STATE_MACHINES.md`; conditional P1/P2 edges are represented in the registry but rejected by a decision gate.

## 2. Commands by state machine

### 2.1 Mitra onboarding and review

| Command | Actor and input | Authorization and validation | Edges and transaction | Audit, outbox, idempotency, errors |
|---|---|---|---|---|
| `startMitraOnboarding` | Account; profile fields/version | active account; owner; no government-ID fields | `inactive→draft`; create optional capability/review atomically | `mitra.onboarding.started.v1`; retry safe; conflict if active draft |
| `submitMitraOnboarding` | Candidate; review id/version, attested profile/portfolio version | contact checks, required profile/portfolio, no ID media | `draft|needs_changes|expired→submitted`; immutable submitted version | submission event/audit; stale version and validation errors |
| `withdrawMitraOnboarding` | Candidate; review/version, reason | owner; not binding-approved action | `submitted|under_review|needs_changes|rejected→withdrawn`, `withdrawn→draft|inactive`, allowed inactive recoveries | safe reason; idempotent terminal replay |
| `reviewMitraOnboarding` | `mitra.review` admin; outcome/reason/safe feedback | scoped permission; no self-review | explicit review outcomes are enumerated pair-by-pair in `TRANSITION_COMMAND_MATRIX.md` | append review event/audit and notification; invalid/conditional edge denied |
| `expireMitraReview` | Internal job; review/version | OD-14 gate | `verified→expired` and documented expiry recoveries | **disabled while OD-14 P1 is open**; scheduled key required |

### 2.2 Jasa listing and moderation

| Command | Actor and input | Authorization and validation | Edges and transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `saveJasaDraft` | Eligible Mitra; typed terms, version-level category/task tags, media refs | owner; category/family/money/timing/revision/tag/media validation | create immutable candidate version with category and tag rows | version audit; stale/conflict/file errors |
| `submitJasa` | Owner; Jasa/version | review eligibility; complete immutable version | `draft|changes_requested→submitted`; `submitted→withdrawn` via withdrawal action | moderation queue event |
| `moderateJasa` | `jasa.moderate` admin; decision/reason/feedback | scoped permission; submitted exact version | `submitted→under_review`; `under_review→changes_requested|published|rejected`; published material edit `published|paused|removed→under_review`; recovery `removed→under_review`, `under_review→published` | audit exact version and reviewer; public-cache event only on publish |
| `setJasaAvailability` | Owner or moderator; intent/reason | owner may pause/archive; moderator may remove; active-order check | `published→paused|archived|removed`; `paused→published|archived|removed`; `changes_requested|rejected|withdrawn→archived`; `archived→draft` | visibility and reason events; existing orders unchanged |

### 2.3 Permintaan

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `savePermintaanDraft` | Pemesan; typed request and version-level category/task tags | owner; category/family/location/budget/timezone/tag validation | create replacement candidate version with immutable category/tag provenance; `draft` maintained | draft is private; no public event |
| `publishPermintaan` | Owner; request/version | complete privacy-minimized version | `draft|closed|expired|removed→published`; set 14-day expiry and expiry job | `permintaan.published.v1`; noindex public projection |
| `closePermintaan` | Owner/admin/job; reason | ownership or moderation/expiry permission | `published→closed|cancelled|expired|removed`; `expired|removed→closed`; terminal checks | close offers where required; audit trigger actor |
| `selectPenawaran` | Owner; request, offer, expected versions | request published; offer submitted/current; same request; one winner | `published→offer_selected`; coordinated acceptance below | atomic reservation; conflict if another winner |
| `convertPermintaan` | Internal acceptance transaction | reserved exact offer/version | `offer_selected→converted`; recovery `offer_selected→published|cancelled` only when no order exists | correlation spans offer/order; never duplicate order |

### 2.4 Penawaran

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `savePenawaranDraft` | Eligible Mitra; request plus typed scope, exclusions, assumptions, price, delivery days, and revision allowance | reviewed Mitra; request published; not owner; no active restriction | create replacement candidate version in `draft`; core terms cannot be replaced by description | private event; eligibility/expiry errors |
| `submitPenawaran` | Author; offer/version | current request published; validity ≤ request expiry | `draft|acceptance_failed→submitted` | notify request owner |
| `replacePenawaran` | Author; old aggregate/version plus new typed version | old is submitted; request still open; actor owns the same `mitra_profile_id` | atomically move old `submitted→replaced`, insert a new Penawaran aggregate with shared `offer_chain_id`, next sequence, `replaces_penawaran_id=old.id`, its own draft/submitted state/version, and a dedicated successor thread | old aggregate/version/thread never rewrite; one active/selectable link; chain audit/correlation |
| `decidePenawaran` | Request owner or author/job; decision | exact contextual actor | `submitted→accepted|rejected|withdrawn|expired`; `draft→withdrawn`; accepted recovery `accepted→converted|acceptance_failed`; `acceptance_failed→withdrawn` | acceptance uses global transaction; other decisions isolated |
| `acceptOfferAndCreateOrder` | Request owner; request/active-chain offer/expected versions | all acceptance invariants; exact new Penawaran and Permintaan version FKs; category/tags/typed terms derived server-side | atomically convert the selected chain link, create Pesanan/work/participants and snapshot version 1 `accepted`, set `terms_version=1`, then close competitors | accepted terms point to the exact replacement version when applicable; one correlation/idempotency key |

### 2.5 Pesanan

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `createJasaOrder` | Pemesan; Jasa/version, scheduling/location refs | Jasa published; `mitra_profile_id` resolves `mitra_profiles(id)`; category/tags and typed terms derive from exact Jasa version | create `pending_confirmation`, snapshot version 1 `pending`, set `terms_version=1`, and create 12h/24h jobs without a circular snapshot FK | order-created event; duplicate source/key returns same order |
| `respondToJasaOrder` | Order Mitra; accept/reject, expected `terms_version` | party; state pending; current snapshot exact | unchanged initial terms: append Mitra acceptance to snapshot version 1 and advance to payment/ready; reject marks it cancelled and closes order; never used for a reminder | stale terms fails and jobs no-op |
| `proposeChangedJasaOrderTerms` / `acceptChangedJasaOrderTerms` | Mitra proposes typed terms; Pemesan accepts exact snapshot version | both are order parties; proposal copies binding source/category/tags and creates N+1 without editing N; Pemesan accepts only the current pending N+1 | proposal atomically supersedes prior pending snapshot, inserts N+1 `pending`, and sets `terms_version=N+1`; acceptance appends accepter/time and performs `pending_confirmation→pending_confirmation`, replacing jobs with expected version N+1 | audit proposal/acceptance separately; stale jobs no-op; reminder emits no transition |
| `finalConfirmJasaOrder` | Order Mitra; Pesanan and expected `terms_version` | current snapshot is `accepted` by Pemesan and exact; order still pending | leave snapshot content/state current and advance Pesanan to `awaiting_payment` or `ready_to_start`; cancellation instead marks current snapshot `cancelled` | no snapshot overwrite; final confirmation and resulting transition share correlation |
| `advanceOrderFromPayment` | Internal payment event | exact amount/currency and paid once | `awaiting_payment→ready_to_start` | same transaction as mock success |
| `startOrderWork` | Mitra; order/version | party, ready, payment condition met | `ready_to_start→in_progress` with Work `ready→in_progress` | atomic cross-machine event |
| `submitOrderWork` | Mitra; delivery/proof version | work active; family-specific valid submission | `in_progress|revision_in_progress→submitted` with Work/submission | atomic immutable version |
| `acceptOrderResult` | Pemesan/admin remedy; accepted version | party; submitted; no open blocking issue | `submitted→completed` with Work done, delivery/proof accepted, Review eligible | payout remains disabled |
| `synchronizeRevisionState` | Internal revision command | valid accepted/fulfilled revision | `submitted→revision_in_progress→submitted` | one revision correlation |
| `synchronizeCancellationState` | Cancellation command/job | valid active source and case | `ready_to_start|in_progress|submitted|revision_in_progress→cancellation_pending`; `cancellation_pending→prior active state|cancelled`; direct approved `ready_to_start→cancelled`; pending confirmation/payment cancellation | cancellation does not decide refund/payout |

### 2.6 Mock payment

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `createMockPaymentAttempt` | Order party/test admin; scenario | non-production, mock enabled, order awaiting payment, amount derived snapshot | create `pending`; retry from `failed|expired→pending` as new attempt | persistent simulation notice; production hard failure |
| `resolveMockPaymentAttempt` | Authorized server/test control; attempt/scenario result | no provider payload; exact environment/order/amount | `pending→paid|failed|expired|cancelled`; `failed|expired→cancelled`; paid triggers order ready | `mock_payment.paid.v1`; once-only; amount mismatch conflict |
| `requestRefund` | Future finance command | OD-08/real-payment approvals | `paid→refund_pending→refunded|partially_refunded|refund_failed` and recoveries | **no route/function/grant in closed beta** |

### 2.7 Work execution

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `prepareWork` | Internal order event | order confirmation/payment complete | `not_ready→ready`; cancellation `not_ready|ready→stopped` | correlated order event |
| `setWorkProgress` | Order Mitra; intent/reason | party; valid order sibling state | `ready→in_progress`; `in_progress→blocked|submitted|stopped`; `blocked→in_progress|stopped`; `revision→blocked|submitted|stopped` | safe blocked reason notification |
| `openWorkRevision` | Internal revision acceptance | accepted in-scope request | `submitted→revision` | atomic with order/revision |
| `finishWork` | Internal accepted result/cancellation | accepted submission or stop reason | `submitted→done|revision|stopped` | review eligibility only on done |

### 2.8 Digital delivery

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `createDigitalDeliveryDraft` | Order Mitra; order/note/items | digital order; work in progress/revision; private files finalized | `none→draft`; failed/retry `failed→draft|processing`; draft cancellation | item type/count/access checks |
| `processDigitalDelivery` | Internal validator/finalizer | exact draft/version and validation result; direct files must be `validated`; external items must be typed HTTPS links | `draft→processing→submitted|failed`; direct `draft→submitted` only when all validation is synchronous | submit atomically updates work/order; no malware-scan claim or server fetch |
| `decideDigitalDelivery` | Pemesan/scoped dispute admin | exact submitted/disputed version | `submitted→accepted|superseded|disputed`; `disputed→accepted|superseded` | accepted may complete order; supersede only with new version |

### 2.9 Local proof

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `createLocalProofDraft` | Order Mitra; note/items | local order; work active; no GPS/EXIF; appropriate evidence or customer confirmation | `none→draft`; `failed→draft`; `draft→cancelled` | file and privacy validation |
| `submitLocalProof` | Mitra/customer confirmation/internal validator | exact draft; note plus allowed proof or confirmation | `draft→submitted|failed`; submit atomically updates work/order | immutable submitted proof |
| `decideLocalProof` | Pemesan/scoped dispute admin | exact submitted/disputed proof | `submitted→accepted|superseded|disputed`; `disputed→accepted|superseded` | same consistency rules as delivery |

### 2.10 Revision

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `requestRevision` | Pemesan; order, submission, scope | submitted order; allowance snapshot not exhausted; no duplicate open request | create `requested` | notify Mitra; sequence unique |
| `respondToRevision` | Mitra or requester; decision/note | party; scope and source state | `requested→accepted|declined|withdrawn|disputed`; `accepted→withdrawn`; `declined→disputed|withdrawn` | accepted synchronizes order/work revision |
| `progressRevision` | Mitra; request/version | accepted and sibling work revision | `accepted→in_progress`; `in_progress→fulfilled|disputed` | fulfill atomically creates new submission/supersedes prior |

### 2.11 Cancellation

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `requestCancellation` | Order party; reason/note | cancellable order state; one active case | create `requested`; `requested→awaiting_response|withdrawn` | order may enter cancellation_pending |
| `respondToCancellation` | Other party; approve/deny/escalate | party; awaiting/requested | `requested|awaiting_response→approved|denied|withdrawn|admin_review` | state-based decision; no financial promise |
| `decideCancellation` | `cancellation.decide` admin | scoped ordinary nonfinancial case; any financial remedy remains unavailable | `admin_review→approved|denied` | reason and safe notice audited |
| `executeCancellation` | Internal command | approved case, expected sibling versions | `approved→executing→executed|failed`; `failed→executing|admin_review`; atomically stop/cancel order/work | exactly once; refund/payout unchanged |

### 2.12 Report

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `submitReport` | Authenticated user; subject/category/description/evidence | rate limit; subject exists/visible; evidence allowed | create `submitted` | submission is not proof of violation |
| `triageReport` | `report.triage` admin; classification/canonical | scope; no self-case; duplicate target valid | `submitted→triaged|closed_duplicate`; `reopened→triaged` | safe reporter update |
| `investigateReport` | `report.investigate` admin; action/request | scoped permission | `triaged→investigating|awaiting_information|dismissed|actioned`; `awaiting_information→investigating|dismissed|closed`; `investigating→awaiting_information|actioned|dismissed` | linked moderation uses separate valid command |
| `closeOrReopenReport` | Scoped admin; reason/new evidence | exact permission and evidence | `actioned|dismissed→closed|reopened`; `closed→reopened`; `reopened→investigating` | append-only decision history |

### 2.13 Dispute

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `submitDispute` | Order party; reason/description/evidence | eligible standing; deadline gate (OD-12 disabled if it would deny); no duplicate active case | create `submitted`; `submitted→withdrawn` | hold auto-completion; payout stays disabled |
| `reviewDisputeEligibility` | `dispute.review` admin | scoped permission | `submitted|reopened→eligibility_review`; `eligibility_review→evidence_collection|dismissed` | decision is not financial outcome |
| `collectDisputeEvidence` | Party/admin; evidence/request | active case; disclosure controls | `evidence_collection→under_review|withdrawn|dismissed`; `under_review→evidence_collection` | evidence immutable/private |
| `decideDispute` | `dispute.decide` admin; versioned nonfinancial remedy | exact evidence/version; restricted-evidence export and financial remedies unavailable until verified reauthentication exists | `under_review→decision_issued`; `decision_issued→implementing|resolved` | remedy snapshot and audit |
| `implementDisputeDecision` | Internal/admin recovery | exact remedy/correlation; each side effect idempotent | `implementing→resolved|implementation_failed`; `implementation_failed→implementing|under_review` | resolve only after all effects |
| `closeOrReopenDispute` | Scoped admin/allowed withdrawer | approved new evidence/error/appeal | exact close/reopen pairs are listed in `TRANSITION_COMMAND_MATRIX.md` | P1 deadline/appeal policy cannot be invented |

### 2.14 Review

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `createReviewEligibility` | Internal completion event | genuine completed order; one reviewer/subject | create `eligible` | no demo review in production |
| `saveReviewDraft` | Eligible reviewer; rating/body | order participant; one review | `eligible→draft` | private |
| `publishReview` | Reviewer; review/version | completed order; rating/body; genuine provenance | `eligible|draft→published` | public aggregate recomputed from real visible reviews |
| `editOrWithdrawReview` | Reviewer; new version or withdraw | one edit within seven days; no provider response | `published→edited|withdrawn`; `edited→edited|withdrawn` | immutable old version; edit marker |
| `moderateReview` | `review.moderate` admin; action/reason | scoped permission | `published|edited→hidden|removed`; `hidden→published|removed`; `removed→published` | no fabricated replacement content |

### 2.15 Account moderation

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `deactivateOrReactivateAccount` | Account owner; intent | ownership; preserve binding obligations | `active→deactivated→active` | manual deletion separate |
| `applyAccountRestriction` | `account.moderate` admin; state/capabilities/reason/review date | scope; no self-action; proportional OD-19; permanent-ban destinations unavailable until verified reauthentication exists | explicit limited/suspended pairs in the matrix; banned pairs are represented but decision-gated unavailable | active orders individually evaluated, never silently cancelled |
| `appealAccountRestriction` | Subject; reason/evidence | eligible restricted state | `limited|suspended|banned→appeal_pending` | safe appeal notice |
| `decideAccountAppeal` | Scoped admin; outcome | no self-case; banned outcome unavailable until verified reauthentication exists | explicit appeal/recovery pairs in the matrix | append restriction decision/audit |

### 2.16 Payout placeholder

| Command | Actor/input | Authorization/validation | Edges/transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `ensurePayoutDisabled` | Internal order/payment setup; order id | environment and OD-32 gate | create/read `disabled`; no outgoing transition | idempotent creation audit only |
| `managePayout` | Future finance actor | OD-32 plus real-payment/security/legal approval | each disabled payout pair is listed explicitly in `TRANSITION_COMMAND_MATRIX.md` | **no closed-beta route, grant, function, provider field, or worker** |

### 2.17 Contextual messaging and attachments

Direct uploads accept exactly JPEG/`image/jpeg`, PNG/`image/png`, PDF/`application/pdf`, TXT/`text/plain`, CSV/`text/csv`, DOCX/`application/vnd.openxmlformats-officedocument.wordprocessingml.document`, XLSX/`application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`, and PPTX/`application/vnd.openxmlformats-officedocument.presentationml.presentation`.

| Command | Actor/input | Authorization/validation | Transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `createContextThread` | Context participant; exactly one of Jasa inquiry, Permintaan, Penawaran, Pesanan, Report, Dispute | explicit intent and contextual eligibility; Penawaran always dedicated; no direct-message type | create thread and initial participants from the sole context FK | `thread.created.v1`; duplicate context/key replays |
| `createSuccessorThread` | Internal context-conversion command | source thread/context valid; destination context created; participant set derived anew | create destination-owned thread, set predecessor, create authorized participants, revoke obsolete access without moving history | one conversion correlation; no cross-context silent reuse |
| `revokeThreadParticipant` | Context transition or scoped case admin | explicit revocation reason; cannot retain unauthorized read through old signed URLs | set revocation actor/time/reason and invalidate future file grants | safe access audit; idempotent |
| `sendMessage` | Active participant; thread/body/client message id, up to five validated attachment IDs | sole context still authorizes actor; body bounds; attachments owned/contextual and `validated` | append message and zero-to-five links | unique sender/client id; `FILE_REJECTED` or `FORBIDDEN` |
| `requestUploadGrant` | Context actor; purpose, filename, declared MIME/extension/byte size | declaration fits target allowlist, ≤10 MB, count ≤5, no identity purpose; PDF/Office denied until content validator is operational | create `pending_upload` with `sha256=NULL` and short-lived path-bound grant | declaration is untrusted; count independent of type count |
| `finalizeUpload` | Upload owner/server; object reference only | server derives actual byte size, MIME, signature, extension, and SHA-256; validates object, allowlist, count, and declaration match | `pending_upload→uploaded→validating→validated`, or `quarantined|rejected`; `validated` requires all derived metadata/SHA | validation audit; browser checksum is neither accepted nor authoritative |
| `addDeliveryExternalLink` | Order Mitra; delivery version, HTTPS URL, label, access note, optional expiration | digital delivery draft/revision; URL absolute HTTPS/no credentials; creator is party | append typed link to immutable version item set | never fetch URL; third-party availability not guaranteed |
| `createApprovedMediaRendition` | Server derivative worker after moderation | source attachment validated/private; exact approved Jasa version or Mitra review; allowed public rendition kind | generate derivative, strip disallowed metadata, write only output to `approved-public-media`, insert immutable rendition | audit source/approval/version; original remains private |
| `revokeOrReplaceMediaRendition` | Scoped Jasa/Mitra moderator | current active rendition and exact approval context | replacement inserts new object/row then revokes/links old; revocation purges/denies cache | public fallback never exposes source |

### 2.18 Administrator permissions and bootstrap

| Operation | Actor/input | Authorization/validation | Transaction | Audit/outbox/errors |
|---|---|---|---|---|
| `grantAdminPermission` | Existing permission manager; recipient, ordinary permission/scope, reason | `grant_source=admin`; grantor required and differs from recipient; grantor already holds permission-management capability; high-risk grant denied | insert one ordinary assignment; no provisioning reference | every success/denial audited; self-grant and insufficient manager return `FORBIDDEN` |
| `revokeAdminPermission` | Existing permission manager; assignment/reason | same scope/management checks; no self-directed privilege manipulation | append revocation lifecycle fact | audited and idempotent |
| Initial bootstrap / controlled recovery | Reviewed migration or provisioning owner; existing target profile, exact permission/scope set, change reference | **not an application command or RPC**; no runtime/user/admin/public execute grant; target Auth user and active non-demo profile already exist | insert `grant_source=provisioning`, null grantor, required change reference; exact replay no-ops; different target/set under same reference rejects atomically | append `system_provisioning` audit for success, replay, and denial; no public outbox payload |

Provisioning is deliberately absent from Server Actions, Route Handlers, public/database RPC grants, and administrator UI. It cannot be invoked by an ordinary administrator even if that administrator manages ordinary permissions.

## 3. Query contract

Queries never return base-table wildcards. All list queries are cursor-paginated with bounded page size.

| Query | Caller and authorization | Safe result |
|---|---|---|
| `getHomepageDiscovery` | Anonymous/authenticated | approved eight categories, genuine published Jasa/Mitra projections, no fabricated popularity |
| `searchJasa` | Anonymous/authenticated | published, moderated, production-non-demo cards; query/filter summary; coarse locality |
| `getPublicJasa` / `getPublicMitra` | Public | approved versioned category/tags and active `media_renditions`; fallback placeholder/no image; genuine reviews and correct review provenance |
| `getPublicPermintaan` | Visitor | privacy-minimized published fields only; no owner/contact/exact address; noindex metadata |
| `listEligiblePermintaan` | Authenticated reviewed Mitra | response projection only for category/area/capability eligibility |
| `getMyProfileCapabilities` | Authenticated owner | base profile, contact facts, Mitra review safe status, restrictions, own grants |
| `listMyJasa` / `getJasaEditor` | Mitra owner | own drafts/versions/safe moderation feedback |
| `listMyPermintaan` / `getPermintaanWorkspace` | Pemesan owner | own versions and received offers; no other request's data |
| `getPenawaranEditor` | Offer author | own offer versions and request response context |
| `getPesanan` / `listMyPesanan` | Party or scoped admin | all immutable snapshot versions plus current `terms_version`, exact category/tags/sources, state/history; private location only after release |
| `getThread` | Active thread participant/scoped case admin | messages and authorized attachments; cursor pagination |
| `getDeliveryOrProof` | Order party/scoped dispute admin | immutable versions and authorized signed-download intents |
| `getRevision` / `getCancellation` | Order party/scoped admin | safe case state, reason, and allowed actions |
| `getReport` | Reporter/scoped safety admin | reporter-safe status or full scoped case; evidence by separate grant |
| `getDispute` | Order party/scoped dispute admin | party-safe case/remedy summary or scoped full case |
| `listReviews` / `getReviewEditor` | Public or eligible reviewer | published genuine reviews, or own draft/edit deadline |
| `listNotifications` | Recipient | own in-app notifications |
| `listAdminQueue` | Exact permission | minimum fields for that queue/scope; no cross-queue access |
| `getAuditTrail` | Exact audit permission | filtered, paginated safe audit events; no private payload bodies |

Query caches are invalidated by domain outbox events. Authorization is re-evaluated on every request; cached private results are never shared across users.

## 4. Cross-machine events

| Event | Atomic or durable outcome | Consumer behavior |
|---|---|---|
| `offer.accepted_order.created.v1` | Permintaan, winning Penawaran, Pesanan, snapshot, participants, work, and competitor closure share one transaction/correlation | Notifications/search invalidation retry from outbox; never recreate order |
| `competing_offers.closed.v1` | Every other submitted offer closes under the acceptance transaction and correlation | Never targets the winner; retry observes terminal competitors and emits no duplicate notices |
| `payment.mock_paid.v1` | Mock attempt paid and eligible order ready atomically; payout remains disabled | Notify parties; amount mismatch creates reconciliation alert |
| `work.started.v1` | Pesanan and Work enter progress together | Notify customer after commit |
| `delivery.digital_submitted.v1` | Immutable delivery, Work submitted, Pesanan submitted | Notify customer; upload validation failure emits no success |
| `proof.local_submitted.v1` | Immutable proof, Work submitted, Pesanan submitted | Same |
| `revision.opened.v1` | Revision accepted, Pesanan revision, Work revision | Prior submission remains immutable |
| `revision.fulfilled.v1` | New version, prior superseded, revision fulfilled, Work/Pesanan submitted | Duplicate key returns same version |
| `order.completed.v1` | Pesanan/Work completed, submission accepted, review eligibility created | Payout remains disabled |
| `cancellation.executed.v1` | Case executed, order cancelled, work stopped | No refund/payout decision |
| `refund.decided.v1` | Future separately approved financial event | Disabled closed beta |
| `dispute.opened.v1` | Case/evidence references and completion hold | Payout remains disabled |
| `dispute.resolved.v1` | Versioned remedy effects all complete | Failed effects remain `implementation_failed` |
| `account.restricted.v1` | Restriction plus separately valid Jasa/Mitra actions | Each active order gets explicit handling result |

Each event stores schema version, aggregate versions, correlation ID, causation ID, idempotency key reference, actor/trigger kind, and safe object references. Fan-out creates one `outbox_event_deliveries` row per required versioned consumer under composite key `(event_id, consumer_name)`. Consumers independently claim due rows, retry with their own attempt/availability state, and never infer authorization from an event alone.

A delivery becomes `dead_letter` after its bounded retry budget and raises an alert. The parent event receives `fanout_completed_at` after all required delivery rows exist and `fully_processed_at` only after every required delivery is `processed`. Any dead letter leaves the parent not fully processed and records terminal failure until reviewed replay succeeds. One consumer's success never suppresses another consumer's retry.

## 5. Scheduled jobs

Supabase Cron is the sole primary minute-level dispatcher. Once per minute it calls a private database function that claims at most a small configured batch of due `scheduled_commands` with `FOR UPDATE SKIP LOCKED`. Each row carries deterministic idempotency, expected aggregate/terms version, retry budget, and correlation ID. The function records run history and returns safe counts for monitoring. Backlog age and terminal failures alert. Vercel does not run a competing schedule; a manually authenticated server-only recovery invocation may call the same private function.

| Job | Schedule/due basis | Preconditions and stale behavior | Idempotency, outcome, and alert |
|---|---|---|---|
| `remindJasaOrderConfirmation` | exact stored `requested_at + 12h`, displayed in saved IANA zone | order still `pending_confirmation`; expected terms/version matches | deterministic `order:{id}:terms:{v}:confirm-reminder`; one in-app notification; stale is successful no-op |
| `timeoutJasaOrderConfirmation` | exact stored `requested_at + 24h` | same checks; lock order | deterministic timeout key; cancel exactly once; alert after retry budget |
| `expirePermintaan` | `published_at + 14 days` | request still published and version matches | expire request/eligible offers once; stale no-op |
| `expirePenawaran` | offer `valid_until` or request expiry, whichever first | submitted and current | expire once; accepted/converted no-op |
| `dispatchOutbox` | continuous/every minute | event due and unprocessed | `FOR UPDATE SKIP LOCKED`; exponential bounded retry; dead-letter alert |
| `reconcileCrossMachine` | periodic | finds only explicitly defined invariant mismatches | never invents a transition; opens admin reconciliation/audit |
| `scanProductionDemoRows` | deployment and periodic | production environment | any row is release/runtime alert; no silent deletion |
| `reviewEvidenceRetention` | periodic operational report | policy class/legal hold | reports candidates only until exact P2 retention approved |
| `submissionReminder` / `autoCompleteOrder` | future OD-10/11 | decision gates and no open issue | **not scheduled in closed beta** |
| `expireMitraVerification` | future OD-14 | decision gate | **not scheduled in closed beta** |
| `sendCriticalEmail` | future OD-24 | approved channel/consent/template | **not scheduled in closed beta** |

The Cron function and recovery invocation reject browser/user calls. A job records `claimed`, `succeeded`, `no_op`, or `failed`, attempt count, safe error code, and timestamps. Jobs call the same domain commands and therefore cannot bypass RLS-equivalent authorization, transition, environment, or decision gates. Surabaya local orders use `Asia/Jakarta`; digital orders default to the Pemesan profile timezone unless the parties explicitly agree another valid IANA zone. The Pesanan snapshots the zone and all deadlines remain UTC `timestamptz`.

## 6. Exact transition coverage

`TRANSITION_COMMAND_MATRIX.md` is the explicit registry. A contract test asserts:

- the matrix contains exactly 266 unique documented `(machine, from, to)` rows;
- no additional pair is accepted;
- every P1/P2-conditional pair returns `DECISION_NOT_APPROVED` in closed beta;
- every cross-machine event uses one correlation ID and either an atomic commit or a visible retry state;
- every command has actor, input schema, authorization, transaction, audit, outbox decision, idempotency policy, and stable error mapping.

The registries are internal enforcement data, not a generic transition endpoint.
