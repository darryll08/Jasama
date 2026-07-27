# Jasama MVP Product Requirements Document

Status: **Closed-beta P0 product decisions approved; remaining P1/P2/P3 decisions open**  
Scope: responsive Indonesian web marketplace MVP  
Product authority: `PRODUCT.md`  
Visual and interaction authority: `DESIGN.md`  
Homepage and discovery authority: `docs/HOMEPAGE_SHAPE.md`  
Behavioral lifecycle authority: `docs/STATE_MACHINES.md`  
Unresolved choices: `docs/OPEN_DECISIONS.md`

This document translates the product direction and recorded approvals into testable MVP requirements. **Approved for closed beta** behavior is binding within its recorded limits. A line marked **Recommended default — approval required** remains unavailable until `docs/OPEN_DECISIONS.md` records approval.

## 1. Product Summary

Jasama is a responsive Indonesian marketplace that connects **Pemesan** who need practical local or digital work with **Mitra** who can provide it. A Pemesan can browse an existing **Jasa** or publish a custom **Permintaan**. A Mitra can publish Jasa and send a custom **Penawaran** in response to a Permintaan. Once both sides agree, the work proceeds through a recorded **Pesanan** with messages, status history, proof or delivery, reporting, and reviews limited to completed Pesanan.

Trust is operational rather than promotional: the truthful Mitra onboarding-review state, moderated listings, agreed scope, recorded state changes, completed-order review provenance, reports, and basic administrator-managed disputes are visible only when the corresponding mechanisms are operational. Closed beta does not claim government-ID verification.

## 2. Problem Statement

Indonesian users often need small local errands or digital assistance that is too specific for a store catalog and too small or informal for a conventional freelance project. Existing discovery happens across fragmented chats, social feeds, and personal referrals, making it difficult to compare scope, price, provider identity, prior work, and accountability.

Mitra also need a practical way to present services, respond to custom needs, preserve agreements, show work, and build a reputation without complex bidding or enterprise tooling. Jasama must reduce this coordination friction without publishing unsupported safety, payment, or performance guarantees.

## 3. Goals

1. Let a Pemesan quickly discover relevant local and digital Jasa.
2. Preserve unmatched search intent by converting it into a prefilled Permintaan.
3. Let Pemesan evaluate Mitra through truthful profiles, portfolios, service areas, verification states, and completed-order reviews.
4. Let Mitra publish moderated Jasa and respond to Permintaan with a clear Penawaran.
5. Record the agreed scope, price, participants, status, messages, delivery or proof, and important changes in a Pesanan.
6. Support accessible mobile-first use and natural Indonesian copy.
7. Give administrators sufficient tools for manual verification, listing moderation, reports, account moderation, and basic disputes.
8. Produce trustworthy product-learning signals without fabricating customer evidence.

## 4. Non-Goals

- Native mobile applications.
- Internal wallet.
- GPS tracking or public live location.
- Internal video calls.
- AI product features.
- Complex open bidding or auction mechanics.
- Paid marketing integrations.
- Production Midtrans integration in the first development phase.
- A promise of escrow, refunds, secure payment, guaranteed outcomes, universal verification, or 24-hour support before those systems and policies exist.
- Active exam assistance, impersonation, plagiarism, fabricated documents, fraud, manipulated research data, or submission of another person's work as the customer's own.

## 5. Target Users

| User | Primary need | Relevant context |
|---|---|---|
| Pemesan | Find trustworthy help or describe a custom need with minimal friction. | Students, young adults, families, professionals, freelancers, and small businesses. |
| Mitra | Offer skills or availability, manage work, and build a truthful reputation. | Local helpers, tutors, creatives, technical specialists, and general service providers. |
| Administrator | Keep marketplace activity reviewable, lawful, and accountable. | Internal staff with explicit privileged permissions. |

The product is initially approachable to younger adults but must remain suitable for Indonesian adults across ages, professions, abilities, and levels of digital familiarity.

## 6. User Roles and Permissions

| Capability | Visitor | Pemesan | Mitra | Administrator |
|---|:---:|:---:|:---:|:---:|
| Browse public Jasa, categories, and public Mitra profiles | Yes | Yes | Yes | Yes |
| View privacy-minimized published Permintaan | Recommended under OD-34; no external indexing | Yes | Yes | Yes, within support/moderation scope |
| Create Permintaan | No | Yes | Yes when acting as Pemesan | Only for testing/support with audit |
| Order a Jasa or accept a Penawaran | No | Yes | Yes when acting as Pemesan | No, except audited support correction |
| Publish Jasa | No | No | Yes, subject to onboarding and moderation | Review only |
| Send Penawaran | No | No | Yes, when eligible | No |
| Message in a permitted marketplace context | No | Yes | Yes | Read only when policy allows and access is audited |
| Submit delivery or local proof | No | No | Assigned Mitra | No, except audited correction |
| Review a completed Pesanan | No | Eligible Pemesan | Eligible Pemesan when acting as customer | Moderate only |
| Verify Mitra, moderate content, manage reports/disputes | No | No | No | Yes, within assigned permission |
| Moderate user accounts | No | No | No | Yes, within assigned permission |

**Approved for closed beta (OD-31):** administrator access uses separate least-privilege permission groups for onboarding review, listing/content moderation, customer support, reports/disputes, account moderation, and payment/payout reconciliation. One administrator may hold multiple assigned groups but cannot self-grant, bypass audit, or perform a binding action without a reason. High-risk actions require step-up authentication; second approval may be added for financial or permanent actions.

**Approved for closed beta (OD-30):** every sensitive or binding state change has append-only audit history containing actor/trigger, timestamp, previous state, next state, reason, affected object and version, correlation/idempotency identifier, and evidence reference where applicable. Exact production retention duration remains an open P2 decision.

## 7. Multiple Non-Admin Roles on One Account

**Approved for closed beta (OD-02):** one normal account may act as Pemesan and activate a Mitra profile. The account keeps one identity and authentication history while presenting role-specific navigation and workspaces. A user acting as Mitra may place an unrelated order as Pemesan but may not order their own Jasa, submit or accept their own Penawaran, review themselves, or participate on both sides of one Pesanan. Administrator permission remains separate.

Role activation, deactivation, suspension, and administrator permissions are recorded in audit history. Switching views must not create a second customer identity or expose private Mitra verification documents.

### Closed-beta account deactivation and restrictions

Under approved **OD-28**, account deactivation is reversible first: disable the public profile and new marketplace actions while preserving the access needed for active obligations and safety cases. Irreversible deletion is handled manually until a record-specific retention policy is approved. Do not promise immediate deletion of transaction, report, dispute, payment, or audit history; exact retention durations remain P2 before public launch.

Under approved **OD-19**, restrictions are proportional: warning or limited capability where appropriate, immediate suspension for serious fraud/safety risk, explicit reason, review date where applicable, and an appeal path. Each active Pesanan is handled individually rather than silently cancelled.

## 8. Local Versus Digital Service Model

| Rule | Local | Digital |
|---|---|---|
| Service area | City/area is required; precise address is private. | `Dikerjakan online`; no location filter required. |
| Work context | Errand, pickup, queue, event help, or practical assistance. | Creative, learning, technical, data, or administrative work. |
| Completion evidence | Time-stamped proof, notes, allowed attachment, or Pemesan confirmation. | Versioned file/link delivery, notes, or Pemesan confirmation. |
| Search filters | Category, city/area, price, availability when real. | Category, price, delivery time when real; no irrelevant location filter. |
| Safety | No public precise address; agreed location shared only when necessary. | No unlawful access, impersonation, plagiarism, or prohibited content. |

A Jasa or Permintaan declares one primary fulfillment mode. Hybrid work may be supported only when its location and delivery requirements are clear; otherwise the user must choose the dominant mode. Under approved **OD-15**, public surfaces show only city, district, or broad area; the minimum precise address is shared only with active Pesanan participants after Mitra confirmation and after payment when required.

## 9. Initial Category Model

The approved homepage uses eight entry points:

**Lokal**

1. Antar & Titip Beli
2. Ambil Paket atau Dokumen
3. Antre & Urusan Harian
4. Bantuan Acara

**Digital**

1. Desain & Presentasi
2. Video & Audio
3. Belajar & Tutor
4. Teknologi & Data

**Approved for closed beta (OD-21):** use these eight as the MVP top-level taxonomy and add controlled task tags underneath them. The discovery page may expose more detailed tags without creating unsupported “popular” labels. Category changes must preserve existing Jasa and Permintaan discoverability.

## 10. Core Terminology

| Term | Meaning |
|---|---|
| Pemesan | Customer requesting or ordering work. |
| Mitra | Provider offering skills or availability. |
| Jasa | Reusable service listing published by a Mitra. |
| Permintaan | Custom task request published by a Pemesan. |
| Penawaran | Mitra's scoped proposal responding to a Permintaan. |
| Pesanan | Recorded agreement and work lifecycle between Pemesan and Mitra. |
| Pengiriman digital | Versioned digital file or link submitted for a Pesanan. |
| Bukti penyelesaian | Evidence submitted for local work. |
| Revisi | Request to correct delivered work within the agreed scope. |
| Laporan | Safety, policy, content, user, message, or Pesanan report. |
| Sengketa | Administrator-managed disagreement about a Pesanan. |
| Pemeriksaan profil Mitra | Closed-beta review of contact verification, profile completeness, portfolio, and manual onboarding eligibility; it is not government-ID verification. |

## 11. User Stories

### Pemesan

- As a visitor, I can understand that Jasama supports local and digital work and immediately search.
- As a Pemesan, I can compare a Jasa, Mitra, price basis, service area, verification state, and completed-order reviews.
- As a Pemesan, I can turn an unsuccessful search into a prefilled Permintaan without retyping it.
- As a Pemesan, I can accept one Penawaran and create a recorded Pesanan.
- As a Pemesan, I can track work, review delivery or proof, request an allowed revision, report a problem, and review only a completed Pesanan.
- As a Pemesan, I can save a Jasa or Mitra and rebook without losing the opportunity to revise scope.

### Mitra

- As a Mitra candidate, I can activate a provider profile and submit contact, profile, portfolio, and onboarding information for manual review without government-ID collection.
- As a Mitra, I can create, submit, pause, revise, and archive a moderated Jasa.
- As a Mitra, I can find eligible Permintaan and send a scoped Penawaran without open-bid gamification.
- As a Mitra, I can manage accepted work, communicate, submit delivery or proof, respond to revisions, and see an auditable status history.

### Administrator

- As an administrator, I can process verification, listing moderation, reports, disputes, and account restrictions within explicit permissions.
- As an administrator, I can see why a binding state changed, who changed it, and which evidence supported the change.
- As an administrator, I cannot silently rewrite user agreements or delete audit history.

## 12. Public Pages

| Field | Requirement |
|---|---|
| Purpose | Explain Jasama, support discovery, expose truthful trust mechanisms, and route visitors to registration. |
| Actors | Visitors and signed-in users. |
| Preconditions | Public content is published and safe; demo records are excluded from production. |
| Main flow | Homepage → search/category → results → Jasa or Mitra detail → sign in or continue to order/request. |
| Alternate flow | No match → prefilled `Buat Permintaan`; prospective provider → `Jadi Mitra`. |
| Error cases | Search unavailable, empty category, removed listing, stale link, or unavailable profile; preserve query and provide recovery. |
| Permissions | Public read only; private addresses, documents, messages, and order evidence never appear. |
| Notifications | None for browsing; saved-search or favorite notifications require sign-in and consent. |
| Acceptance criteria | Homepage follows the eight-part structure; `Jelajahi Jasa` is primary; `Buat Permintaan` is prominent; categories are four local and four digital; public claims use real evidence only. |

Public pages include homepage, discovery results, category view, Jasa detail, public Mitra profile, how it works, become a Mitra, safety/rules, help entry, terms, and privacy.

## 13. Authentication and Onboarding Pages

| Field | Requirement |
|---|---|
| Purpose | Create and recover a normal account, establish consent, and activate role-specific capabilities. |
| Actors | Visitor, account holder, Mitra candidate, administrator for audited support. |
| Preconditions | User can access a verified contact channel and accept current terms/privacy notice. |
| Main flow | Register → verify contact → complete minimum profile → enter Pemesan workspace; optionally activate Mitra onboarding. |
| Alternate flow | Sign in, forgot password, resend verification, change contact, or resume incomplete Mitra onboarding. |
| Error cases | Duplicate contact, expired link, weak credential, rate limit, inaccessible verification method, suspended account. |
| Permissions | A normal user cannot self-grant administrator access or verified status. |
| Notifications | Contact verification, password reset, security-sensitive account change, onboarding submission/result. |
| Acceptance criteria | Labels and errors are accessible; values survive recoverable errors; role activation is explicit; admin privilege is separate; suspended users receive a safe explanation and appeal/help path when available. |

## 14. Pemesan Dashboard

| Field | Requirement |
|---|---|
| Purpose | Give Pemesan a clear view of Permintaan, Penawaran, Pesanan, favorites, messages, reports, and required actions. |
| Actors | Authenticated account acting as Pemesan. |
| Preconditions | Active account. |
| Main flow | View action queue → open relevant object → complete next allowed action → see updated status history. |
| Alternate flow | Filter by state, search history, revisit favorites, rebook, or resume draft Permintaan. |
| Error cases | Data unavailable, object removed, access revoked, stale state, duplicate submission. |
| Permissions | Only participant-owned or explicitly shared records; no other user's private activity. |
| Notifications | In-app indicators for offers, messages, deliveries, revision responses, cancellations, disputes, and review eligibility. |
| Acceptance criteria | Current state and next action are explicit; empty/error states preserve navigation; dense data follows `DESIGN.md`; binding changes require confirmation and audit. |

## 15. Mitra Dashboard

| Field | Requirement |
|---|---|
| Purpose | Let Mitra manage onboarding, Jasa, Penawaran, Pesanan, delivery/proof, availability, reports, and reputation. |
| Actors | Account with active or in-progress Mitra profile. |
| Preconditions | Active normal account; restricted features reflect verification/moderation state. |
| Main flow | Resolve onboarding or action queue → manage listing/offer/order → submit required work → review history. |
| Alternate flow | Pause a Jasa, withdraw eligible offer, request cancellation, update portfolio, or switch to Pemesan view. |
| Error cases | Verification pending, listing rejected, offer expired, order state changed, upload failed, account restricted. |
| Permissions | Only owned Jasa, authored Penawaran, assigned Pesanan, and permitted messages. |
| Notifications | Verification, moderation, new eligible activity, offer result, order changes, messages, revisions, reports, disputes. |
| Acceptance criteria | Restricted actions explain why; public verification claims reflect actual state; Mitra cannot transact with self; every binding change is auditable. |

## 16. Administrator Dashboard

| Field | Requirement |
|---|---|
| Purpose | Process queues for verification, listings, reports, disputes, account moderation, and audit review. |
| Actors | Administrators with explicit scoped permissions. |
| Preconditions | Privileged authenticated session; sensitive actions may require stronger re-authentication **(OD-22)**. |
| Main flow | Open assigned queue → inspect evidence/context → choose allowed outcome → record reason → notify affected parties. |
| Alternate flow | Request more information, reassign, escalate, reverse a reversible decision, or close with no action. |
| Error cases | Insufficient permission, stale decision, missing evidence, conflict of interest, concurrent review. |
| Permissions | Least privilege; sensitive documents and messages are opened only when required and access is audited. |
| Notifications | Queue assignment, SLA reminder when policy exists, decision notice, appeal or follow-up. |
| Acceptance criteria | No silent state override; reason is required for adverse/binding actions; audit history is immutable to ordinary admins; private data is minimized. |

## 17. Jasa Creation and Management

| Field | Requirement |
|---|---|
| Purpose | Let an eligible Mitra publish a clear reusable service. |
| Actors | Mitra; administrator as moderator. |
| Preconditions | Active account, Mitra profile, permitted category, completed closed-beta onboarding review under **OD-13/OD-33**, and required profile fields; publication moderation follows approved **OD-18**. |
| Main flow | Draft → add title, category, mode, scope/exclusions, fixed or clearly defined base price with visible included scope, area/delivery, and media → preview → submit → moderation → publish. |
| Alternate flow | Save draft, revise after requested changes, pause, republish, or archive. |
| Error cases | Prohibited service, missing scope, unsupported media, invalid price, precise address exposed, duplicate submit. |
| Permissions | Mitra edits owned Jasa; moderator changes moderation state but does not rewrite commercial terms. |
| Notifications | Submission received, changes requested, approved/published, rejected, removed, or policy update affecting listing. |
| Acceptance criteria | Approved OD-03 permits fixed price or clearly defined base price only when included scope is visible; hourly billing and complex bidding are deferred; required information is present; public card/detail remain truthful; every new Jasa and material edit receives manual pre-publication review; moderation reason is recorded; archived/removed Jasa cannot accept new orders; paused/changed/removed/archived Jasa never rewrite existing Pesanan snapshots. |

## 18. Permintaan Creation and Management

| Field | Requirement |
|---|---|
| Purpose | Capture a specific need when browsing is insufficient. |
| Actors | Pemesan; privacy-minimized visitor readers under approved OD-34; authenticated eligible Mitra readers/responders; administrator moderator. |
| Preconditions | Authenticated active account; request complies with service and safety policy. |
| Main flow | Draft or prefill from search → describe outcome, mode, category, timing, budget guidance, area if local → preview → publish → receive Penawaran. |
| Alternate flow | Save draft, edit while allowed, close without selection, cancel, expire after 14 calendar days, reopen with a new 14-day validity window, or convert an accepted Penawaran into Pesanan. |
| Error cases | Prohibited request, unsafe address disclosure, invalid timing/budget, no eligible respondents, expired request. |
| Permissions | Owner edits until a Penawaran is accepted. Under approved **OD-34**, visitors may view only privacy-minimized published fields; Permintaan details are `noindex` and excluded from public sitemaps. Only authenticated Mitra passing account status, Mitra status, category permission, local service-area match when applicable, restrictions, and self-dealing checks may respond. |
| Public and hidden fields | Public/minimized: task outcome, category, local/digital mode, broad city/area, budget guidance, timing, and approved public constraints. Hidden: Pemesan identity/contact, precise address, private notes, and non-public attachments. |
| Notifications | Published, new Penawaran, offer withdrawn/expired, reminder before request expiry, selected, cancelled, removed, or reopened. |
| Acceptance criteria | Browse context is preserved; no complex open bidding; audience preview separates visible/hidden fields; only eligible authenticated Mitra can respond; detail is `noindex` and absent from public sitemaps; approved OD-26 expires requests after 14 calendar days and offers with the request or earlier stated validity; reopening starts a new valid window; accepting one offer closes competing acceptance; scheduled actions and state changes are idempotent/audited. |

## 19. Penawaran Workflow

| Field | Requirement |
|---|---|
| Purpose | Let one Mitra propose scope, price, schedule, and assumptions for one Permintaan. |
| Actors | Eligible Mitra and owning Pemesan. |
| Preconditions | Permintaan accepts offers; Mitra is eligible and not the owner; no prohibited terms. |
| Main flow | Mitra drafts → specifies deliverable, price, timing, revisions if agreed, and notes → submits → Pemesan reviews → accepts → Pesanan created from immutable offer snapshot. |
| Alternate flow | Mitra withdraws before acceptance; Pemesan rejects; offer expires; parties clarify through allowed messaging and Mitra submits a replacement version. |
| Error cases | Request closed, price invalid, offer stale, self-dealing, simultaneous acceptance, content violation. |
| Permissions | Only author edits draft; submitted commercial terms are versioned, not silently overwritten; only request owner accepts. |
| Notifications | Offer submitted, clarified, replaced, accepted, rejected, withdrawn, or expired. |
| Acceptance criteria | Exactly one offer can become the active Pesanan; accepted terms are preserved; losing offers close safely; all binding transitions are audited. |

## 20. Messaging and Attachments

| Field | Requirement |
|---|---|
| Purpose | Clarify marketplace work while preserving agreed context and safety controls. |
| Actors | Permitted Pemesan, Mitra, and audited administrator when policy allows. |
| Preconditions | An explicit-intent Jasa inquiry or permitted Permintaan, Penawaran, or Pesanan context exists under approved **OD-16**. |
| Main flow | Open contextual thread → send text/allowed attachment → recipient receives notification → message remains tied to object history. |
| Alternate flow | Report message, remove own unsent draft, retry failed attachment, or continue a thread after offer/order transition when permitted. |
| Error cases | Unauthorized thread, blocked participant, unsafe file, size/type limit, malware result, upload failure, rate limit. |
| Permissions | Context participants only; unsolicited open direct messages are prohibited; admins access content only for support/moderation with audit. Attachment limits and types are approved under **OD-17**. |
| Notifications | New message, mention if supported, upload failure, reported-content outcome when appropriate. |
| Acceptance criteria | Users cannot enumerate unrelated threads; message timestamps and sender identity are clear; attachments follow OD-17: 10 MB per file, five files per message/submission, approved images/PDF/text/CSV/office documents only, approved access-controlled links for large audio/video, and no executables, scripts, archives, or password-protected files; reported content remains available to authorized review even if hidden from participants. |

## 21. Pesanan Workflow

| Field | Requirement |
|---|---|
| Purpose | Record an agreed service and coordinate it to a terminal outcome. |
| Actors | Pemesan, assigned Mitra, payment adapter, administrator for allowed interventions. |
| Preconditions | Valid Jasa order terms or accepted Penawaran snapshot; eligible participants; no self-order. |
| Main flow | Existing Jasa: create pending confirmation → Mitra explicitly accepts current immutable terms → only then request payment if required → start. Accepted Penawaran: create from already accepted snapshot → payment if required → start. Then execute → submit delivery/proof → approve or revise → complete → become review-eligible. |
| Alternate flow | Mitra declines; Pemesan cancels before confirmation; Mitra proposes changed terms that require explicit Pemesan acceptance and a new immutable snapshot; send a reminder after 12 hours; after 24 hours with no response, idempotently cancel the unconfirmed order without payment using the order timezone; later clarification, blocked work, revision, cancellation request, report, or dispute. |
| Error cases | Payment attempted before confirmation, stale/changed terms without Pemesan acceptance, duplicate response, duplicate reminder/timeout execution, payment failure, unavailable Mitra, invalid transition, lost upload, concurrent action. |
| Permissions | Only participants perform ordinary transitions; admin-only transitions require reason and audit; webhook transitions are authenticated. |
| Notifications | Creation, confirmation, payment state, start, status change, delivery/proof, revision, cancellation, dispute, completion, review eligibility. |
| Acceptance criteria | Current state, next action, price/scope snapshot, and history are visible; approved OD-29 accept/decline/pre-confirmation cancel/changed-terms paths are explicit; reminder occurs once after 12 hours; no-response cancellation occurs once after 24 hours in the order timezone; payment is impossible before confirmation; terminal state rules follow `STATE_MACHINES.md`; all binding transitions are audited. |

## 22. Digital Delivery and Local Proof of Completion

| Field | Requirement |
|---|---|
| Purpose | Provide verifiable completion material appropriate to service mode. |
| Actors | Assigned Mitra, Pemesan, authorized administrator during dispute. |
| Preconditions | Active Pesanan in a submittable work state. |
| Main flow | Mitra adds notes and required file/link or local proof → validates → submits immutable version → Pemesan reviews → approves, requests eligible revision, or reports issue. |
| Alternate flow | Save draft, retry upload, replace draft before submission, or submit a later revision version. |
| Error cases | Missing required material, unsafe attachment, inaccessible link, unsupported type, upload failure, wrong order state. |
| Permissions | Only assigned Mitra submits; only Pemesan accepts/revises; admin views evidence only when authorized. |
| Notifications | Submission, failed processing, acceptance, revision request, dispute evidence request. |
| Acceptance criteria | Version, author, timestamp, notes, and files/links are preserved; local proof follows approved OD-27 with a completion note plus category-appropriate photo/document or explicit Pemesan confirmation; no GPS or unnecessary precise-location metadata; previous submitted versions remain auditable. |

## 23. Revisions

| Field | Requirement |
|---|---|
| Purpose | Correct delivered work within the agreed scope without turning the order into unlimited new work. |
| Actors | Pemesan requests; Mitra responds; administrator may resolve disputes. |
| Preconditions | Delivery/proof submitted; revision window and allowance remain open; request relates to agreed scope. |
| Main flow | Pemesan describes mismatch → system records revision → Mitra accepts or explains scope conflict → work resumes → new delivery/proof version submitted. |
| Alternate flow | Pemesan withdraws request; parties agree to a changed scope through an allowed new agreement; dispute is opened. |
| Error cases | Window expired, limit reached, vague request, out-of-scope demand, cancelled/completed order. |
| Permissions | Pemesan initiates; Mitra cannot mark fulfilled without new submission; admin does not invent scope. |
| Notifications | Revision requested, accepted/rejected with reason, due update, fulfilled, escalated. |
| Acceptance criteria | Every revision references a delivery version and reason; the allowance is snapshotted from the Jasa or accepted Penawaran; custom digital work defaults to one included revision; local work uses proof correction; additional scope requires a new agreement; original scope remains accessible under approved **OD-09**. |

## 24. Cancellation

| Field | Requirement |
|---|---|
| Purpose | End work safely when continuation is no longer appropriate. |
| Actors | Pemesan, Mitra, administrator; payment adapter when money movement applies. |
| Preconditions | Pesanan is cancellable under approved policy; actor provides reason. |
| Main flow | Apply approved OD-07 eligibility for the current order state → record reason → obtain required participant agreement or administrator decision → stop or continue work → close and notify. Any refund or payout evaluation occurs separately under OD-08/OD-32. |
| Alternate flow | Before confirmation, Pemesan cancels or Mitra declines; after confirmation before payment, either party cancels with reason; after payment before work, a cancellation request may proceed while financial outcomes stay separate; after work starts or submission, require mutual agreement or administrator review; safety/dispute cases may pause ordinary resolution. |
| Error cases | Terminal order, concurrent completion, refund failure, evidence missing, abusive repeated requests. |
| Permissions | Participant requests; unilateral cancellation rights depend on state; administrator decisions require scoped permission and reason. |
| Notifications | Request, required response, approval/denial, final closure, and separately generated Payment/Payout status when applicable. |
| Acceptance criteria | Approved **OD-07** is state-based; submitted evidence remains preserved; cancellation never silently determines refund or payout outcomes; OD-08/OD-32 remain separate; all transitions are audited. |

## 25. Payment Assumptions

| Field | Requirement |
|---|---|
| Purpose | Model payment-dependent order behavior without overstating production protection. |
| Actors | Pemesan, payment adapter/provider, administrator for reconciliation, Mitra as status viewer. |
| Preconditions | Pesanan has agreed immutable terms, Mitra confirmation when required, and an approved payment path. |
| Main flow | Create payment attempt → show pending → receive authenticated result → update Pesanan eligibility → record reconciliation event. |
| Alternate flow | Retry failed/expired attempt, use approved alternative method, or process approved refund. |
| Error cases | Duplicate callback, invalid signature, amount mismatch, timeout, provider outage, refund failure. |
| Permissions | Users cannot mark themselves paid; provider webhook or audited mock tool controls payment result. |
| Notifications | Payment pending, paid, failed, expired, refund pending/completed/failed. |
| Acceptance criteria | Closed beta uses mock payment only; approved OD-06 requires Mitra confirmation before a payment attempt and a successful required mock/real payment state before work starts; later provider integration preserves the same product states; no public protection claim ships before production flow/webhooks operate; OD-04/OD-05/OD-08 remain open. |

**Approved for closed beta (OD-06):** use mock payment only, after Mitra confirmation and before work starts when payment is required. Production method, platform fee, refund policy, and payout behavior remain open under OD-04/OD-05/OD-08/OD-32.

### Mitra Settlement and Payout

| Field | Requirement |
|---|---|
| Purpose | Represent provider earnings, holds, transfer attempts, failures, and corrections without assuming who holds funds or overstating production readiness. |
| Actors | Mitra as status viewer; system/provider callback; authorized finance/reconciliation administrator. |
| Preconditions | **OD-32** approved; real-money payment path operational; funds receiver, merchant-of-record role, eligibility event, fee, timing, verified payout destination, dispute hold, and reconciliation rules approved. |
| Main flow | Payment/order event → pending eligibility or hold → eligibility → provider-neutral processing → paid, with immutable failure/retry history. |
| Alternate flow | Hold/release, cancel before transfer, retry a failed attempt, or create a linked reversal/correction without rewriting the original payout. |
| Error cases | Unverified destination, amount/currency/fee mismatch, provider failure, duplicate callback, dispute/refund race, stale payout-account change, reconciliation mismatch. |
| Permissions | Mitra cannot mark earnings eligible/paid or edit financial history; scoped administrators require OD-22/OD-31 controls for holds, correction, and reconciliation. |
| Notifications | Eligibility, hold/release, processing, paid, failed/retry, cancelled, reversal/correction. |
| Acceptance criteria | `STATE_MACHINES.md` remains provider-neutral; payment success alone does not guarantee payout; disputes may hold only under approved policy; fees/net amounts are explicit; all mock/demo states move no money; all production real-money collection, settlement, and payout stay disabled until **OD-05/OD-32** approval and operational readiness. |

## 26. Ratings and Reviews

| Field | Requirement |
|---|---|
| Purpose | Let customers describe completed-order experience with verifiable provenance. |
| Actors | Eligible Pemesan; public readers; administrator moderator. |
| Preconditions | Pesanan is completed; reviewer was the Pemesan; one active review per eligible Pesanan. |
| Main flow | Eligible user rates and writes optional review → previews → publishes → review displays completed-Pesanan provenance. |
| Alternate flow | Save draft if supported, make the single approved edit within seven days under **OD-23**, withdraw, report, hide pending moderation, or remove for policy violation. |
| Error cases | Ineligible order, duplicate review, prohibited content, invalid rating, account restriction. |
| Permissions | Only eligible Pemesan creates; Mitra cannot review self or alter review; admin moderation requires reason. |
| Notifications | Review eligibility, published review, moderation action, provider response if later approved. |
| Acceptance criteria | One review per completed Pesanan; one edit within seven days with preserved history and `Diedit` marker; reviewer withdrawal is allowed; Mitra public responses are deferred; numeric rating always shows count; new Mitra shows `Belum ada ulasan`; no cherry-picked testimonials; demo reviews remain `is_demo` outside production. |

## 27. Favorites and Rebooking

| Field | Requirement |
|---|---|
| Purpose | Let Pemesan retain trusted options and start repeat work efficiently. |
| Actors | Authenticated account acting as Pemesan. |
| Preconditions | Target Jasa or Mitra is viewable. |
| Main flow | Save favorite → view saved list → open target → rebook with current terms review. |
| Alternate flow | Remove favorite, target unavailable, or create Permintaan based on prior scope. |
| Error cases | Removed listing, suspended Mitra, duplicate request, network failure. |
| Permissions | Favorites are private to account unless future sharing is approved. |
| Notifications | Quiet inline confirmation; no marketing message without consent. |
| Acceptance criteria | Favorite action has accessible name; rebooking never silently reuses stale price, scope, address, or availability; unavailable targets offer a safe alternative. |

## 28. Verification

| Field | Requirement |
|---|---|
| Purpose | Manually assess closed-beta Mitra onboarding eligibility and expose a narrowly truthful profile-review status without claiming government-ID verification. |
| Actors | Mitra candidate and authorized administrator. |
| Preconditions | Verified email and phone, required profile fields, portfolio where applicable, and manual onboarding information under approved **OD-13/OD-33**. |
| Main flow | Submit contact/profile/portfolio/onboarding information → authorized admin reviews eligibility → approve, reject, or request changes → status and limited explanation update. |
| Alternate flow | Invitation, referral, or live onboarding may supplement review; candidate may resubmit, be suspended, appeal/review, or voluntarily deactivate the Mitra profile. |
| Error cases | Unverified contact, incomplete/misleading profile, portfolio concern, duplicate-account concern, unauthorized access, or review conflict. |
| Permissions | Candidate sees their case; only assigned OD-31 onboarding reviewers decide; closed beta has no government-ID document view/download because no government ID or identity-match media is collected. |
| Notifications | Submission, request for changes, profile reviewed, rejected, or suspended. |
| Acceptance criteria | Closed beta displays `Profil Mitra diperiksa` or another narrowly truthful equivalent and never `Identitas terverifikasi`; government ID and identity-match media are neither collected nor stored; future government-ID verification, lifecycle controls, and exact retention remain deferred P2; expiry policy remains open under **OD-14**. |

## 29. Listing Moderation

| Field | Requirement |
|---|---|
| Purpose | Prevent prohibited, misleading, unsafe, or incomplete Jasa from publication. |
| Actors | Mitra author and authorized moderator. |
| Preconditions | Listing submitted with required content. |
| Main flow | Queue → review scope, category, copy, price basis, area, media, and policy → approve, request changes, or reject. |
| Alternate flow | Post-publication report triggers re-review; listing may pause while preserving existing Pesanan. |
| Error cases | Conflicting review, insufficient evidence, moderator conflict, repeated violation. |
| Permissions | Moderator changes state/reason; author changes listing content; neither rewrites the other's history. |
| Notifications | Submission, queue result, change request, removal, appeal route if approved. |
| Acceptance criteria | Every new Jasa and material edit receives approved manual pre-publication review; public listing has approved state; reason accompanies adverse action; existing orders keep their immutable snapshot when the Jasa is paused, changed, removed, or archived under **OD-18**. |

## 30. Reports and Disputes

| Field | Requirement |
|---|---|
| Purpose | Provide accountable paths for policy issues and order disagreements. |
| Actors | Visitor where allowed, account holder, Pesanan participant, authorized administrator. |
| Preconditions | Reportable object exists or a safety intake permits missing/removed content; dispute eligibility follows **OD-12**. |
| Main flow | Choose object/reason → describe issue → attach permitted evidence → acknowledge → triage → investigate → decide → notify/close. |
| Alternate flow | Request information, consolidate duplicates, urgent safety escalation, reopen on new evidence, or redirect support question. |
| Error cases | Abuse/spam, missing evidence, unauthorized disclosure, conflict of interest, deadline expired. |
| Permissions | Reporter sees own case status; reported party sees only safe necessary details; admin access is scoped and audited. |
| Notifications | Receipt, request for information, material status update, decision, appeal/reopen path when allowed. |
| Acceptance criteria | Report does not promise outcome; dispute preserves order evidence; decisions state reason; deadlines/refund effects are not assumed; all sensitive transitions are audited. |

## 31. Notifications

| Field | Requirement |
|---|---|
| Purpose | Tell users about required action and material state changes without spam. |
| Actors | System, Pemesan, Mitra, administrator. |
| Preconditions | A notification event occurs and recipient is authorized; channel consent applies. |
| Main flow | Create in-app notification → route to exact object/action → mark read after user access. |
| Alternate flow | Send approved email or other channel based on **OD-24**; digest non-urgent activity. |
| Error cases | Delivery failure, stale deep link, revoked access, duplicate event. |
| Permissions | Notification content reveals minimum necessary private information. |
| Notifications | Security, verification, moderation, offer, order, payment, delivery, revision, cancellation, report, dispute, and review events. |
| Acceptance criteria | Critical events are not silently suppressed; duplicates are controlled; users can manage non-essential channels; inaccessible object links show safe recovery. |

## 32. Location and Privacy Rules

| Field | Requirement |
|---|---|
| Purpose | Support local matching while minimizing exposure of personal location. |
| Actors | Pemesan, Mitra, administrator when support requires. |
| Preconditions | Local Jasa, Permintaan, or Pesanan. |
| Main flow | Publicly select city/district/broad area → match candidates → after Mitra confirmation share the minimum precise location necessary with active Pesanan participants; when payment is required, share after payment under approved **OD-15**. |
| Alternate flow | Use neutral meeting point, service area, remote handoff, or decline location sharing. |
| Error cases | Precise address entered in public field, unsupported area, location mismatch, unauthorized access. |
| Permissions | Public sees city, district, or broad area only; precise address is never public and is limited to active Pesanan participants and authorized support, with audit where sensitive. |
| Notifications | Address shared/changed, access revoked, or safety warning when appropriate. |
| Acceptance criteria | No GPS requirement; no public precise address; data is minimized; expansion beyond pilot does not require changing the core local/digital model. |

**Approved for closed beta (OD-01):** offer digital services nationally where operations support them, with Surabaya as the initial local-service pilot. Support later Indonesian expansion and show honest unavailable/interest states where local operations are unsupported.

## 33. Academic-Integrity and Prohibited-Service Policy

Jasama may support tutoring, consultation, explanation, proofreading, debugging, design, delivery, errands, and project assistance. It must reject or remove:

- Active assistance during an exam or assessment.
- Impersonation or taking an assessment for someone.
- Plagiarism or submission of another person's work as one's own.
- Fabricated documents, credentials, citations, evidence, or records.
- Manipulated research data or fraudulent analysis.
- Illegal, dangerous, abusive, exploitative, discriminatory, or privacy-invasive services.
- Unauthorized system access, credential theft, malware, or circumvention of access controls.

Creation and moderation interfaces must explain the boundary in plain Indonesian. Enforcement applies to Jasa, Permintaan, Penawaran, messages, attachments, deliveries, and public profiles. A policy action records object, reason, actor, evidence reference, and appeal/recovery path when available.

## 34. Accessibility Requirements

- Meet WCAG 2.2 AA for the MVP.
- Support complete keyboard operation and logical focus order.
- Use the solid 3px focus outline with 2px offset from `DESIGN.md`.
- Maintain minimum 44×44 CSS pixel touch targets.
- Provide persistent labels, descriptive errors, status text plus icons, and live-region announcements for asynchronous actions.
- Reflow at 320px and remain usable at 200% zoom.
- Respect reduced-motion preferences and avoid motion-dependent understanding.
- Preserve user input after recoverable errors.
- Use semantic HTML before ARIA and test major flows with keyboard and a screen reader.
- Ensure Indonesian labels wrap without truncating primary actions.

## 35. Development and Staging Data Rules

1. Fabricated testimonials, claims, statistics, ratings, reviews, prices, partners, rankings, and performance evidence are prohibited in production and public-facing claims.
2. Development and staging may use realistic synthetic prices, ratings, reviews, profiles, listings, and orders only on records marked `is_demo`.
3. Staging displays a persistent demo banner.
4. Production rejects or excludes every `is_demo` record.
5. Synthetic data is never presented as real customer evidence.
6. Per-object demo labels are needed only when demo and real records are intentionally shown together.
7. Synthetic testimonials, public claims, aggregate statistics, partners, rankings, and performance evidence are not demo substitutes.
8. Test users and administrators cannot accidentally publish demo records by changing ordinary moderation state.

## 36. Analytics Events Required for Product Evaluation

Analytics must avoid sensitive message, address, document, attachment, and free-text contents. Required events:

| Journey | Events |
|---|---|
| Homepage | `homepage_viewed`, `hero_search_started`, `browse_clicked`, `request_clicked`, `category_opened`, `become_mitra_clicked` |
| Discovery | `search_submitted`, `suggestion_selected`, `filter_applied`, `sort_changed`, `result_opened`, `no_results_seen`, `browse_to_request_started` |
| Jasa | `jasa_viewed`, `mitra_profile_opened`, `favorite_added`, `order_started` |
| Permintaan | `request_draft_saved`, `request_published`, `offer_received`, `offer_accepted`, `request_closed` |
| Penawaran | `offer_draft_saved`, `offer_submitted`, `offer_withdrawn`, `offer_accepted`, `offer_expired` |
| Pesanan | `order_created`, `order_confirmed`, `work_started`, `delivery_submitted`, `revision_requested`, `order_completed`, `order_cancelled`, `dispute_opened` |
| Trust | `verification_submitted`, `verification_decided`, `listing_moderated`, `report_submitted`, `dispute_decided`, `review_published` |
| Reliability | `flow_error_seen`, `upload_failed`, `payment_failed`, `notification_opened`, `recovery_succeeded` |

Every event identifies environment and `is_demo` status so demo activity never contaminates production metrics. Final event names and retention must be reviewed before implementation; no tracking is allowed without the required privacy notice and consent basis.

## 37. MVP Success Metrics

Targets are unresolved business decisions; the MVP must measure:

1. Search-to-Jasa-detail rate.
2. No-result rate and no-result-to-Permintaan conversion.
3. Jasa-detail-to-order-start rate.
4. Permintaan publication-to-first-valid-Penawaran rate.
5. Penawaran acceptance rate.
6. Pesanan completion, cancellation, revision, report, and dispute rates.
7. Median time to first valid offer and to completion, segmented by local/digital.
8. Percentage of published Jasa that pass moderation without rework.
9. Verification completion and rework rates.
10. Review eligibility-to-publication rate.
11. Critical flow error and recovery rates.
12. Accessibility defect escape rate for major flows.

No metric may be displayed publicly as customer evidence until measured from real production data and approved for publication. Numeric success thresholds require approval **(OD-25)**.

## 38. Functional Acceptance Criteria

The MVP is functionally acceptable when:

1. Visitors can search, browse eight top-level categories, and view truthful public Jasa/Mitra information.
2. Search query and applicable filters can prefill a Permintaan.
3. One account can follow the approved role model without self-dealing.
4. Mitra onboarding, verification, Jasa moderation, Permintaan, Penawaran, Pesanan, messaging, delivery/proof, revision, cancellation, payment, provider-neutral payout, report, dispute, review, and account moderation follow `STATE_MACHINES.md`.
5. Reviews can be created only from completed Pesanan.
6. Existing Jasa and accepted Penawaran create immutable commercial snapshots for Pesanan.
7. Local public records never expose precise addresses.
8. Sensitive and binding transitions create audit history.
9. Administrators cannot perform privileged transitions without permission and reason.
10. Demo data is marked, bannered in staging, and rejected/excluded from production.
11. Loading, empty, no-results, unavailable, success, and error states provide a recovery path.
12. Prohibited-service controls apply across listings, requests, offers, messages, attachments, and deliveries.

## 39. Non-Functional Acceptance Criteria

- **Accessibility:** WCAG 2.2 AA checks pass for major flows; keyboard and screen-reader paths are verified.
- **Responsive behavior:** all major flows work from 320px through desktop without required horizontal page scrolling.
- **Security:** least privilege, safe session handling, rate limiting at abuse-prone boundaries, validated uploads, and audited privileged access are required.
- **Privacy:** public/private field separation is enforced; precise addresses are minimized and access-controlled; closed beta collects no government ID or identity-match media.
- **Reliability:** user input survives recoverable failures; duplicate submissions and callbacks are idempotently rejected at the product-behavior level.
- **Performance:** discovery and dashboards provide responsive feedback and stable layout; exact budgets require technical planning outside this document.
- **Auditability:** append-only history records actor/trigger, timestamp, prior state, new state, reason, affected object/version, correlation/idempotency identifier, and evidence reference where applicable for binding/sensitive changes; exact production retention remains P2.
- **Observability:** critical flow failures and state-transition errors are diagnosable without logging private message or document contents.
- **Localization:** natural Indonesian is primary; formats use Indonesian currency, date, and time conventions.
- **Environment separation:** staging demo behavior cannot leak records or aggregate metrics into production.

## 40. Explicitly Deferred Features

- Production Midtrans integration until the later payment phase.
- Real-money collection, settlement, and Mitra payout until OD-05/OD-32 approval and production operational readiness.
- Internal wallet, escrow-like balance, or platform-held funds.
- Native iOS or Android applications.
- GPS tracking and real-time courier map.
- Internal video calling.
- AI matching, generation, moderation, or support features.
- Complex bidding, auctions, ranking wars, or paid offer placement.
- Paid marketing integrations.
- Public provider rankings or performance guarantees.
- Multi-currency, cross-border services, subscriptions, service bundles, or enterprise procurement.
- Automated dispute adjudication.
- Broad social features, public follower counts, or public activity feeds.
- Any payment-protection, refund, guarantee, or 24-hour support claim before approved policy and operational evidence exist.
