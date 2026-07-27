# Jasama Open Decisions

Status: **Mixed — closed-beta approvals recorded; remaining decisions open**  
Product authority: `PRODUCT.md`  
Affected requirements: `docs/PRD.md` and `docs/STATE_MACHINES.md`

This is the numbered decision log for MVP business and policy choices. Original options, recommendations, risks, and approval history remain preserved. A recommendation is not an approved fact unless its decision contains an approval record. Production behavior that depends on an open decision remains disabled or explicitly non-production until approval is recorded.

Priority is the latest safe approval boundary: **P0** before architecture/schema, **P1** before closed beta, **P2** before public real-money launch, and **P3** after pilot evidence.

## Decision Summary

| ID | Priority | Status | Decision | Recommended option | Required approval |
|---|---|---|---|---|---|
| OD-01 | P0 | Approved for closed beta | Pilot launch geography | Digital nationally where supported; local Surabaya pilot | Product + operations |
| OD-02 | P0 | Approved for closed beta | One account as Pemesan and Mitra | One normal multi-role account | Product + security |
| OD-03 | P0 | Approved for closed beta | Pricing model | Fixed/base Jasa; agreed Penawaran for custom work | Product + finance |
| OD-04 | P2 | Open | Platform service fee | No fee in mock phase; approve simple transparent fee before real payments | Product + finance |
| OD-05 | P2 | Open | Initial payment method | Mock in development; Midtrans before public real-money orders | Product + finance + engineering |
| OD-06 | P0 | Approved for closed beta | Payment timing | Confirm first; mock payment second when required; then work | Product + finance + operations |
| OD-07 | P0 | Approved for closed beta | Cancellation rules | State-based cancellation; refund and payout outcomes separate | Product + operations + legal |
| OD-08 | P2 | Open | Refund rules | Manual approved outcome; no automatic refund | Product + finance + legal |
| OD-09 | P0 | Approved for closed beta | Revision limits | Snapshotted allowance; one custom-digital default; local proof correction | Product + operations |
| OD-10 | P1 | Open | Submission approval period | 72 hours with reminders | Product + operations |
| OD-11 | P1 | Open | Automatic Pesanan completion | Enable only after OD-10, reminders, and no open issue | Product + operations + legal |
| OD-12 | P1 | Open | Dispute submission deadline | Seven calendar days | Product + operations + legal |
| OD-13 | P0 | Approved for closed beta | Verification evidence | Contact/profile/portfolio/manual onboarding review; no government ID | Product + privacy/legal + operations |
| OD-14 | P1 | Open | Verification expiration | Annual renewal with advance notice | Product + privacy/legal + operations |
| OD-15 | P0 | Approved for closed beta | Exact-address sharing | Minimum address after confirmation and payment when required | Product + privacy/security |
| OD-16 | P0 | Approved for closed beta | Messaging access rules | Contextual threads only; no unsolicited open DMs | Product + trust & safety |
| OD-17 | P0 | Approved for closed beta | Attachment limits and types | 10 MB each; five allowlisted files; large media by approved link | Product + security + operations |
| OD-18 | P0 | Approved for closed beta | Content moderation workflow | Manual pre-publication review for new Jasa and material edits | Product + trust & safety + operations |
| OD-19 | P0 | Approved for closed beta | Provider suspension rules | Graduated restrictions; serious-risk suspension; active orders handled individually | Product + trust & safety + legal |
| OD-20 | P1 | Open | Customer support operating model | Indonesian business-hours support; no 24-hour claim | Product + operations |
| OD-21 | P0 | Approved for closed beta | MVP category taxonomy | Eight approved top-level categories plus task tags | Product |
| OD-22 | P1 | Open | Administrator reauthentication | MFA plus reauthentication for sensitive actions | Security + product |
| OD-23 | P0 | Approved for closed beta | Review editing and responses | One review; one seven-day edit; withdrawal; no provider response | Product + trust & safety |
| OD-24 | P1 | Open | Notification channels | In-app plus critical email; no WhatsApp in MVP | Product + operations + privacy |
| OD-25 | P3 | Open | Numeric success thresholds | Measure closed-pilot baseline before setting thresholds | Product + business |
| OD-26 | P0 | Approved for closed beta | Permintaan and Penawaran expiry | Request 14 days; offers expire with request or earlier validity | Product + operations |
| OD-27 | P0 | Approved for closed beta | Local proof standard | Note plus appropriate photo/document or customer confirmation; no GPS | Product + privacy + operations |
| OD-28 | P0 | Approved for closed beta | Account deactivation and retention | Reversible deactivation; manual deletion; exact duration remains P2 | Product + privacy/legal + security |
| OD-29 | P0 | Approved for closed beta | Existing-Jasa order confirmation | Explicit response; 12-hour reminder; 24-hour timeout | Product + operations |
| OD-30 | P0 | Approved for closed beta | Audit-history scope and retention | Append-only sensitive/binding history; exact duration remains P2 | Product + security + privacy/legal |
| OD-31 | P0 | Approved for closed beta | Administrator permission model | Separate least-privilege groups; no self-grant; step-up for high risk | Product + security + operations |
| OD-32 | P2 | Open | Mitra settlement and payout model | Provider-neutral states; all real money disabled until approved | Product + finance + legal + operations |
| OD-33 | P0 | Approved for closed beta | Verification document retention and deletion | No government ID/media collection; production verification remains P2 | Product + privacy/legal + security + operations |
| OD-34 | P0 | Approved for closed beta | Permintaan visibility and Mitra eligibility | Privacy-minimized visitor view, no indexing, eligible authenticated Mitra responses only | Product + privacy + trust & safety + operations |

## Remaining Open Decisions

- **P0:** none.
- **P1 before closed beta:** OD-10 submission approval period; OD-11 automatic completion; OD-12 dispute deadline; OD-14 review/verification expiry; OD-20 support operating model; OD-22 administrator MFA/reauthentication; OD-24 notification channels.
- **P2 before public real-money launch:** OD-04 platform fee; OD-05 production payment method/provider; OD-08 refund rules; OD-32 settlement/payout model; future government-ID verification and its lifecycle under OD-13/OD-33; exact record, audit, backup, and deletion retention durations under OD-28/OD-30/OD-33.
- **P3 after pilot evidence:** OD-25 numeric success thresholds.

## 1. OD-01 — Pilot Launch Geography

| Field | Detail |
|---|---|
| Why it matters | Determines service-area copy, operations coverage, moderation context, and supply acquisition. |
| Available options | A. Surabaya only. B. Surabaya metropolitan area. C. Multiple launch cities. D. Indonesia-wide digital with one local pilot. |
| Recommended option | D: launch digital services nationally where operations permit, with Surabaya as the initial local-service pilot. The locality model must support later Indonesian expansion. |
| Effect on user experience | Visitors see honest availability; local users outside the pilot receive a clear unavailable/request-interest state rather than false coverage. |
| Effect on database and engineering | Requires city/area concepts that are not hard-coded to one city and an eligibility rule for local publishing/search. |
| Risk | Too broad creates unsupported operations; too narrow limits liquidity and learning. |
| Required approval | Product owner and launch operations owner. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Digital services may operate nationally where supported; local services pilot in Surabaya; locality supports later Indonesian expansion; unsupported local areas show honest unavailable or interest states.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Operations must support each enabled area; approval does not claim nationwide local coverage.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 2. OD-02 — One Account as Both Pemesan and Mitra

| Field | Detail |
|---|---|
| Why it matters | Affects onboarding, navigation, permissions, identity, self-dealing controls, and account moderation. |
| Available options | A. Separate customer/provider accounts. B. One account with activatable Mitra profile. C. One account with forced role selection. |
| Recommended option | B: one normal account may act as Pemesan and activate a Mitra profile; administrator remains separate privilege. |
| Effect on user experience | Users keep one identity and can switch workspaces without duplicate registration. |
| Effect on database and engineering | Requires role capabilities on one account and guards against ordering/reviewing oneself. |
| Risk | Permission mistakes can expose Mitra-only or admin-only actions. |
| Required approval | Product owner and security reviewer. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: One normal account may act as Pemesan and activate a Mitra profile; administrator permissions remain separate; self-ordering, self-offering, self-reviewing, and acting on both sides of one Pesanan are prohibited.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Administrator capabilities use OD-31 least-privilege assignments.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 3. OD-03 — Pricing Model

| Field | Detail |
|---|---|
| Why it matters | Controls discovery cards, order creation, offer terms, disputes, and revenue logic. |
| Available options | A. Fixed price only. B. Starting/base price plus clarification. C. Hourly. D. Custom Penawaran only. E. Category-dependent combination. |
| Recommended option | E: existing Jasa supports fixed or clearly defined base price; custom work uses an agreed Penawaran. Hourly pricing is deferred unless a category needs it. |
| Effect on user experience | Users can compare simple services while preserving flexibility for custom tasks. |
| Effect on database and engineering | Product records need a price basis and immutable agreed amount snapshot; no complex bidding. |
| Risk | Ambiguous “starting from” copy may mislead if included scope is unclear. |
| Required approval | Product owner and finance/business owner. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Existing Jasa may use a fixed or clearly defined base price with visible included scope; custom work uses an immutable accepted Penawaran; hourly billing and complex bidding are deferred.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: A base price cannot be shown without its included scope.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 4. OD-04 — Platform Service Fee

| Field | Detail |
|---|---|
| Why it matters | Changes checkout totals, provider earnings, tax/legal review, cancellations, refunds, and public pricing. |
| Available options | A. No fee. B. Percentage paid by Mitra. C. Customer service fee. D. Split fee. E. Fixed fee. |
| Recommended option | No fee during the non-production mock phase. Before real-money public orders, approve one simple, transparent fee model based on unit economics; do not hide it in listed prices. |
| Effect on user experience | Total, fee, and Mitra proceeds must be visible before commitment. |
| Effect on database and engineering | Requires separate agreed price, fee, total, and provider proceeds in transaction records. |
| Risk | Premature fees suppress marketplace liquidity; unclear fees damage trust. |
| Required approval | Product owner, finance, and legal/tax review. |

## 5. OD-05 — Initial Payment Method

| Field | Detail |
|---|---|
| Why it matters | Determines whether Pesanan can represent paid work and which payment claims are truthful. |
| Available options | A. Mock-only closed development. B. Manual bank transfer with admin reconciliation. C. Midtrans Sandbox then production. D. No platform payment at public launch. |
| Recommended option | Use mock provider in development and staging; require Midtrans production readiness before Jasama publicly accepts real-money orders through the platform. |
| Effect on user experience | Development can test states; public users do not encounter a pretend or manually ambiguous protected-payment flow. |
| Effect on database and engineering | Requires provider-neutral payment states now and authenticated callbacks/reconciliation later. |
| Risk | Manual transfer creates support and fraud risk; early public claims may overstate protection. |
| Required approval | Product, finance, engineering, and legal/compliance as applicable. |

## 6. OD-06 — Payment Timing

| Field | Detail |
|---|---|
| Why it matters | Determines when Mitra starts, cancellation exposure, and cash-flow expectations. |
| Available options | A. Before Mitra confirmation. B. After confirmation but before work. C. After completion. D. Deposit plus balance. |
| Recommended option | B: after Mitra confirmation and before work begins. Deposits are deferred. |
| Effect on user experience | Pemesan knows a Mitra accepted before paying; Mitra does not start without the required payment state. |
| Effect on database and engineering | Pesanan needs `pending_confirmation`, `awaiting_payment`, and `ready_to_start` gates. |
| Risk | Confirmation delays conversion; payment-first creates refund burden if Mitra declines. |
| Required approval | Product, finance, and operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Mitra confirmation occurs first; mock payment occurs second when required; work starts only after the required payment state succeeds.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Closed beta uses mock payment only; real payment-provider behavior remains open under OD-05.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 7. OD-07 — Cancellation Rules

| Field | Detail |
|---|---|
| Why it matters | Controls whether work stops, whether consent is required, and how disputes/refunds begin. |
| Available options | A. Either party freely cancels anytime. B. Mutual before/after start. C. State-based unilateral rights. D. Admin decision for every cancellation. |
| Recommended option | C: use the state-based rules below. Cancellation decides whether the Pesanan/work stops; it never decides refund eligibility or amount. Any financial outcome is a separate OD-08 Payment/Payout decision. |
| Before Mitra confirmation | Pemesan may cancel and Mitra may decline without payment. A changed-terms proposal remains unconfirmed and requires explicit Pemesan acceptance under OD-29. |
| After confirmation, before payment | Either party may cancel under the approved pre-work rule; no payment attempt may be created after cancellation. |
| After payment, before work | Either party may request cancellation. The order may stop under OD-07, while any refund, fee, or payout consequence is evaluated separately under OD-08/OD-32. |
| After work starts | Require mutual agreement or administrator review, except an approved urgent safety restriction may stop unsafe work immediately without predetermining financial outcome. |
| After submission | Require mutual agreement or administrator review; preserve submitted delivery/proof and allow dispute routing. Cancellation does not erase reviewable evidence. |
| Active safety or dispute case | Pause ordinary cancellation resolution when it could conflict with a safety hold or dispute remedy; an authorized admin routes the case and records every linked transition. |
| Effect on user experience | The applicable rule and non-financial consequence are shown for the current order state before confirmation; any separate refund status is described without guarantee. |
| Effect on database and engineering | Requires order-state-aware eligibility, cancellation request/response, prior-order-state recovery, reason, correlation to separate financial events, and audit. |
| Risk | Vague rules create inconsistent treatment and refund disputes. |
| Required approval | Product, operations, trust & safety, and legal. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Apply state-based cancellation before confirmation, after confirmation before payment, after payment before work, after work starts, after submission, and during safety/dispute holds as specified above.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Cancellation never silently decides refund or payout outcomes; those remain separate under OD-08 and OD-32.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 8. OD-08 — Refund Rules

| Field | Detail |
|---|---|
| Why it matters | Refunds create financial, legal, support, and reconciliation obligations. |
| Available options | A. No refunds. B. Automatic state-based refunds. C. Manual full refunds. D. Manual full/partial refunds. E. Provider-specific policy. |
| Recommended option | D only after policy approval: manually authorized full or partial outcome tied to cancellation/dispute; no automatic refund in MVP. |
| Effect on user experience | Users see refund status and amount without a guarantee before decision. |
| Effect on database and engineering | Requires refund authorization, amount validation, provider result, failure/retry, and audit. |
| Risk | Unsupported automatic refunds cause loss; no remedy undermines trust. |
| Required approval | Product, finance, legal, and operations. |

## 9. OD-09 — Revision Limits

| Field | Detail |
|---|---|
| Why it matters | Separates correction from unpaid scope expansion and affects completion timing. |
| Available options | A. Unlimited. B. One global revision. C. Category-specific. D. Listing/offer-defined. E. Paid additional revisions. |
| Recommended option | D with category defaults: each accepted listing/offer snapshots its revision allowance; use one included revision as the initial custom-digital default and a proof-correction path for local work. |
| Effect on user experience | Allowance and window are visible before commitment. |
| Effect on database and engineering | Requires revision allowance/window in commercial snapshot and version-linked requests. |
| Risk | One global rule fits local and digital work poorly; unlimited revisions invite abuse. |
| Required approval | Product and operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Snapshot revision allowance from the Jasa or accepted Penawaran; custom digital work defaults to one included revision; local work uses proof correction; additional scope requires a new agreement.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: The allowance and included scope must be visible before commitment.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 10. OD-10 — Submission Approval Period

| Field | Detail |
|---|---|
| Why it matters | Defines how long a submitted result waits for Pemesan action. |
| Available options | A. No deadline. B. 48 hours. C. 72 hours. D. Seven days. E. Category-specific. |
| Recommended option | 72 hours with clear reminders; consider category-specific extensions only after evidence. |
| Effect on user experience | Pemesan has a visible review deadline and Mitra is not left indefinitely pending. |
| Effect on database and engineering | Requires submitted-at timestamp, due time, reminders, and hold conditions for revision/dispute/cancellation. |
| Risk | Too short harms complex review; too long delays completion. |
| Required approval | Product and operations. |

## 11. OD-11 — Automatic Pesanan Completion

| Field | Detail |
|---|---|
| Why it matters | Can close inactive orders and enable reviews, but may appear unfair without policy and reminders. |
| Available options | A. Never auto-complete. B. Auto-complete after OD-10. C. Category-specific. D. Admin manual completion. |
| Recommended option | B only after OD-10 approval: reminders before a 72-hour auto-completion; block it when revision, cancellation, report, or dispute is open. |
| Effect on user experience | Deadline and consequences must be visible at submission and in reminders. |
| Effect on database and engineering | Requires scheduled job, idempotency, hold flags, and audit event. |
| Risk | Premature completion can create disputes and false review eligibility. |
| Required approval | Product, operations, and legal. |

## 12. OD-12 — Dispute Submission Deadline

| Field | Detail |
|---|---|
| Why it matters | Balances evidence freshness, finality, and customer/provider remedy. |
| Available options | A. No deadline. B. Three days. C. Seven days. D. Fourteen days. E. Category/state-specific. |
| Recommended option | Seven calendar days after completion or cancellation, with exceptional safety/fraud reports handled separately. |
| Effect on user experience | Participants see eligibility and deadline without a guaranteed outcome. |
| Effect on database and engineering | Requires eligibility timestamp, deadline checks, and exceptional report routing. |
| Risk | Short deadline excludes legitimate issues; long deadline extends uncertainty. |
| Required approval | Product, operations, trust & safety, and legal. |

## 13. OD-13 — Verification Documents

| Field | Detail |
|---|---|
| Why it matters | Defines what “Identitas terverifikasi” truthfully means and introduces sensitive data handling. |
| Available options | A. Closed-beta contact/profile/portfolio/manual onboarding review without government ID. B. Government ID only. C. ID plus live identity match. D. ID plus bank/account match. E. Third-party verification later. |
| Recommended option | A for closed beta: verify email, phone, profile completeness, portfolio, and manual onboarding eligibility; invitation, referral, or live onboarding may supplement the review. Do not collect government ID or identity-match media and do not display `Identitas terverifikasi`. Preserve government-ID options as deferred future alternatives under OD-33 controls. |
| Effect on user experience | Closed-beta Mitra see clear onboarding requirements and correction paths; the public status is `Profil Mitra diperiksa` or another narrowly truthful equivalent. A future identity-verification label may appear only after the deferred government-ID process and lifecycle controls are approved and operational. |
| Effect on database and engineering | Closed beta requires contact/profile/portfolio review results and audit without government-ID upload/storage. Any future government-ID flow requires separate privacy, storage, access, deletion, backup, audit, legal, and operational approval under OD-33. |
| Risk | Excess collection increases privacy harm; weak checks undermine status. |
| Required approval | Product, privacy/legal, security, and verification operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Verify email, phone, profile completeness, portfolio, and manual onboarding eligibility; invitation, referral, or live onboarding may supplement review; collect no government ID or identity-match media.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Closed-beta public status is `Profil Mitra diperiksa` or a narrowly truthful equivalent; `Identitas terverifikasi` is prohibited. Full government-ID verification remains a deferred P2 alternative under OD-33.
Documents requiring update: DESIGN.md, docs/HOMEPAGE_SHAPE.md, docs/PRD.md, docs/STATE_MACHINES.md
```

## 14. OD-14 — Verification Expiration

| Field | Detail |
|---|---|
| Why it matters | Identity documents and risk status can become stale; renewal adds user and operations burden. |
| Available options | A. Never expires. B. Annual. C. Document-expiry based. D. Risk-triggered only. E. Annual plus risk-triggered. |
| Recommended option | E: annual renewal with advance notice plus risk-triggered review; document expiry may shorten validity. |
| Effect on user experience | Mitra sees expiry date and renewal reminders; losing status does not imply wrongdoing. |
| Effect on database and engineering | Requires validity dates, scheduler, notice sequence, and re-review states. |
| Risk | Silent expiry disrupts income; no expiry leaves stale verification. |
| Required approval | Product, privacy/legal, risk, and operations. |

## 15. OD-15 — Exact-Address Sharing

| Field | Detail |
|---|---|
| Why it matters | Local work needs coordination, but public precise addresses create safety/privacy risk. |
| Available options | A. Share in public request. B. Share after offer acceptance. C. Share after payment. D. Use chat only. E. User-controlled meeting point. |
| Recommended option | Public surfaces show only city, district, or broad area. Share the minimum precise address only with active Pesanan participants after Mitra confirmation and, when payment is required, after payment; earlier feasibility information requires explicit approval. Support neutral meeting points. |
| Effect on user experience | Public pages show only broad area; active participants receive an explicit minimum-address share event at the approved point. |
| Effect on database and engineering | Requires public/private location separation and participant access checks. |
| Risk | Early exposure creates stalking/fraud risk; late sharing may reveal infeasible work. |
| Required approval | Product, privacy/security, and local operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Public surfaces show city, district, or broad area only; share the minimum precise address with active Pesanan participants after Mitra confirmation and after payment when required; support neutral meeting points.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Earlier feasibility information requires explicit approval and must remain less precise than the service address.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 16. OD-16 — Messaging Access Rules

| Field | Detail |
|---|---|
| Why it matters | Messaging enables clarification but can create spam, off-platform solicitation, and moderation burden. |
| Available options | A. Open direct messages. B. Jasa inquiry threads. C. Threads only after Permintaan/Penawaran/Pesanan context. D. Order-only messaging. |
| Recommended option | C: contextual threads tied to Permintaan, Penawaran, or Pesanan; allow a constrained Jasa inquiry only when it creates an explicit intent context. No unsolicited open DMs. |
| Effect on user experience | Every conversation has visible task context and clear report controls. |
| Effect on database and engineering | Requires thread authorization based on object/participant state and access revocation rules. |
| Risk | Too open creates spam; too closed prevents necessary clarification. |
| Required approval | Product and trust & safety. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Messaging is limited to explicit-intent Jasa inquiries and contextual Permintaan, Penawaran, or Pesanan threads; unsolicited open direct messages are prohibited.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Access follows object participation/state and may be revoked by account or safety restrictions.
Documents requiring update: docs/PRD.md
```

## 17. OD-17 — Attachment Limits and Allowed File Types

| Field | Detail |
|---|---|
| Why it matters | Attachments are required for digital work and evidence but introduce malware, privacy, cost, and abuse risk. |
| Available options | A. Images/PDF only. B. Common office/media files. C. Archives allowed. D. Links only. E. Category-specific allowlists. |
| Recommended option | Allow up to five files per message or submission and 10 MB per file: approved image formats, PDF, plain text, CSV, and common office documents. Large audio/video must use an approved access-controlled link rather than direct upload. Block executables, scripts, archives, and password-protected files. |
| Effect on user experience | Validation explains accepted formats and preserves text/draft after upload failure. |
| Effect on database and engineering | Requires an explicit image/PDF/text/CSV/office allowlist, 10 MB size and five-file count validation, approved-link checks for large media, safety scanning, access control, and retention policy. |
| Risk | Broad types increase malware and processing risk; narrow types block legitimate work. |
| Required approval | Product, security, storage/cost owner, and operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Maximum 10 MB per file and five files per message/submission; allowlisted images, PDF, plain text, CSV, and common office formats; large audio/video by approved access-controlled external link; executables, scripts, archives, and password-protected files prohibited.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: File/link validation and safe recovery remain mandatory.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 18. OD-18 — Content Moderation Workflow

| Field | Detail |
|---|---|
| Why it matters | Determines publication delay, policy enforcement, editing, and staffing. |
| Available options | A. Manual pre-publication for all. B. First listing only. C. Post-publication/report-based. D. Risk-based hybrid. |
| Recommended option | A for MVP: manual pre-publication review for each new Jasa and material edit; evolve to risk-based only after evidence. |
| Effect on user experience | Mitra sees review status, reasons, and required changes; no unsupported instant-publication promise. |
| Effect on database and engineering | Requires moderation queue, material-edit detection at product level, version snapshots, and reasons. |
| Risk | Manual queue slows supply; post-only moderation raises safety risk. |
| Required approval | Product, trust & safety, and operations staffing. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Manually review every new Jasa and every material edit before publication; later pause, change, removal, or archive does not rewrite existing Pesanan snapshots.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Moderators change state/reason, not the author's commercial terms.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 19. OD-19 — Provider Suspension Rules

| Field | Detail |
|---|---|
| Why it matters | Restrictions affect livelihood, customer obligations, listings, offers, and ongoing orders. |
| Available options | A. Account-wide suspension only. B. Capability-specific restrictions. C. Warning ladder. D. Immediate permanent ban for all violations. |
| Recommended option | Graduated capability-specific restrictions: warning or limited capability where proportional; immediate suspension for serious safety/fraud risk; explicit reason, review date where applicable, and appeal path. Handle every active Pesanan individually rather than silently cancelling it. |
| Effect on user experience | Affected users understand what is blocked, what remains available, and how ongoing obligations are handled. |
| Effect on database and engineering | Requires scoped restriction states, reason/evidence, duration/review, and appeal handling. |
| Risk | Inconsistent enforcement harms trust; overbroad suspension can strand orders. |
| Required approval | Product, trust & safety, legal, and operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Use proportional warnings or capability limits, immediate suspension for serious fraud/safety risk, explicit reasons, review dates where applicable, and an appeal path; handle active Pesanan individually.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Restrictions never silently cancel active Pesanan.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 20. OD-20 — Customer Support Operating Model

| Field | Detail |
|---|---|
| Why it matters | Verification, moderation, payment failures, reports, and disputes require human ownership and response expectations. |
| Available options | A. Business-hours internal team. B. Extended hours. C. Outsourced support. D. Community/self-service first. E. 24-hour support. |
| Recommended option | Indonesian business-hours support with documented queue priorities and emergency safety escalation; do not claim 24-hour support. |
| Effect on user experience | Help pages state available channels and realistic response expectations. |
| Effect on database and engineering | Requires case ownership, priority, status, and safe communication history at the product level. |
| Risk | Undefined ownership leaves sensitive cases stalled; overpromised hours create false trust. |
| Required approval | Product and operations leadership. |

## 21. OD-21 — MVP Category Taxonomy

| Field | Detail |
|---|---|
| Why it matters | Controls discovery, moderation expertise, forms, filters, analytics, and supply planning. |
| Available options | A. Eight homepage categories are full MVP taxonomy. B. Eight top-level categories plus task tags. C. Launch with broader taxonomy. |
| Recommended option | B: use the approved eight as top-level categories and add controlled task tags; do not label popularity without analytics. |
| Effect on user experience | Simple entry points remain stable while search can express specific work. |
| Effect on database and engineering | Requires stable top-level identifiers and evolvable tags without destructive recategorization. |
| Risk | Too broad reduces relevance; too detailed creates empty categories. |
| Required approval | Product owner. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Use the eight named Lokal/Digital top-level MVP categories plus controlled task tags; do not apply popularity labels without analytics.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Category evolution must preserve existing Jasa and Permintaan discoverability.
Documents requiring update: docs/PRD.md
```

## 22. OD-22 — Administrator Reauthentication and MFA

| Field | Detail |
|---|---|
| Why it matters | Admins access verification documents and perform high-impact actions. |
| Available options | A. Standard login only. B. MFA for all admins. C. MFA plus step-up reauthentication for sensitive actions. |
| Recommended option | C: mandatory MFA and recent reauthentication for document access, bans, verification decisions, refunds, and dispute remedies. |
| Effect on user experience | Admin work has occasional deliberate confirmation; end users gain stronger protection. |
| Effect on database and engineering | Requires admin authentication assurance and sensitive-action checks, without defining implementation architecture here. |
| Risk | Weak controls enable severe account/data harm; excessive prompts slow operations. |
| Required approval | Security owner and product owner. |

## 23. OD-23 — Review Editing, Withdrawal, and Provider Responses

| Field | Detail |
|---|---|
| Why it matters | Changes rating aggregates, moderation, fairness, and conversational risk. |
| Available options | A. Immutable review. B. Edit within window. C. Edit anytime with history. D. Provider response. E. Reviewer withdrawal. |
| Recommended option | One review per completed Pesanan; allow one edit within seven days with a `Diedit` marker and preserved history; allow reviewer withdrawal; defer Mitra public responses from the initial MVP. |
| Effect on user experience | Users can correct mistakes without silently rewriting history. |
| Effect on database and engineering | Requires version history, aggregate recalculation, and withdrawal/moderation states. |
| Risk | Unlimited edits enable retaliation; no correction traps errors. |
| Required approval | Product and trust & safety. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Allow one review per completed Pesanan, one edit within seven days with version history and an edited marker, and reviewer withdrawal; defer Mitra public responses.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Review provenance and moderation history remain preserved.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 24. OD-24 — Notification Channels

| Field | Detail |
|---|---|
| Why it matters | Missed offers, deliveries, disputes, or security events harm completion, while excessive messaging creates spam/privacy issues. |
| Available options | A. In-app only. B. In-app plus email. C. Add WhatsApp/SMS. D. Push notifications later. |
| Recommended option | B: in-app for all material events and email for security or action-critical events; defer WhatsApp/SMS and push. |
| Effect on user experience | Critical actions are less likely to be missed and non-essential marketing remains opt-in. |
| Effect on database and engineering | Requires event/channel preferences, delivery status, deduplication, and minimal-content templates. |
| Risk | Too few channels reduce completion; too many create consent and cost problems. |
| Required approval | Product, operations, and privacy/legal. |

## 25. OD-25 — Numeric MVP Success Thresholds

| Field | Detail |
|---|---|
| Why it matters | Go/no-go decisions need thresholds, but there is no real baseline evidence yet. |
| Available options | A. Set speculative targets now. B. Use industry benchmarks. C. Run closed pilot, then approve thresholds. |
| Recommended option | C: instrument the measures in PRD Section 37, collect a closed-pilot baseline, then approve targets segmented by local/digital. |
| Effect on user experience | Prevents optimizing toward arbitrary numbers or publishing fabricated proof. |
| Effect on database and engineering | Requires trustworthy event definitions, environment and `is_demo` separation, and metric review. |
| Risk | No thresholds weakens decisions; speculative thresholds misdirect product work. |
| Required approval | Product and business owner after baseline review. |

## 26. OD-26 — Permintaan and Penawaran Expiry

| Field | Detail |
|---|---|
| Why it matters | Stale requests/offers mislead users and complicate acceptance races. |
| Available options | A. No expiry. B. Fixed global expiry. C. Request-selected deadline. D. Category-specific. |
| Recommended option | Permintaan expires after 14 calendar days unless owner closes earlier; Penawaran expires with its Permintaan or an explicitly earlier validity date. Remind before expiry. Reopening creates a new valid 14-day expiry window. |
| Effect on user experience | Availability remains current and users can republish intentionally. |
| Effect on database and engineering | Requires expiry timestamps, scheduled transitions, reminders, and safe handling of attempts near expiry. |
| Risk | Short expiry harms low-liquidity categories; no expiry creates stale results. |
| Required approval | Product and operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Permintaan expires after 14 calendar days; Penawaran expires with it or at an explicitly earlier validity date; send reminders before expiry; reopening starts a new 14-day validity window.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Scheduled expiry and reopening are idempotent and preserve history.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 27. OD-27 — Local Proof-of-Completion Standard

| Field | Detail |
|---|---|
| Why it matters | Local work needs evidence appropriate to the task without collecting excessive location or personal data. |
| Available options | A. Photo mandatory. B. Signature/code. C. Notes only. D. Category-dependent photo/document/note. E. GPS proof. |
| Recommended option | D: category-appropriate completion note plus photo/document where appropriate, or explicit Pemesan confirmation. No mandatory GPS and no unnecessary precise-location metadata. |
| Effect on user experience | Mitra knows what evidence is expected; Pemesan can assess it without invasive tracking. |
| Effect on database and engineering | Requires proof-type validation, versioning, private access, and category requirements. |
| Risk | Weak proof complicates disputes; excessive proof harms privacy and usability. |
| Required approval | Product, privacy, local operations, and trust & safety. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Require a completion note plus appropriate photo/document where needed, or explicit Pemesan confirmation; require no GPS and collect no unnecessary precise-location metadata.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Proof requirements remain category-appropriate and privacy-minimized.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 28. OD-28 — Account Deactivation, Deletion, and Retention

| Field | Detail |
|---|---|
| Why it matters | Users need control while Jasama must retain lawful transaction, safety, and audit records. |
| Available options | A. Immediate deletion. B. Reversible deactivation then deletion. C. Indefinite retention. D. Separate schedules by record type. |
| Recommended option | For closed beta, use immediate reversible deactivation: disable the public profile and new marketplace actions while preserving access needed for active obligations and safety cases. Handle irreversible deletion manually until record-specific retention is approved. |
| Effect on user experience | Consequences and retained records are explained before confirmation; reactivation remains possible; Jasama does not promise immediate deletion of transaction, report, dispute, payment, or audit history. |
| Effect on database and engineering | Closed beta requires reversible deactivation and manual deletion handling. Exact record-specific retention/deletion durations remain an open P2 decision before public launch. |
| Risk | Over-retention harms privacy; early deletion breaks disputes/legal duties. |
| Required approval | Product, privacy/legal, security, and finance where transaction retention applies. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Reversible deactivation first; disable public profile and new marketplace actions; retain required access for active obligations/safety cases; handle irreversible deletion manually.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Do not promise immediate deletion of transaction, report, dispute, payment, or audit history. Exact record-specific retention durations remain open at P2 before public launch.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 29. OD-29 — Existing-Jasa Order Confirmation

| Field | Detail |
|---|---|
| Why it matters | A reusable Jasa may not imply instant provider availability; confirmation timing affects payment and cancellation. |
| Available options | A. Instant order. B. Mitra confirms every order. C. Auto-confirm based on availability. D. Category-dependent. |
| Recommended option | B for MVP: Mitra confirms current scope, timing, and availability before payment or work begins. |
| Accept | Mitra explicitly accepts the current immutable Jasa-order snapshot; only then may the order move to payment or directly to ready-to-start when no payment is required. |
| Decline | Mitra may decline with a safe reason; the unconfirmed order closes and no payment attempt is created. |
| Pre-confirmation cancel | Pemesan may cancel while confirmation is pending; the order closes without payment and remains in audit history. |
| No response | Send a reminder after 12 hours. If no acceptance, decline, cancellation, or changed-terms response exists after 24 hours, automatically cancel the unconfirmed order without payment. Use the order timezone and make reminder/timeout execution idempotent. |
| Changed terms | A Mitra-proposed change to scope, timing, or price is not acceptance. Pemesan must explicitly accept a new immutable snapshot; otherwise the order remains unconfirmed or is cancelled. |
| Payment gate | Payment must never be requested, attempted, or marked required before Mitra accepts the current terms and any changed terms are accepted by Pemesan. |
| Effect on user experience | Pemesan avoids paying for unavailable or changed service but sees a clear pending state, response history, and cancellation path. |
| Effect on database and engineering | Requires `pending_confirmation`, explicit accept/decline/cancel events, versioned changed terms, a 12-hour reminder, a 24-hour idempotent timeout in the order timezone, and a hard payment-before-confirmation guard. |
| Risk | Slow response reduces conversion; instant order creates rejection/refund burden. |
| Required approval | Product and marketplace operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Mitra explicitly accepts or declines current immutable terms; Pemesan may cancel before confirmation; changed terms require Pemesan acceptance; payment is blocked before acceptance; remind after 12 hours and auto-cancel without payment after 24 hours of no response.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Use the order timezone; reminder and timeout execution must be idempotent.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 30. OD-30 — Audit-History Scope and Retention

| Field | Detail |
|---|---|
| Why it matters | Trust, disputes, security, and privileged corrections depend on knowing who changed binding state and why. |
| Available options | A. Status history only. B. Sensitive/admin actions only. C. All sensitive and binding transitions. D. Full content history. |
| Recommended option | C: append-only history records actor/trigger, timestamp, previous/next state, reason, affected object and version, correlation/idempotency identifier, and evidence reference when applicable for every sensitive or binding transition. |
| Effect on user experience | Participants can see appropriate order status history; private admin evidence remains restricted. |
| Effect on database and engineering | Requires append-only product history semantics and access controls without logging unnecessary private content. Exact production retention duration remains an open P2 decision before public launch. |
| Risk | Too little history impairs accountability; too much private content increases privacy exposure. |
| Required approval | Product, security, privacy/legal, and operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Append-only history for every sensitive or binding transition records actor/trigger, timestamp, previous/next state, reason, affected object/version, correlation/idempotency identifier, and evidence reference when applicable.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Exact production audit-retention duration remains open at P2 before public launch.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 31. OD-31 — Administrator Permission Model

| Field | Detail |
|---|---|
| Why it matters | Verification, moderation, payments, disputes, and account actions have different sensitivity and conflict risks. |
| Available options | A. One super-admin role. B. Scoped roles by function. C. Scoped roles plus approval for highest-risk actions. |
| Recommended option | C: separate least-privilege permissions for verification/onboarding review, listing/content moderation, customer support, reports/disputes, account moderation, and payment/payout reconciliation. One admin may hold multiple assigned groups but cannot self-grant or bypass audit; binding actions require reasons; high-risk actions require step-up authentication; second approval may be introduced for financial or permanent actions. |
| Effect on user experience | Decisions are safer and more consistent; some cases may take longer. |
| Effect on database and engineering | Requires permission checks, assignment/conflict handling, and audited privileged actions. |
| Risk | One broad role magnifies compromise and insider risk; excessive fragmentation slows small teams. |
| Required approval | Product, security, and operations leadership. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Use least-privilege groups for onboarding review, content moderation, support, reports/disputes, account moderation, and payment/payout reconciliation; one admin may hold multiple assigned groups but cannot self-grant or bypass audit.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Binding actions require reasons; high-risk actions require step-up authentication; second approval may be added for financial/permanent actions.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## 32. OD-32 — Mitra Settlement and Payout Model

| Field | Detail |
|---|---|
| Why it matters | Collecting customer money does not by itself define who receives funds, when Mitra earnings become payable, how fees are deducted, or how failures and disputes are reconciled. |
| Available options | A. No platform settlement/payout. B. Provider-managed marketplace settlement. C. Jasama receives and later pays Mitra. D. Manual bank payouts. E. Category/payment-method hybrid. |
| Recommended option | Model provider-neutral Payout states now, but keep all real-money collection, settlement, and payout disabled until OD-05/OD-32 are approved and production finance/legal/provider controls operate. Do not imply escrow, wallet, or protected funds. |
| Funds receiver | Approval must identify whether the payment provider, Jasama legal entity, or Mitra receives customer funds at each stage and which party is merchant of record. No document may imply Jasama holds funds until this is approved. |
| Earnings eligibility | Define the exact event that creates Mitra earnings—such as verified payment plus completion—and every hold/cancellation condition. Payment success alone must not make payout immediately payable. |
| Payout timing | Define release delay, processing calendar, minimum/maximum timing, and whether local/digital categories differ. No scheduled release is active before approval. |
| Platform fee | OD-04 must define gross amount, fee basis, taxes where applicable, rounding, net Mitra amount, and what happens to fees during refunds/corrections. |
| Payout account verification | Require verified ownership/identity match, access-controlled changes, step-up authentication, change holds, and clear destination display before transfer. |
| Dispute hold | Opening an eligible dispute may hold unpaid earnings only under an approved rule. Resolution explicitly releases, cancels, or adjusts the held payout; the dispute machine never silently edits money history. |
| Failure handling | Preserve failed provider/bank attempt, expose safe recovery, revalidate destination and eligibility, and create a distinct idempotent retry. Never overwrite a failed attempt as paid. |
| Reversal and correction | A paid transfer is immutable. Approved reversal/correction creates a linked adjustment with amount, reason, actor, provider result, and notice; it never rewrites the original payout. |
| Reconciliation | Reconcile order, payment, fee, refund, payout, and provider references; amount/currency/destination mismatches enter a held/manual-review path with least-privilege access and audit. |
| Production versus mock | Development/staging may simulate every state with `is_demo` data and no bank movement. Production rejects mock/demo records and keeps all real-money actions disabled until approval and operational readiness are recorded. |
| Effect on user experience | Mitra sees gross, fee, net, destination summary, eligibility/hold reason, processing status, failure recovery, and corrections without an unsupported payout guarantee. |
| Effect on database and engineering | Requires only the provider-neutral behavioral states in `STATE_MACHINES.md` at this stage; concrete architecture/schema waits for approval of receiver, eligibility, timing, fee, destination, holds, and reconciliation. |
| Risk | Ambiguous fund custody or payout entitlement creates severe legal, accounting, fraud, and trust risk. |
| Required approval | Product, finance, legal/compliance, security, operations, and payment-provider owner. |

## 33. OD-33 — Verification Document Retention and Deletion

| Field | Detail |
|---|---|
| Why it matters | Government IDs and identity-match media are high-risk data; verification cannot be designed safely without an explicit raw-document lifecycle. |
| Available options | A. Retain raw documents for a fixed period. B. Delete raw documents after decision/appeal window and retain a minimized result. C. Use an approved verification provider without Jasama raw storage. D. Closed beta without government ID collection/storage. |
| Recommended option | D for closed beta: do not collect or store government ID or identity-match media. Use the lower-risk OD-13 contact/profile/portfolio/manual onboarding review and the truthful status `Profil Mitra diperiksa` or equivalent. Government-ID verification is a deferred P2 production decision and requires the complete lifecycle below before activation. |
| Raw ID storage | Approval must define whether Jasama stores raw ID/selfie files, encryption and isolation requirements, allowed regions/providers, and the shortest necessary storage period. Raw IDs never belong in ordinary profile/media storage. |
| Access and download | Only assigned verification staff with OD-22/OD-31 controls may view raw evidence. Downloads are disabled by default; any exceptional export requires step-up authentication, purpose, time limit, and audit. |
| Deletion after verification | Define whether raw evidence is deleted immediately after decision or after a short approved correction/appeal window. Deletion must not remove the minimized result, decision reason, or required audit record. |
| Retention schedule | Set separate periods for raw documents, derived verification result/checklist, access logs, decision history, fraud/safety hold evidence, and legal exceptions. Indefinite retention is not the default. |
| Backups | Deletion policy must state backup propagation/expiry, maximum residual period, restoration safeguards, and how a restored backup re-applies deletions. |
| Audit access | Record viewer, purpose, time, case, action, and exceptional download; restrict audit visibility and approve its own retention/redaction. |
| Resubmission | Every resubmission is a new immutable evidence version. Superseded raw files follow the same deletion schedule and cannot be silently reused for a new approval. |
| Account deletion | OD-28 must disclose which raw/derived/audit records are deleted, anonymized, retained by lawful exception, or held for an active safety/dispute case, with later deletion after the hold ends. |
| Closed-beta alternative | Verify email, phone, profile completeness, portfolio, and manual onboarding eligibility; optionally use invitation, referral, or live onboarding. Do not store government ID or identity-match media. The public label is `Profil Mitra diperiksa` or another narrowly truthful equivalent, never `Identitas terverifikasi`. |
| Effect on user experience | Candidates receive clear collection purpose, access limits, retention/deletion timing, resubmission behavior, and the meaning of any public status before upload. |
| Effect on database and engineering | Closed-beta planning proceeds without government-ID storage. Any future production identity-verification architecture/schema waits for approval of storage, access, deletion, backup, audit, resubmission, and account-deletion rules. Exact production retention durations remain P2. |
| Risk | Over-retention, uncontrolled download, misleading beta labels, or incomplete backup deletion can create severe privacy and identity-harm exposure. |
| Required approval | Product, privacy/legal, security, verification operations, and infrastructure/storage owner. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Collect and store no government ID or identity-match media; use OD-13 lower-risk onboarding review and the public status `Profil Mitra diperiksa` or a narrowly truthful equivalent.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Full government-ID verification and its storage/access/deletion/backup/audit lifecycle remain deferred P2 production decisions; exact retention durations also remain P2.
Documents requiring update: DESIGN.md, docs/HOMEPAGE_SHAPE.md, docs/PRD.md, docs/STATE_MACHINES.md
```

## 34. OD-34 — Permintaan Visibility and Mitra Eligibility

| Field | Detail |
|---|---|
| Why it matters | A Permintaan must attract qualified Mitra without exposing customer identity, contact details, precise location, or externally indexable sensitive needs. |
| Available options | A. Authenticated eligible-Mitra visibility only. B. Privacy-minimized visitor view with authenticated eligible-Mitra response. C. Fully public and externally indexable. |
| Recommended option | B for MVP: visitors may view a privacy-minimized published Permintaan, but pages are excluded from external search indexing. Only authenticated Mitra who pass eligibility may open response actions or submit Penawaran. |
| Visitor visibility | A visitor may see the task description, category, fulfillment mode, broad city/area for local work, budget guidance, and requested timing. Sign-in and Mitra eligibility are required to respond. |
| Search indexing | Use `noindex` and exclude Permintaan detail from public sitemaps/structured search feeds for MVP. Reconsider indexing only after privacy, moderation, stale-content removal, and user-consent evidence. |
| Mitra eligibility | Require an active account and Mitra profile; any approved category verification; category permission; local service-area match for local requests; and no account, safety, self-dealing, or moderation restriction. |
| Hidden fields | Hide Pemesan name/identity where not required, profile/contact handles, precise address, private notes, attachments not explicitly public, and any safety-sensitive details from visitors and ineligible Mitra. |
| Visible fields | Show enough to assess fit: task/outcome, category, local/digital mode, broad area for local work, budget guidance, timing, and approved public attachments/constraints. |
| Effect on user experience | Visitors understand the opportunity before signing in; eligible Mitra can evaluate fit; Pemesan sees a preview of exactly what each audience can access. |
| Effect on database and engineering | Requires field-level audience classification, eligibility checks at read/respond boundaries, indexing controls, moderation removal, and audit for privileged access. |
| Risk | Overexposure creates privacy/safety harm; overrestriction reduces marketplace liquidity and makes discovery opaque. |
| Required approval | Product, privacy, trust & safety, security, and marketplace operations. |

```text
Decision status: Approved for closed-beta architecture and implementation planning.
Approved option: Visitors may view privacy-minimized published Permintaan; details are noindex and excluded from public sitemaps; only authenticated eligible Mitra may respond; specified identity/contact/address/private fields remain hidden.
Approved by: Product owner.
Approval date: 2026-07-27
Conditions or limits: Eligibility checks account/Mitra status, category, local service area, restrictions, and self-dealing; only the approved public task fields may be exposed.
Documents requiring update: docs/PRD.md, docs/STATE_MACHINES.md
```

## Approval Record Template

When a decision is approved, append this block beneath it without deleting the original options:

```text
Decision status: Approved | Rejected | Superseded
Approved option:
Approved by:
Approval date:
Conditions or limits:
Documents requiring update:
```
