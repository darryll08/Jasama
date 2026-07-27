# Jasama MVP State Machines

Status: **Closed-beta P0 product decisions approved; remaining P1/P2/P3 policies open**  
Product authority: `PRODUCT.md`  
Product requirements: `docs/PRD.md`  
Open policies: `docs/OPEN_DECISIONS.md`

These state machines define product behavior, not technical architecture or a database schema. State names are stable requirement identifiers; Indonesian labels are user-facing candidates governed visually by `DESIGN.md`.

## Global Transition Rules

1. **Approved for closed beta (OD-30):** every sensitive or binding transition appends actor/trigger, timestamp, previous state, next state, reason, affected object/version, correlation/idempotency identifier, and evidence reference where applicable.
2. A transition is rejected when its source state, actor, preconditions, or validation do not match the table.
3. **Approved for closed beta (OD-31):** administrators use separate least-privilege groups for onboarding review, listing/content moderation, support, reports/disputes, account moderation, and payment/payout reconciliation. They cannot self-grant, bypass audit, or delete/rewrite history; binding actions require reasons and high-risk actions require step-up authentication.
4. Notifications expose only the minimum private information needed by the recipient.
5. Duplicate submissions, scheduled triggers, and payment callbacks must not apply the same transition twice.
6. A terminal state blocks ordinary outgoing transitions; any documented recovery is a privileged exception with audit.
7. Policies marked **approval required** remain unavailable until the linked decision is approved. Closed-beta approvals apply only within their recorded conditions; open real-money, production-verification, and exact-retention behavior remains disabled.
8. Manual MVP transitions require a named administrator decision; “manual” never means unrecorded.

### Table convention

Each transition table supplies:

- **Actor/trigger:** actors allowed to enter the destination state.
- **Preconditions and validation:** required source data and validation.
- **Side effects:** product-visible effects.
- **Notification and audit:** recipient events and required audit event.
- **Timeout/cancellation/recovery:** scheduled, cancellation, exceptional, and recovery behavior.

## 1. Mitra Onboarding and Verification

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `inactive` | Belum diaktifkan | Account has no active Mitra profile. | `draft` | Reversible starting state |
| `draft` | Lengkapi profil Mitra | Onboarding is incomplete and private. | `submitted`, `inactive` | Reversible |
| `submitted` | Menunggu pemeriksaan | Candidate submitted required contact/profile/portfolio/onboarding information. | `under_review`, `withdrawn` | Reversible before review |
| `under_review` | Sedang diperiksa | Authorized admin is reviewing. | `needs_changes`, `verified`, `rejected`, `withdrawn` | Manual MVP |
| `needs_changes` | Perlu diperbaiki | Candidate must correct specified issues. | `submitted`, `withdrawn` | Reversible |
| `verified` | Profil Mitra diperiksa | Closed-beta onboarding eligibility review is approved; this is not a government-ID claim. | `suspended`, `expired`, `inactive` | Active; expiry conditional |
| `rejected` | Verifikasi belum disetujui | Submission failed with reason. | `draft`, `withdrawn` | Reversible if resubmission allowed |
| `expired` | Verifikasi kedaluwarsa | Prior approval is no longer current. | `draft`, `submitted`, `suspended` | Conditional on OD-14 |
| `suspended` | Status Mitra ditangguhkan | Verification use is temporarily blocked. | `under_review`, `verified`, `rejected`, `inactive` | Administrator-only |
| `withdrawn` | Pengajuan dibatalkan | Candidate withdrew onboarding. | `draft`, `inactive` | Reversible |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| `inactive` | `draft` | Account holder | Active normal account; not banned. | Create private Mitra profile shell. | In-app confirmation; `mitra_onboarding_started`. | User may return to `inactive`. |
| `draft`/`needs_changes` | `submitted` | Candidate | Approved OD-13/OD-33 closed-beta fields are complete: verified email/phone, profile, portfolio where applicable, and onboarding information; no government ID or identity-match media. | Lock submitted version for review; enqueue case. | Candidate receipt; admin queue; `verification_submitted`. | Candidate may withdraw until a decision. |
| `draft` | `inactive` | Candidate | No submitted review is active. | Close the private onboarding draft; retain required audit metadata. | Candidate confirmation; `mitra_onboarding_deactivated`. | Can restart at `draft`. |
| `submitted` | `under_review` | Authorized admin | Case unassigned or assigned to actor; no conflict. | Record reviewer and review start. | Candidate status update; `verification_review_started`. | Manual MVP; stalled-case reminders depend on OD-20. |
| `under_review` | `needs_changes` | Authorized admin | Specific correctable deficiencies and safe instructions. | Reopen allowed fields; preserve prior submission. | Candidate action notice; `verification_changes_requested`. | Resubmission timing requires operational policy. |
| `under_review` | `verified` | Authorized onboarding reviewer | Approved OD-13 closed-beta contact/profile/portfolio/onboarding evidence meets the checklist; reason complete. | Enable eligible Mitra actions and the narrowly truthful `Profil Mitra diperiksa` label. | Candidate approval; `verification_approved`. | Do not display `Identitas terverifikasi`; expiry exists only if OD-14 is approved. |
| `under_review` | `rejected` | Authorized admin | Material failure or prohibited case; reason required. | Block verified-only capabilities. | Candidate decision with safe reason; `verification_rejected`. | Resubmission/appeal follows approved support policy. |
| `submitted`/`under_review`/`needs_changes`/`rejected` | `withdrawn` | Candidate | No active order dependency that prevents withdrawal. | Close case; retain audit and required records. | Candidate confirmation; `verification_withdrawn`. | Can restart at `draft`. |
| `verified` | `expired` | Scheduled job or admin | **Approval required OD-14**; verified-at plus approved validity period reached. | Remove current-verification display; restrict gated actions. | Advance notice if approved; `verification_expired`. | Impossible until expiry policy approved. |
| `verified`/`expired` | `suspended` | Authorized admin | Safety, fraud, document, or account concern; reason/evidence required. | Hide verification claim; pause gated publishing/offer actions. | Safe suspension notice; `verification_suspended`. | Manual MVP; restore only after review. |
| `suspended` | `verified`/`rejected` | Authorized admin | Review completed; current evidence supports outcome. | Restore or revoke eligibility. | Decision notice; `verification_suspension_resolved`. | Administrator-only recovery. |
| `verified`/`suspended` | `inactive` | Candidate or authorized admin | No active obligation requires current Mitra capabilities; reason recorded for admin action. | Disable Mitra-only capabilities without deleting history. | Candidate notice; `mitra_profile_deactivated`. | Can restart only through `draft`. |
| `rejected`/`expired`/`withdrawn` | `draft` | Candidate | Resubmission is allowed; prior evidence/version remains preserved under OD-33. | Open a new editable submission version. | Candidate confirmation; `verification_resubmission_started`. | New evidence must be submitted before review. |
| `expired` | `submitted` | Candidate | Renewal information is complete and valid under OD-13/OD-33 without government-ID evidence. | Lock renewal version and enqueue review. | Candidate/admin notice; `verification_renewal_submitted`. | Expiry remains visible until a new approval. |
| `suspended` | `under_review` | Authorized admin | Suspension review is assigned; no conflict. | Reopen evidence review while capabilities remain blocked. | Candidate status; `verification_suspension_review_started`. | Admin-only. |
| `withdrawn` | `inactive` | Candidate | No active obligation prevents deactivation. | Close Mitra onboarding and retain required history. | Candidate confirmation; `verification_withdrawn_deactivated`. | Can restart at `draft`. |

**Control classification**

- Impossible: `draft → verified`, `rejected → verified`, public self-approval, government-ID/media collection in closed beta, or displaying `Identitas terverifikasi` for the closed-beta review.
- Terminal: none absolutely; `withdrawn` and `rejected` can restart only under approved resubmission policy.
- Reversible: `draft`, `needs_changes`, `withdrawn`; `suspended` only through admin review.
- Administrator-only: entering/exiting `under_review`, `verified`, `rejected`, `suspended`.
- Scheduled: `verified → expired` only after OD-14 approval.
- Manual MVP: contact/profile/portfolio/onboarding review, change request, rejection, suspension, restoration.

## 2. Jasa Listing and Moderation

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `draft` | Draf | Private editable listing. | `submitted`, `archived` | Reversible |
| `submitted` | Menunggu moderasi | Submitted snapshot awaits review. | `under_review`, `withdrawn` | Reversible before review |
| `under_review` | Sedang ditinjau | Moderator is reviewing. | `changes_requested`, `published`, `rejected` | Manual MVP |
| `changes_requested` | Perlu diperbaiki | Author must address specified issues. | `submitted`, `archived` | Reversible |
| `published` | Tayang | Public and orderable if Mitra is eligible. | `paused`, `under_review`, `removed`, `archived` | Active |
| `paused` | Dijeda | Hidden from new orders by Mitra/admin. | `published`, `under_review`, `archived`, `removed` | Reversible |
| `rejected` | Tidak disetujui | Moderation rejected current submission. | `draft`, `archived` | Reversible if allowed |
| `removed` | Dihapus dari publik | Admin removed a published listing for policy/safety. | `under_review`, `archived` | Administrator-only |
| `archived` | Diarsipkan | Closed to new activity; history retained. | `draft` | Terminal for current version |
| `withdrawn` | Pengajuan ditarik | Author withdrew submitted version. | `draft`, `archived` | Reversible |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| `draft`/`changes_requested` | `submitted` | Mitra author | Required scope/exclusions, category, mode, fixed or clearly defined base price with visible included scope under approved OD-03, media, area/delivery, and policy validation. | Lock version; enqueue moderation. | Author receipt; queue event; `jasa_submitted`. | Hourly billing/complex bidding are unavailable; author can withdraw before review. |
| `submitted` | `under_review` | Authorized moderator | Assignment and permission valid. | Mark reviewer. | Optional status update; `jasa_review_started`. | Manual MVP. |
| `under_review` | `changes_requested` | Moderator | Correctable reason and fields identified. | Reopen editable copy; preserve reviewed version. | Author action notice; `jasa_changes_requested`. | No auto-reject without approved policy. |
| `under_review` | `published` | Moderator | Content, price basis, mode, privacy, and policy pass. | Make listing discoverable/orderable subject to Mitra eligibility. | Author approval; `jasa_published`. | No timeout. |
| `under_review` | `rejected` | Moderator | Material policy or quality failure; reason required. | Block publication. | Safe reason; `jasa_rejected`. | Appeal/resubmit follows OD-18. |
| `published` | `paused` | Author or moderator | No attempt to cancel existing Pesanan. | Hide from new discovery/orders; retain snapshots. | Author confirmation; `jasa_paused`. | Reversible. |
| `paused` | `published` | Author or moderator | Mitra/listing eligibility current; unchanged content still approved. | Restore discovery. | Author confirmation; `jasa_resumed`. | Every material edit requires pre-publication review under approved OD-18. |
| `published`/`paused` | `under_review` | Moderator | Report, material edit, or periodic review. | Hide a material edit from publication until approved; preserve existing Pesanan snapshots. | Author notice; `jasa_reopened_for_review`. | Manual MVP under approved OD-18. |
| `published`/`paused` | `removed` | Authorized moderator | Policy/safety basis; evidence and reason. | Remove public access and new orders; retain existing order snapshots. | Author decision; `jasa_removed`. | Admin-only recovery to review. |
| `submitted` | `withdrawn` | Mitra author | Review has not started. | Remove the submitted version from the moderation queue; preserve history. | Author confirmation; `jasa_withdrawn`. | Can reopen as `draft`. |
| `draft`/`changes_requested`/`published`/`paused`/`rejected`/`removed`/`withdrawn` | `archived` | Author or moderator | No effect on existing Pesanan. | Close listing to new activity. | Confirmation; `jasa_archived`. | Restore by creating/reviewing a new active version. |
| `rejected`/`withdrawn`/`archived` | `draft` | Mitra author | A new editable version is allowed; prior moderation history remains immutable. | Create or reopen a private draft version. | Author confirmation; `jasa_draft_reopened`. | Publication still requires moderation. |
| `removed` | `under_review` | Authorized moderator | Appeal, correction, or new evidence justifies review; reason required. | Keep listing hidden and reopen moderation. | Author status notice; `jasa_removal_review_started`. | Admin-only; cannot restore directly to `published`. |

**Control classification**

- Impossible: `draft → published`, `rejected → published`, `removed → published` without review.
- Terminal: `archived` for the current published version.
- Reversible: `paused`, `changes_requested`, `withdrawn`.
- Administrator-only: `removed`; moderation outcomes.
- Scheduled/webhook: none required.
- Manual MVP: all moderation and removal decisions.

## 3. Custom Permintaan

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `draft` | Draf | Private, editable request. | `published`, `cancelled` | Reversible |
| `published` | Menerima Penawaran | Visible under OD-34; only authenticated eligible Mitra may respond. | `offer_selected`, `closed`, `cancelled`, `expired`, `removed` | Active |
| `offer_selected` | Penawaran dipilih | One Penawaran is accepted; conversion pending. | `converted`, `published`, `cancelled` | Binding/recovery limited |
| `converted` | Menjadi Pesanan | Accepted offer produced a Pesanan. | None | Terminal |
| `closed` | Ditutup | Owner stopped receiving offers without selection. | `published` | Reversible if policy allows |
| `expired` | Kedaluwarsa | Approved response period ended. | `published`, `closed` | Scheduled; OD-26 |
| `cancelled` | Dibatalkan | Owner cancelled request. | None | Terminal |
| `removed` | Dihapus | Moderator removed policy-violating request. | `published`, `closed` | Administrator-only recovery |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| `draft` | `published` | Pemesan | Required task, category, mode, timing, budget guidance, safe area, policy; no identity, contact, or precise public address. | Apply approved OD-34 visibility; only authenticated Mitra passing account, Mitra status, category, location, restriction, and self-dealing eligibility may respond. | Owner confirmation; `request_published`. | Approved OD-26 expiry is 14 calendar days. |
| `published` | `offer_selected` | Owner | Offer still valid; no other selected offer; actor is owner. | Lock request edits; close acceptance race. | Selected and nonselected Mitra notices; `offer_selected_for_request`. | If conversion fails, audited recovery to `published`. |
| `offer_selected` | `converted` | System | Pesanan created with immutable offer/request snapshot. | Close other offers; link Pesanan. | Both parties; `request_converted_to_order`. | Retry safely if creation temporarily fails. |
| `offer_selected` | `published` | System/admin recovery | Pesanan creation failed and no order exists. | Reopen offers; preserve failed attempt audit. | Owner/selected Mitra; `request_conversion_recovered`. | Exceptional recovery only. |
| `published` | `closed` | Owner | No active conversion. | Stop new offers; close submitted offers. | Participants; `request_closed`. | Reopening creates a new 14-day validity window under approved OD-26. |
| `published` | `expired` | Scheduled job | Fourteen calendar days elapsed; no selected offer; scheduled execution is idempotent. | Stop new offers. | Owner and active offer authors; `request_expired`. | Send approved reminder before expiry; duplicate execution is a no-op. |
| `draft`/`published` | `cancelled` | Owner | No accepted/converted offer. | Stop offers; retain audit. | Active offer authors; `request_cancelled`. | Terminal; new need requires new/reopened request per policy. |
| `published` | `removed` | Moderator | Policy violation; reason/evidence. | Hide request and stop offers. | Owner and affected offer authors; `request_removed`. | Admin may restore only after review. |
| `offer_selected` | `cancelled` | Owner or system/admin | No Pesanan exists; cancellation is consistent with the selected Penawaran recovery state. | Release selection and close the request; retain all offer history. | Owner and offer authors; `request_selection_cancelled`. | Exceptional pre-conversion cancellation only. |
| `closed`/`expired` | `published` | Owner | Request is still safe/current and has no active conversion. | Reopen a new 14-day offer window and re-evaluate Mitra eligibility. | Owner and prior participants; `request_reopened`. | Reopening records a new expiry timestamp idempotently under approved OD-26. |
| `expired` | `closed` | Owner or scheduled policy | Owner declines to reopen or approved grace period ends. | Keep request unavailable for new offers. | Owner confirmation; `request_expiry_closed`. | Can reopen only through the explicit `closed → published` path. |
| `removed` | `published` | Authorized moderator | Review confirms the request is safe and current; reason required; OD-34 visibility rules pass. | Restore approved visibility and eligible responses. | Owner and affected offer authors; `request_restored`. | Admin-only recovery. |
| `removed` | `closed` | Authorized moderator | Review is complete but request should not resume receiving offers. | Close moderation case and keep request unavailable. | Owner; `request_removed_closed`. | Owner may reopen only if policy permits. |

**Control classification**

- Impossible: selecting two offers, editing scope after selection, `cancelled → converted`.
- Terminal: `converted`, `cancelled`.
- Reversible: `closed`, `expired`, and `removed` only through allowed review.
- Administrator-only: `removed` and recovery from failed conversion when system cannot.
- Scheduled: expiry under OD-26.
- Manual MVP: moderation and exceptional recovery.

## 4. Penawaran

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `draft` | Draf Penawaran | Private editable proposal. | `submitted`, `withdrawn` | Reversible |
| `submitted` | Menunggu keputusan | Visible to Permintaan owner. | `replaced`, `accepted`, `rejected`, `withdrawn`, `expired` | Active |
| `replaced` | Diperbarui | Superseded version retained in history. | None | Terminal version |
| `accepted` | Diterima | Selected for order conversion. | `converted`, `acceptance_failed` | Binding |
| `converted` | Menjadi Pesanan | Offer snapshot is attached to Pesanan. | None | Terminal |
| `rejected` | Tidak dipilih | Owner rejected the offer. | None | Terminal |
| `withdrawn` | Ditarik | Mitra withdrew before acceptance. | None | Terminal |
| `expired` | Kedaluwarsa | Offer validity ended. | None | Terminal |
| `acceptance_failed` | Penerimaan gagal | Conversion failed without a Pesanan. | `submitted`, `withdrawn` | Recovery state |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| `draft` | `submitted` | Mitra author | Eligible request/Mitra; scope, price, timing, assumptions valid; no self-offer. | Lock version; show to owner. | Owner notice; `offer_submitted`. | Can withdraw or replace before acceptance. |
| `submitted` | `replaced` | Mitra author | Clarification requires changed terms; request still open. | Preserve old version; create new submitted version. | Owner notice; `offer_replaced`. | Old version terminal. |
| `submitted` | `accepted` | Request owner | Offer/request active; no competing acceptance; terms confirmed. | Lock offer; reserve conversion. | Both parties; `offer_accepted`. | Conversion must be idempotent. |
| `accepted` | `converted` | System | Pesanan creation succeeds. | Close competing offers. | Both parties; `offer_converted`. | Retry temporary failure. |
| `accepted` | `acceptance_failed` | System/admin recovery | No Pesanan exists; conversion irrecoverably failed. | Release request selection safely. | Both parties; `offer_acceptance_failed`. | Can restore to submitted only with consistent request state. |
| `submitted` | `rejected` | Request owner, or system after a competing offer converts | Request remains open/closing, or one different offer created the Pesanan under the same correlated acceptance event. | Close offer without affecting the accepted offer. | Mitra notice; `offer_rejected`. | Terminal; synchronized competing-offer closure is idempotent. |
| `draft`/`submitted` | `withdrawn` | Mitra author | Not accepted. | Hide from selection; retain history. | Owner notice if submitted; `offer_withdrawn`. | Terminal. |
| `submitted` | `expired` | Scheduled job | Permintaan expires or an explicitly earlier offer-validity time elapses under approved OD-26. | Prevent acceptance. | Both parties; `offer_expired`. | Reminder follows the owning request/offer policy; duplicate execution is a no-op. |
| `acceptance_failed` | `submitted` | System/admin recovery | No Pesanan exists; request is `published`; offer terms remain current. | Restore offer eligibility and release failed acceptance lock. | Both parties; `offer_acceptance_retried`. | Idempotent exceptional recovery. |
| `acceptance_failed` | `withdrawn` | Mitra author or admin recovery | No Pesanan exists and the failed offer must not be selectable. | Close the failed offer while preserving the acceptance attempt. | Both parties; `offer_acceptance_withdrawn`. | Terminal. |

**Control classification**

- Impossible: accepting withdrawn/rejected/expired offer, author accepting own offer, editing an accepted version.
- Terminal: `replaced`, `converted`, `rejected`, `withdrawn`, `expired`.
- Reversible: only `acceptance_failed` through audited recovery.
- Administrator-only: exceptional recovery; admins do not accept offers for users.
- Scheduled: expiry under OD-26.
- Manual MVP: no ordinary manual admin transition.

## 5. Pesanan

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `pending_confirmation` | Menunggu konfirmasi Mitra | Existing-Jasa order awaits provider confirmation. | `pending_confirmation`, `awaiting_payment`, `ready_to_start`, `cancelled` | OD-29 |
| `awaiting_payment` | Menunggu pembayaran | Agreed order waits for required payment result. | `ready_to_start`, `cancelled` | Payment-dependent |
| `ready_to_start` | Siap dimulai | Terms/payment conditions are satisfied. | `in_progress`, `cancellation_pending`, `cancelled` | Active |
| `in_progress` | Sedang dikerjakan | Mitra is executing work. | `submitted`, `cancellation_pending` | Active |
| `submitted` | Hasil dikirim | Delivery/proof awaits Pemesan action. | `revision_in_progress`, `completed`, `cancellation_pending` | Review window |
| `revision_in_progress` | Sedang direvisi | Approved revision work is active. | `submitted`, `cancellation_pending` | Active |
| `cancellation_pending` | Pembatalan diajukan | Cancellation workflow is unresolved. | prior active state, `cancelled` | Conditional OD-07 |
| `completed` | Selesai | Work accepted or completed under approved policy. | None | Terminal |
| `cancelled` | Dibatalkan | Order ended under cancellation policy. | None | Terminal |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| Creation | `pending_confirmation` | System | Existing Jasa order has the current immutable terms snapshot under approved OD-29. | Create order/history and schedule one 12-hour reminder plus one 24-hour timeout in the order timezone. | Both parties; `order_created`. | Scheduled commands are idempotent. |
| `pending_confirmation` | `pending_confirmation` | Mitra then Pemesan | Mitra proposes changed scope, timing, or price; Pemesan explicitly accepts a new immutable terms snapshot. | Replace only the pending commercial version, restart the 12/24-hour confirmation schedule in the order timezone, and keep payment disabled until acceptance. | Both parties; `order_confirmation_terms_changed`. | No silent term change; stale scheduled commands are no-ops. |
| Creation/`pending_confirmation` | `awaiting_payment` | System/Mitra | Valid accepted Penawaran, or Mitra accepted the current existing-Jasa terms; approved OD-06 requires payment before start. | Create/associate a mock payment attempt only after confirmation in closed beta. | Pemesan action notice; `order_awaiting_payment`. | Payment expiry may cancel only under OD-07. |
| Creation/`pending_confirmation` | `ready_to_start` | System/Mitra | Valid accepted Penawaran, or Mitra accepted the current existing-Jasa terms; no prepayment required. | Enable start. | Both parties; `order_ready`. | No automatic start. |
| `pending_confirmation` | `cancelled` | Pemesan | Pemesan cancels before Mitra confirmation. | Close the unconfirmed order without creating a payment attempt. | Both parties; `order_cancelled_before_confirmation`. | Immediate pre-confirmation exit; OD-07 records the policy basis. |
| `pending_confirmation` | `cancelled` | Mitra | Mitra declines the current terms or availability. | Close the unconfirmed order without creating a payment attempt. | Both parties; `order_confirmation_declined`. | Pemesan may return to discovery or create a Permintaan. |
| `pending_confirmation` | `cancelled` | Scheduled job | Twenty-four hours elapsed in the order timezone with no acceptance, decline, Pemesan cancellation, or changed-terms response; command key/version is current. | Close the unconfirmed order without payment. | Both parties; `order_confirmation_expired`; a reminder was sent after 12 hours. | Idempotent: duplicates and stale-version jobs are no-ops. |
| `awaiting_payment` | `ready_to_start` | Authenticated payment webhook/mock adapter | Payment is `paid`; amount/order match; callback valid. | Enable start. | Both parties; `order_payment_satisfied`. | Webhook-triggered in integration phase. |
| `ready_to_start` | `in_progress` | Assigned Mitra | Start permitted; account/listing not blocked. | Record start time; activate work execution. | Pemesan; `order_started`. | No automatic start. |
| `in_progress`/`revision_in_progress` | `submitted` | Assigned Mitra | Valid delivery/proof version submitted. | Start approval period; expose submission. | Pemesan; `order_submitted`. | Approval period OD-10; autocomplete OD-11. |
| `submitted` | `revision_in_progress` | Pemesan | Valid revision request under OD-09. | Open revision state; link request to version. | Mitra; `order_revision_started`. | Limit/window not active until approved. |
| `submitted` | `completed` | Pemesan | Submission reviewed and accepted. | Close normal work; enable review. | Both parties; `order_completed_by_customer`. | Terminal. |
| `submitted` | `completed` | Scheduled job | **Approval required OD-10/OD-11**; review period elapsed and auto-completion approved; no dispute/revision/cancellation. | Complete and enable review. | Advance/reminder/final notices; `order_auto_completed`. | Scheduled; impossible until both policies approved. |
| `ready_to_start`/`in_progress`/`submitted`/`revision_in_progress` | `cancellation_pending` | Participant | Cancellation allowed under OD-07; reason present. | Pause conflicting completion actions. | Other party/admin as needed; `order_cancellation_requested`. | Cancellation machine controls resolution. |
| `cancellation_pending` | prior active state | System/admin | Cancellation denied/withdrawn. | Resume prior work state. | Both parties; `order_cancellation_resolved_continue`. | Audited recovery. |
| `pending_confirmation`/`awaiting_payment`/`ready_to_start`/`cancellation_pending` | `cancelled` | System/admin | Cancellation approved/executed under OD-07. Any refund eligibility or amount is decided separately under OD-08, not by this transition. | Stop work; close ordinary actions; link but do not determine any Payment/Payout consequence. | Both parties; `order_cancelled`. | Financial side effects may remain separately pending. |

**Approved OD-29 scheduled behavior:** while the current terms version remains `pending_confirmation`, emit `order_confirmation_reminder` once after 12 hours and execute the documented `pending_confirmation → cancelled` transition once after 24 hours. Both schedules use the order timezone and an idempotency key containing the order, terms version, and scheduled action; acceptance, decline, cancellation, or a newer terms version makes stale jobs no-ops.

**Control classification**

- Impossible: start before required payment, complete without submission, revise after completion, self-dealing, or move a terminal order back to active.
- Terminal: `completed`, `cancelled`. Reports/disputes are related state machines and do not silently reopen Pesanan.
- Reversible: `cancellation_pending` only to its recorded prior state.
- Administrator-only: contested cancellation resolution and exceptional correction.
- Payment webhook: `awaiting_payment → ready_to_start`.
- Scheduled: approved OD-29 reminder after 12 hours and no-response cancellation after 24 hours; auto-completion only after OD-10/OD-11 approval.
- Manual MVP: explicit provider confirmation/decline under OD-29; cancellation/dispute interventions.

## 6. Payment

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `not_required` | Tidak memerlukan pembayaran sistem | Approved flow has no provider-managed attempt. | None | Terminal |
| `pending` | Menunggu pembayaran | Attempt exists without final result. | `paid`, `failed`, `expired`, `cancelled` | Active |
| `paid` | Pembayaran tercatat | Provider/mock reports successful agreed amount. | `refund_pending` | Binding |
| `failed` | Pembayaran gagal | Attempt failed. | `pending`, `cancelled` | Reversible via new attempt |
| `expired` | Pembayaran kedaluwarsa | Attempt passed provider expiry. | `pending`, `cancelled` | Reversible via new attempt |
| `cancelled` | Pembayaran dibatalkan | Attempt closed without payment. | None | Terminal attempt |
| `refund_pending` | Pengembalian diproses | Approved refund has been requested. | `refunded`, `partially_refunded`, `refund_failed` | OD-08 |
| `refunded` | Dana dikembalikan | Approved full refund completed. | None | Terminal |
| `partially_refunded` | Sebagian dana dikembalikan | Approved partial refund completed. | `refund_pending` | Conditional OD-08 |
| `refund_failed` | Pengembalian gagal | Provider could not complete refund. | `refund_pending` | Recovery |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| Creation | `pending` | Audited mock adapter for closed beta; future provider adapter | OD-06 confirmation gate passed; amount/currency/order valid. Real provider creation remains disabled under open OD-05. | Create attempt/reference. | Pemesan; `payment_pending`. | Mock-only in closed beta; provider expiry may schedule transition later. |
| `pending` | `paid` | Authenticated webhook or audited mock adapter | Signature/test authority, amount, order, idempotency valid. | Mark payment condition satisfied. | Both parties; `payment_paid`. | Webhook in Midtrans phase; mock callback in development. |
| `pending` | `failed` | Authenticated callback/mock | Provider failure code mapped safely. | Keep order unpaid. | Pemesan recovery; `payment_failed`. | User may create new attempt. |
| `pending` | `expired` | Provider callback or scheduled reconciliation | Expiry reached; no success recorded. | Close attempt. | Pemesan; `payment_expired`. | Scheduled reconciliation when callback absent. |
| `pending` | `cancelled` | User/system | Provider permits cancellation; no paid result. | Close attempt. | Pemesan; `payment_cancelled`. | Cannot override later valid paid webhook without reconciliation. |
| `paid` | `refund_pending` | Authorized admin/system | **Approval required OD-08**; refund outcome approved; amount valid. | Submit refund request. | Both parties; `refund_requested`. | Manual MVP approval; provider callback later. |
| `refund_pending` | `refunded`/`partially_refunded` | Authenticated webhook/mock | Provider result and amount match approved refund. | Record final returned amount. | Both parties; `refund_completed`. | Partial path unavailable unless OD-08 approves it. |
| `refund_pending` | `refund_failed` | Authenticated webhook/mock | Failure result valid. | Flag reconciliation/support action. | Pemesan/admin; `refund_failed`. | Manual retry/reconciliation. |
| `failed`/`expired` | `pending` | Pemesan/system | A new provider attempt is permitted; amount/order remain valid; prior attempt stays immutable. | Create and link a distinct payment attempt. | Pemesan; `payment_retry_started`. | Idempotency prevents duplicate attempts. |
| `failed`/`expired` | `cancelled` | Pemesan/system | No successful result exists and the attempt should be closed. | Prevent further callbacks from changing the attempt without reconciliation. | Pemesan; `payment_attempt_closed`. | A later valid success callback requires admin reconciliation. |
| `partially_refunded`/`refund_failed` | `refund_pending` | Authorized admin/system | OD-08 separately authorizes a remaining or retried refund amount; cumulative amount stays within paid amount. | Create a new idempotent refund attempt. | Both parties; `refund_retry_started`. | Provider callback or manual reconciliation completes it. |

**Control classification**

- Impossible: user-set `paid`, refund before `paid`, refund above recorded paid amount, terminal attempt to `paid` without reconciliation.
- Terminal: `not_required`, `cancelled`, `refunded`; `partially_refunded` may allow another approved refund.
- Reversible: `failed`, `expired`, `refund_failed` via new/retry attempt.
- Administrator-only: refund authorization and reconciliation.
- Payment webhook: success/failure/refund result transitions.
- Scheduled: pending expiry and reconciliation.
- Manual MVP: mock provider controls results; refund policy/action waits for OD-08.

## 7. Work Execution

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `not_ready` | Belum siap dimulai | Order conditions are incomplete. | `ready`, `stopped` | Starting |
| `ready` | Siap dikerjakan | Work may start. | `in_progress`, `stopped` | Active |
| `in_progress` | Sedang dikerjakan | Mitra is actively working. | `blocked`, `submitted`, `stopped` | Active |
| `blocked` | Pekerjaan terhambat | Work needs participant action or clarification. | `in_progress`, `stopped` | Reversible |
| `submitted` | Hasil dikirim | Current execution version was submitted. | `revision`, `done`, `stopped` | Review |
| `revision` | Sedang direvisi | Work resumed for approved revision. | `blocked`, `submitted`, `stopped` | Active |
| `done` | Pekerjaan selesai | Execution ended successfully. | None | Terminal |
| `stopped` | Pekerjaan dihentikan | Cancellation/moderation ended execution. | None | Terminal |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| `not_ready` | `ready` | System | Pesanan is `ready_to_start`. | Enable Mitra start. | Mitra action notice; `work_ready`. | No auto-start. |
| `ready` | `in_progress` | Assigned Mitra | Order eligible; actor assigned. | Record start. | Pemesan; `work_started`. | Manual Mitra action. |
| `in_progress`/`revision` | `blocked` | Participant | Specific missing input/safety blocker; reason. | Surface required action without changing scope. | Other party; `work_blocked`. | Reminders depend on OD-20/OD-24. |
| `blocked` | `in_progress` | Responsible participant/system | Required input received or blocker resolved. | Resume work. | Both parties; `work_resumed`. | Manual. |
| `in_progress`/`revision` | `submitted` | Assigned Mitra | Valid delivery/proof submitted. | Freeze current execution version. | Pemesan; `work_submitted`. | Review timing OD-10. |
| `submitted` | `revision` | System | Valid revision request accepted under OD-09. | Reopen work against referenced version. | Mitra; `work_revision_opened`. | Conditional limits. |
| `submitted` | `done` | System | Pesanan completed. | Close execution. | Both parties; `work_done`. | Terminal. |
| `not_ready`/`ready`/`in_progress`/`blocked`/`submitted`/`revision` | `stopped` | System/admin | Pesanan cancelled or policy action stops work. | Disable new submission. | Both parties; `work_stopped`. | Recovery requires a new/continued Pesanan policy; not ordinary reversal. |

**Control classification**

- Impossible: submit before start, revise without a valid request, participant change on unassigned order.
- Terminal: `done`, `stopped`.
- Reversible: `blocked`.
- Administrator-only: policy-forced stop.
- Scheduled/webhook: none directly; mirrors Pesanan/payment conditions.
- Manual MVP: blocker resolution and execution actions.

## 8. Digital Delivery

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `none` | Belum ada pengiriman | No delivery draft exists. | `draft` | Starting |
| `draft` | Draf pengiriman | Mitra is preparing files/links/notes. | `processing`, `submitted`, `cancelled` | Reversible |
| `processing` | File sedang diperiksa | Upload or safety processing is running. | `submitted`, `failed` | Transient |
| `failed` | Pengiriman gagal | Validation or upload failed. | `draft`, `processing` | Recovery |
| `submitted` | Hasil digital dikirim | Immutable version is visible to Pemesan. | `accepted`, `superseded`, `disputed` | Binding version |
| `superseded` | Digantikan versi baru | Later revision replaced this version. | None | Terminal version |
| `accepted` | Hasil diterima | Pemesan accepted this version. | None | Terminal |
| `disputed` | Hasil diperselisihkan | Version is referenced by an active dispute. | `accepted`, `superseded` | Admin-mediated |
| `cancelled` | Draf dibatalkan | Unsubmitted draft closed. | None | Terminal draft |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| `none` | `draft` | Assigned Mitra | Digital Pesanan in active work state. | Create private version draft. | None; `digital_delivery_draft_started`. | Draft can be cancelled. |
| `draft` | `processing` | Mitra/system | Approved OD-17: each direct file is at most 10 MB; no more than five files per submission; type is allowlisted image/PDF/plain text/CSV/common office; large audio/video uses an approved access-controlled link; no executable, script, archive, or password-protected file. | Run upload/link/safety checks. | Progress/error UI; `digital_delivery_processing`. | Failed processing recovers to draft. |
| `draft`/`processing` | `submitted` | Mitra/system | Required notes/file/link valid and accessible. | Freeze version; update order submission. | Pemesan; `digital_delivery_submitted`. | No silent replacement after submission. |
| `processing` | `failed` | System | Upload, scan, link, or validation failure. | Preserve safe draft data. | Mitra recovery notice; `digital_delivery_failed`. | Retry. |
| `submitted` | `accepted` | Pemesan/system | Pesanan completed by approved manual/auto path. | Mark accepted version. | Mitra; `digital_delivery_accepted`. | Auto path conditional OD-10/OD-11. |
| `submitted` | `superseded` | System | Valid revision produced a newer submitted version. | Preserve prior version for history. | Participants; `digital_delivery_superseded`. | Terminal version. |
| `submitted` | `disputed` | System/admin | Eligible dispute references version. | Preserve evidence and restrict deletion. | Participants/admin; `digital_delivery_disputed`. | Dispute outcome controls recovery. |
| `draft` | `cancelled` | Assigned Mitra | Draft has not been submitted and no required evidence hold applies. | Close the private draft without affecting earlier submitted versions. | Mitra confirmation; `digital_delivery_draft_cancelled`. | Terminal draft. |
| `failed` | `draft` | Assigned Mitra | Safe draft inputs remain available. | Reopen editing and preserve the failure reason. | Mitra recovery; `digital_delivery_retry_draft`. | Manual retry. |
| `failed` | `processing` | Assigned Mitra/system | Corrected file/link is present and retry validation passes. | Restart upload or safety processing. | Progress UI; `digital_delivery_processing_retried`. | Idempotent retry. |
| `disputed` | `accepted`/`superseded` | System/admin | Dispute decision is final and explicitly identifies the version outcome. | Release evidence hold only under retention policy; synchronize order state. | Participants; `digital_delivery_dispute_resolved`. | Admin-mediated recovery. |

**Control classification**

- Impossible: unassigned submission, editing submitted version, acceptance before submission.
- Terminal: `accepted`, `superseded`, `cancelled`.
- Reversible: `failed`; `disputed` only via dispute result.
- Administrator-only: evidence preservation/exceptional dispute resolution.
- Scheduled: acceptance only through approved Pesanan auto-completion.
- Manual MVP: user submission/acceptance and dispute review.

## 9. Local Proof of Completion

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `none` | Belum ada bukti | No proof draft exists. | `draft` | Starting |
| `draft` | Draf bukti | Mitra prepares allowed proof and notes. | `submitted`, `failed`, `cancelled` | Reversible |
| `failed` | Bukti gagal dikirim | Validation/upload failed. | `draft` | Recovery |
| `submitted` | Bukti dikirim | Immutable proof version awaits review. | `accepted`, `superseded`, `disputed` | Binding version |
| `superseded` | Digantikan bukti baru | New revision proof replaced version. | None | Terminal version |
| `accepted` | Bukti diterima | Pemesan accepted completion. | None | Terminal |
| `disputed` | Bukti diperselisihkan | Proof is held for dispute review. | `accepted`, `superseded` | Admin-mediated |
| `cancelled` | Draf dibatalkan | Unsubmitted proof closed. | None | Terminal draft |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| `none` | `draft` | Assigned Mitra | Local Pesanan active. | Create private proof draft. | None; `local_proof_draft_started`. | Draft can be cancelled. |
| `draft` | `submitted` | Assigned Mitra | Approved OD-27 category-appropriate completion note plus photo/document where appropriate, or explicit Pemesan confirmation; no GPS or unnecessary precise-location metadata. | Freeze proof version; update order. | Pemesan; `local_proof_submitted`. | No silent replacement. |
| `draft` | `failed` | System | Upload/validation fails. | Preserve safe inputs. | Mitra recovery; `local_proof_failed`. | Retry to draft. |
| `submitted` | `accepted` | Pemesan/system | Accepted manually or through approved completion policy. | Mark accepted evidence. | Mitra; `local_proof_accepted`. | Auto path OD-10/OD-11. |
| `submitted` | `superseded` | System | Valid revision produces new proof. | Preserve history. | Participants; `local_proof_superseded`. | Terminal version. |
| `submitted` | `disputed` | System/admin | Eligible dispute references proof. | Preserve evidence. | Participants/admin; `local_proof_disputed`. | Resolve through dispute. |
| `draft` | `cancelled` | Assigned Mitra | Draft has not been submitted and no evidence hold applies. | Close the private proof draft. | Mitra confirmation; `local_proof_draft_cancelled`. | Terminal draft. |
| `failed` | `draft` | Assigned Mitra | Safe inputs remain available after validation/upload failure. | Reopen the proof draft and preserve the failure reason. | Mitra recovery; `local_proof_retry_draft`. | Manual retry. |
| `disputed` | `accepted`/`superseded` | System/admin | Dispute decision is final and explicitly identifies the proof outcome. | Release evidence hold only under retention policy; synchronize order state. | Participants; `local_proof_dispute_resolved`. | Admin-mediated recovery. |

**Control classification**

- Impossible: public precise address as proof, unassigned submission, editing submitted version.
- Terminal: `accepted`, `superseded`, `cancelled`.
- Reversible: `failed`; `disputed` through dispute.
- Administrator-only: dispute evidence controls.
- Scheduled: acceptance only if auto-completion approved.
- Manual MVP: proof submission and review; exact standard OD-27.

## 10. Revision Request

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `requested` | Revisi diminta | Pemesan submitted a scoped correction request. | `accepted`, `declined`, `withdrawn`, `disputed` | Active |
| `accepted` | Revisi disetujui | Mitra agrees request is within scope. | `in_progress`, `withdrawn` | Binding |
| `in_progress` | Revisi dikerjakan | Mitra is correcting work. | `fulfilled`, `disputed` | Active |
| `fulfilled` | Revisi dipenuhi | New delivery/proof submitted for request. | None | Terminal |
| `declined` | Revisi ditolak | Mitra states request is outside scope or invalid. | `disputed`, `withdrawn` | Reversible through dispute |
| `withdrawn` | Permintaan revisi ditarik | Pemesan withdrew request. | None | Terminal |
| `disputed` | Revisi diperselisihkan | Disagreement moved to dispute. | None | Terminal in this machine |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| Creation | `requested` | Pemesan | Submitted delivery/proof; allowance snapshotted from Jasa/accepted Penawaran under approved OD-09; reason references scope/version. Custom digital defaults to one included revision; local uses proof correction. | Pause completion; consume the snapshotted allowance. | Mitra; `revision_requested`. | Additional scope requires a new agreement. |
| `requested` | `accepted` | Mitra | Request within agreed scope. | Reopen work. | Pemesan; `revision_accepted`. | Response reminders depend OD-20/OD-24. |
| `accepted` | `in_progress` | Mitra | Work resumed. | Update execution state. | Pemesan; `revision_started`. | Manual. |
| `in_progress` | `fulfilled` | System | New delivery/proof submitted and linked. | Return Pesanan to submitted review. | Pemesan; `revision_fulfilled`. | Terminal request. |
| `requested` | `declined` | Mitra | Reason identifies scope/policy issue. | Keep prior submission; expose dispute path. | Pemesan; `revision_declined`. | No automatic cancellation/refund. |
| `requested`/`accepted`/`declined` | `withdrawn` | Pemesan | No new revision submission exists and no active dispute decision blocks withdrawal. | Resume prior review/work as appropriate. | Mitra; `revision_withdrawn`. | Terminal. |
| `requested`/`declined`/`in_progress` | `disputed` | Eligible participant/system | Dispute submitted under OD-12. | Preserve versions/messages/evidence. | Both/admin; `revision_disputed`. | Dispute machine controls outcome. |

**Control classification**

- Impossible: revision before submission, after terminal order, by non-Pemesan, or beyond unapproved policy.
- Terminal: `fulfilled`, `withdrawn`, `disputed`.
- Reversible: `declined` through dispute; `requested` by withdrawal.
- Administrator-only: none ordinarily; dispute handling separate.
- Scheduled: none until response/deadline policies approved.
- Manual MVP: participant decisions under approved OD-09 snapshotted allowance and scope rules.

## 11. Cancellation

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `requested` | Pembatalan diajukan | Participant requests cancellation. | `awaiting_response`, `approved`, `denied`, `withdrawn`, `admin_review` | Active |
| `awaiting_response` | Menunggu tanggapan | Other participant may respond. | `approved`, `denied`, `withdrawn`, `admin_review` | Active |
| `admin_review` | Ditinjau admin | Contested/exceptional request awaits admin. | `approved`, `denied` | Manual MVP |
| `approved` | Pembatalan disetujui | Cancellation terms are decided. | `executing` | Binding |
| `denied` | Pembatalan tidak disetujui | Order should continue. | None | Terminal request |
| `withdrawn` | Pengajuan ditarik | Requester withdrew before decision. | None | Terminal request |
| `executing` | Pembatalan diproses | Order/payment effects are being applied. | `executed`, `failed` | Transient |
| `executed` | Pesanan dibatalkan | Order reached cancelled state. | None | Terminal |
| `failed` | Pembatalan belum selesai | A side effect failed. | `executing`, `admin_review` | Recovery |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| Creation | `requested` | Pemesan or Mitra | Approved OD-07 allows a request in the current order state; reason present; actor is a participant. | Set Pesanan cancellation pending. | Other party; `cancellation_requested`. | Safety/dispute holds may pause ordinary resolution. |
| `requested` | `awaiting_response` | System | Approved state-based rule requires participant response. | Set the response task without deciding any financial outcome. | Other party; `cancellation_response_requested`. | Response timing is operational policy, not refund policy. |
| `requested`/`awaiting_response` | `approved` | Other party/system | Mutual consent or approved state-based unilateral rule; non-financial stop/continue outcome is explicit. | Lock the cancellation decision and link any separate financial question. | Both parties; `cancellation_approved`. | Refund/payout eligibility remains OD-08/OD-32. |
| `requested`/`awaiting_response` | `denied` | Other party/system | Approved right to deny; reason. | Resume order prior state. | Both parties; `cancellation_denied`. | Terminal request. |
| `requested`/`awaiting_response` | `withdrawn` | Requester | No decision/execution. | Resume prior order state. | Other party; `cancellation_withdrawn`. | Terminal request. |
| `requested`/`awaiting_response` | `admin_review` | Participant/system | Contested or exception under approved policy. | Preserve evidence; assign case. | Parties/admin; `cancellation_escalated`. | Manual MVP. |
| `admin_review` | `approved`/`denied` | Authorized admin | Evidence and approved OD-07 policy; reason. | Set binding outcome. | Both parties; `cancellation_admin_decided`. | Admin-only. |
| `approved` | `executing` | System/admin | Work-stop effects are defined; any financial action has a separate approved Payment/Payout decision. | Stop work and trigger only separately authorized linked financial actions. | Both parties; `cancellation_execution_started`. | Await incomplete side effects without deciding refund/payout here. |
| `executing` | `executed` | System | Required side effects completed or explicitly recorded as none. | Set Pesanan cancelled. | Both parties; `cancellation_executed`. | Terminal. |
| `executing` | `failed` | System | Work/order effect or separately authorized financial side effect failed. | Hold case for recovery. | Pemesan/admin; `cancellation_execution_failed`. | Retry or admin review. |
| `failed` | `executing` | System/admin | Failed work-stop or linked side effect is safe to retry idempotently. | Resume execution without changing the approved cancellation decision. | Parties/admin; `cancellation_execution_retried`. | Retry only the incomplete side effect. |
| `failed` | `admin_review` | Authorized admin | Reconciliation shows the approved execution cannot continue safely or its non-financial terms need correction. | Reopen cancellation handling while preserving the prior decision and failures. | Parties/admin; `cancellation_failure_escalated`. | Admin-only recovery. |

**Control classification**

- Impossible: cancellation after terminal order unless separate dispute remedy; execution without approved decision; silent refund.
- Terminal: `denied`, `withdrawn`, `executed`.
- Reversible: `failed`; pending request by withdrawal.
- Administrator-only: contested decision and exceptional recovery.
- Payment webhook: may complete refund side effect, not cancellation policy decision.
- Scheduled: response deadline only after OD-07 approval.
- Manual MVP: contested cancellation decisions; any refund/payout authorization remains in its separate machine.

**Approved for closed beta (OD-07):** apply state-based rules before confirmation, after confirmation before payment, after payment before work, after work starts, after submission, and during an active safety/dispute case. Cancellation never decides refund or payout eligibility/amount; financial outcomes belong to OD-08 and OD-32.

## 12. Report

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `submitted` | Laporan diterima | Report was recorded. | `triaged`, `closed_duplicate` | Active |
| `triaged` | Laporan ditinjau awal | Severity, scope, and ownership classified. | `investigating`, `awaiting_information`, `dismissed`, `actioned` | Manual MVP |
| `awaiting_information` | Menunggu informasi | Reporter/party/admin input is needed. | `investigating`, `dismissed`, `closed` | Reversible |
| `investigating` | Sedang diperiksa | Authorized admin reviews context/evidence. | `awaiting_information`, `actioned`, `dismissed` | Manual MVP |
| `actioned` | Tindakan diambil | A linked moderation/safety action occurred. | `closed`, `reopened` | Binding |
| `dismissed` | Tidak ada tindakan | Evidence/policy did not support action. | `closed`, `reopened` | Reversible on new evidence |
| `closed_duplicate` | Digabung dengan laporan lain | Duplicate is linked to canonical case. | None | Terminal |
| `closed` | Laporan selesai | Case handling ended. | `reopened` | Terminal ordinary |
| `reopened` | Laporan dibuka kembali | New evidence or appeal restored review. | `triaged`, `investigating` | Administrator-only |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| Creation | `submitted` | Eligible reporter | Reportable object/reason; rate/abuse controls; safe evidence. | Create case; preserve target snapshot. | Receipt; `report_submitted`. | Urgent safety routing manual under OD-20. |
| `submitted` | `triaged` | Authorized admin | Permission, no conflict, case complete enough. | Assign severity/category/owner. | Reporter status; `report_triaged`. | Manual MVP. |
| `submitted` | `closed_duplicate` | Admin | Canonical report exists; link validated. | Consolidate evidence safely. | Reporter notice; `report_deduplicated`. | Terminal duplicate. |
| `triaged` | `investigating` | Authorized admin | Case has an assigned reviewer and enough information to begin. | Start evidence/context review. | Reporter status; `report_investigation_started`. | Manual MVP. |
| `triaged`/`investigating` | `awaiting_information` | Admin | Specific missing information. | Create limited request. | Relevant party; `report_information_requested`. | Deadline/support policy OD-20. |
| `awaiting_information` | `investigating` | Admin | Sufficient response received. | Resume review. | Reporter status; `report_investigation_resumed`. | Manual. |
| `triaged`/`investigating` | `actioned` | Admin | Approved policy supports linked action; reason/evidence. | Trigger separate moderation state machine. | Safe decision notices; `report_actioned`. | Linked action may have its own recovery. |
| `triaged`/`investigating` | `dismissed` | Admin | Evidence/policy does not support action; reason. | No adverse linked action. | Reporter safe reason; `report_dismissed`. | Reopen on new evidence. |
| `actioned`/`dismissed`/`awaiting_information` | `closed` | Admin | Required communication/actions complete. | Close queue item. | Reporter closure; `report_closed`. | Reopen admin-only. |
| `closed`/`dismissed`/`actioned` | `reopened` | Authorized admin | New material evidence, appeal, or error; reason. | Restore case. | Relevant parties; `report_reopened`. | Administrator-only. |
| `awaiting_information` | `dismissed` | Authorized admin | Approved deadline elapsed or response confirms no actionable basis; reason required. | End investigation without an adverse linked action. | Reporter safe reason; `report_dismissed_after_information_request`. | Can reopen on new evidence. |
| `reopened` | `triaged`/`investigating` | Authorized admin | Reopen reason identifies whether fresh triage or direct investigation is required. | Assign the case and restore the chosen review stage. | Relevant parties; `report_reopen_routed`. | Administrator-only. |

**Control classification**

- Impossible: reporter directly imposing moderation; closing without reason; exposing private evidence to unrelated party.
- Terminal: `closed_duplicate`; `closed` ordinarily.
- Reversible: `dismissed`, `closed`, `actioned` only through admin reopen.
- Administrator-only: all review/outcome/reopen transitions.
- Scheduled/webhook: none required; reminders depend OD-20.
- Manual MVP: triage, investigation, outcome, reopen.

## 13. Dispute

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `submitted` | Sengketa diajukan | Participant submitted order dispute. | `eligibility_review`, `withdrawn` | Active |
| `eligibility_review` | Kelayakan diperiksa | Admin checks deadline, standing, and scope. | `evidence_collection`, `dismissed` | Manual MVP |
| `evidence_collection` | Bukti dikumpulkan | Parties provide allowed evidence. | `under_review`, `withdrawn`, `dismissed` | Active |
| `under_review` | Sengketa ditinjau | Admin evaluates record and approved policy. | `decision_issued`, `evidence_collection` | Manual MVP |
| `decision_issued` | Keputusan diterbitkan | Outcome and remedies are recorded. | `implementing`, `resolved` | Binding |
| `implementing` | Keputusan dijalankan | Linked order/payment/moderation effects are pending. | `resolved`, `implementation_failed` | Transient |
| `implementation_failed` | Pelaksanaan tertunda | A remedy side effect failed. | `implementing`, `under_review` | Recovery |
| `resolved` | Sengketa selesai | Decision effects completed. | `reopened`, `closed` | Terminal ordinary |
| `dismissed` | Sengketa tidak diproses | Ineligible/unsupported case closed with reason. | `reopened`, `closed` | Terminal ordinary |
| `withdrawn` | Sengketa ditarik | Submitter withdrew before decision when allowed. | `closed` | Terminal |
| `closed` | Kasus ditutup | Administrative closure complete. | `reopened` | Terminal ordinary |
| `reopened` | Sengketa dibuka kembali | Approved appeal/new evidence/error. | `eligibility_review`, `evidence_collection`, `under_review` | Administrator-only |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| Creation | `submitted` | Pesanan participant | **Approval required OD-12**; standing, order, reason, initial evidence. | Preserve relevant order versions/history. | Receipt to parties; `dispute_submitted`. | Deadline not enforced until approved. |
| `submitted` | `eligibility_review` | Authorized admin | Permission/no conflict. | Assign reviewer. | Parties status; `dispute_eligibility_review_started`. | Manual MVP. |
| `eligibility_review` | `evidence_collection` | Admin | Eligible under approved policy. | Open evidence requests. | Parties; `dispute_accepted_for_review`. | Evidence deadline requires approval/support model. |
| `eligibility_review` | `dismissed` | Admin | Ineligible with safe reason. | Close merits review. | Submitter decision; `dispute_dismissed_ineligible`. | Reopen only on error/new evidence. |
| `evidence_collection` | `under_review` | Admin | Required evidence collected or documented unavailable. | Lock ordinary submissions. | Parties; `dispute_review_started`. | Manual. |
| `under_review` | `evidence_collection` | Admin | Specific additional evidence needed. | Reopen limited evidence window. | Relevant party; `dispute_more_evidence_requested`. | Deadline policy required. |
| `under_review` | `decision_issued` | Authorized admin | Approved cancellation/refund/service policy; reason and remedy explicit. | Lock decision version. | Both parties; `dispute_decision_issued`. | No silent refund/guarantee. |
| `decision_issued` | `implementing` | System/admin | Remedy includes linked state/payment action. | Trigger allowed side effects. | Parties; `dispute_implementation_started`. | Payment callback may complete refund part. |
| `decision_issued` | `resolved` | System/admin | Decision requires no pending side effect. | Mark resolved. | Parties; `dispute_resolved`. | Terminal ordinary. |
| `implementing` | `resolved` | System | All side effects confirmed. | Finalize case. | Parties; `dispute_resolved`. | Webhook may confirm payment effect. |
| `implementing` | `implementation_failed` | System | Side effect failed. | Hold for reconciliation. | Affected party/admin; `dispute_implementation_failed`. | Retry/admin recovery. |
| `submitted`/`evidence_collection` | `withdrawn` | Submitter | No decision; withdrawal allowed by policy. | Stop review. | Other party; `dispute_withdrawn`. | Does not erase related reports/evidence. |
| `resolved`/`dismissed`/`closed` | `reopened` | Authorized admin | Approved appeal, new evidence, or material error. | Restore review with reason. | Parties; `dispute_reopened`. | Admin-only. |
| `evidence_collection` | `dismissed` | Authorized admin | Evidence confirms the case is ineligible or unsupported under approved policy; reason required. | End merits review without a remedy. | Parties; `dispute_dismissed_after_evidence`. | Reopen only on error/new evidence. |
| `implementation_failed` | `implementing` | System/admin | Incomplete remedy side effects are safe to retry idempotently. | Resume only the failed effects. | Affected parties/admin; `dispute_implementation_retried`. | Reconciliation prevents duplicate remedies. |
| `implementation_failed` | `under_review` | Authorized admin | Remedy cannot be implemented as issued or material inconsistency is found. | Return to review without rewriting evidence or the prior decision. | Parties; `dispute_returned_to_review`. | A new decision version is required. |
| `resolved`/`dismissed`/`withdrawn` | `closed` | Authorized admin/system | Required communication, retention holds, and linked actions are complete. | Administratively close the case. | Parties; `dispute_closed`. | Reopen remains admin-only. |
| `reopened` | `eligibility_review`/`evidence_collection`/`under_review` | Authorized admin | Reopen reason identifies the correct review stage and reviewer has no conflict. | Restore the selected stage and preserve the earlier case record. | Parties; `dispute_reopen_routed`. | Administrator-only recovery. |

**Control classification**

- Impossible: dispute by unrelated user, decision without approved policy, automatic refund, or changing evidence history.
- Terminal: `withdrawn`; `resolved`, `dismissed`, and `closed` ordinarily.
- Reversible: terminal ordinary states only through admin reopen.
- Administrator-only: eligibility, evidence control, decision, reopen.
- Payment webhook: remedy implementation confirmation only.
- Scheduled: deadlines/reminders only after OD-12/OD-20 approval.
- Manual MVP: all adjudication and remedy authorization.

**Recommended default — approval required:** allow submission within seven calendar days of completion/cancellation, pause no funds automatically, and resolve manually. This remains inactive until OD-12 and payment/refund policies are approved.

## 14. Review

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `eligible` | Bisa memberi ulasan | Completed Pesanan permits one review. | `draft`, `published` | Active |
| `draft` | Draf ulasan | Unpublished review content. | `published`, `withdrawn` | Reversible |
| `published` | Ulasan dipublikasikan | Public completed-order review. | `edited`, `hidden`, `removed`, `withdrawn` | Active; edit OD-23 |
| `edited` | Ulasan diperbarui | Published review has visible edit history/marker. | `edited`, `hidden`, `removed`, `withdrawn` | Conditional OD-23 |
| `hidden` | Ulasan disembunyikan | Temporarily unavailable pending moderation. | `published`, `removed` | Administrator-controlled |
| `removed` | Ulasan dihapus | Removed for policy with reason. | `published` | Admin recovery only |
| `withdrawn` | Ulasan ditarik | Reviewer removed public display where policy allows. | None | Terminal |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| Creation | `eligible` | System | Pesanan completed; actor is Pemesan; no active review. | Show review action. | Pemesan; `review_eligible`. | Eligibility expiry, if any, needs OD-23. |
| `eligible` | `draft` | Pemesan | User starts review. | Save private draft if supported. | None; `review_draft_started`. | User may withdraw draft. |
| `eligible`/`draft` | `published` | Pemesan | Rating valid; content policy; one review; order still eligible. | Publish rating/count/provenance. | Mitra; `review_published`. | No synthetic production review. |
| `published`/`edited` | `edited` | Reviewer | Approved OD-23 permits one edit within seven days; valid content; edit not already consumed. | Preserve prior version and display the edited marker. | Mitra; `review_edited`. | Additional edits are rejected. |
| `published`/`edited` | `hidden` | Moderator | Report/review requires temporary restriction; reason. | Remove public visibility without deleting evidence. | Reviewer/Mitra as safe; `review_hidden`. | Manual moderation. |
| `hidden` | `published` | Moderator | Review passes moderation. | Restore public visibility. | Parties; `review_restored`. | Admin-only. |
| `published`/`edited`/`hidden` | `removed` | Moderator | Policy violation; reason/evidence. | Remove public visibility; adjust aggregates. | Parties; `review_removed`. | Restore only on successful review/appeal. |
| `published`/`edited` | `withdrawn` | Reviewer | Withdrawal allowed under approved OD-23. | Remove display; preserve audit/version history. | Optional Mitra notice; `review_withdrawn`. | Terminal ordinary. |
| `draft` | `withdrawn` | Reviewer | Draft is unpublished. | Close the draft while preserving minimum audit history. | Reviewer confirmation; `review_draft_withdrawn`. | Terminal ordinary. |
| `removed` | `published` | Authorized moderator | Appeal/review confirms the original content may be restored; reason required. | Restore visibility and recalculate aggregates. | Reviewer and Mitra; `review_removal_reversed`. | Admin-only recovery. |

**Control classification**

- Impossible: review before completed Pesanan, duplicate review, Mitra self-review, production `is_demo` review.
- Terminal: `withdrawn`; `removed` ordinarily.
- Reversible: `hidden`, `removed` admin-only; published edits conditional OD-23.
- Administrator-only: hide, remove, restore.
- Scheduled/webhook: none required.
- Manual MVP: review creation and moderation.

## 15. User-Account Moderation

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `active` | Akun aktif | Normal permitted access. | `limited`, `suspended`, `banned`, `deactivated` | Active |
| `limited` | Akses dibatasi | Specific capabilities are temporarily blocked. | `active`, `suspended`, `banned`, `appeal_pending` | Reversible |
| `suspended` | Akun ditangguhkan | Sign-in or marketplace actions are broadly blocked. | `active`, `limited`, `banned`, `appeal_pending` | Admin-only |
| `banned` | Akun dinonaktifkan permanen | Severe/permanent marketplace exclusion. | `appeal_pending` | Terminal ordinary |
| `appeal_pending` | Banding sedang ditinjau | Approved appeal is under review. | `active`, `limited`, `suspended`, `banned` | Manual MVP |
| `deactivated` | Akun dinonaktifkan pengguna | User requested ordinary deactivation. | `active` | Reversible subject to retention OD-28 |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| `active` | `limited` | Authorized admin | Approved OD-19 proportional restriction; specific risk/violation; scope, reason, and review date where applicable. | Disable named capabilities; preserve safe access to obligations/support and handle active Pesanan individually. | User notice; `account_limited`. | Scheduled review/expiry only if separately defined. |
| `active`/`limited` | `suspended` | Authorized admin | Approved suspension basis; reason/evidence. | Block affected sessions/actions; pause Mitra publishing/offers. | User notice; `account_suspended`. | Manual review; no silent expiry policy. |
| `active`/`limited`/`suspended` | `banned` | Authorized senior admin | Severe approved basis, proportionality review, reason. | Revoke marketplace access; preserve legal/audit records. | User safe notice; `account_banned`. | Appeal path depends OD-19/OD-20. |
| `limited`/`suspended` | `active` | Authorized admin | Review shows restriction no longer needed. | Restore allowed capabilities. | User notice; `account_restored`. | Admin-only. |
| `banned`/`suspended`/`limited` | `appeal_pending` | User/admin intake | Appeal allowed and timely under OD-19. | Assign independent reviewer where possible. | Receipt; `account_appeal_submitted`. | Deadline/support model OD-20. |
| `appeal_pending` | `active`/`limited`/`suspended`/`banned` | Authorized reviewer | Appeal decision with reason/evidence. | Apply final moderation state. | User decision; `account_appeal_decided`. | Manual MVP. |
| `active` | `deactivated` | Account holder | No security hold; approved OD-28 consequences explained. | Disable public profile and new marketplace actions while preserving access required for active obligations/safety cases. | Confirmation; `account_deactivated`. | Reversible; irreversible deletion is manual until P2 retention policy. |
| `deactivated` | `active` | Account holder/admin support | Reactivation permitted; contact revalidated if needed; no irreversible manual deletion completed. | Restore account, not necessarily Mitra reviewed status. | User notice; `account_reactivated`. | Reversible until a future approved deletion boundary. |
| `suspended` | `limited` | Authorized admin | Review supports a narrower restriction; capabilities and obligations are explicitly scoped. | Restore only permitted access; keep named capabilities blocked. | User notice; `account_restriction_reduced`. | Administrator-only. |

**Control classification**

- Impossible: self-granted restoration from suspension/ban, deletion of audit evidence, admin action without permission/reason.
- Terminal: `banned` ordinarily; `deactivated` after any approved irreversible deletion boundary.
- Reversible: `limited`, `suspended`, `deactivated`; `banned` only through appeal.
- Administrator-only: restrictions, suspension, ban, appeal decision, restoration.
- Scheduled: restriction expiry/review only after OD-19 approval.
- Manual MVP: moderation, appeal, restoration.

## 16. Mitra Settlement and Payout

This provider-neutral model is a product-state placeholder for **OD-32**. All real-money collection, settlement, and payout behavior remains disabled until OD-05 and OD-32 are approved and the production provider, reconciliation, privacy, legal, finance, and operational controls are ready.

### State catalog

| State | Indonesian label | Meaning | Allowed next states | Classification |
|---|---|---|---|---|
| `disabled` | Payout belum tersedia | Real-money payout is not enabled in this environment/policy. | None | Terminal for disabled phase |
| `pending_eligibility` | Menunggu kelayakan payout | Payment/order/fee/account conditions are not yet all satisfied. | `on_hold`, `eligible`, `cancelled` | Active |
| `on_hold` | Payout ditahan | Dispute, restriction, verification, or reconciliation blocks release. | `pending_eligibility`, `eligible`, `cancelled` | Reversible |
| `eligible` | Siap dijadwalkan | Earnings and verified payout account meet approved release rules. | `on_hold`, `processing`, `cancelled` | Binding eligibility |
| `processing` | Payout diproses | Provider/bank transfer is in progress. | `paid`, `failed` | Transient |
| `failed` | Payout gagal | Transfer failed or could not be reconciled. | `eligible`, `on_hold`, `cancelled` | Recovery |
| `paid` | Payout dibayarkan | Confirmed net amount reached the approved destination. | `adjustment_pending` | Binding |
| `adjustment_pending` | Koreksi payout diproses | Approved reversal or correction is pending. | `adjustment_pending`, `paid`, `adjusted` | Recovery/binding |
| `adjusted` | Payout dikoreksi | Approved correction or reversal is reconciled. | `adjustment_pending` | Binding |
| `cancelled` | Payout dibatalkan | No transfer will occur for this payout record. | None | Terminal |

### Transition table

| From | To | Actor/trigger | Preconditions and validation | Side effects | Notification and audit | Timeout/cancellation/recovery |
|---|---|---|---|---|---|---|
| Creation | `disabled` | System | Production payout policy/provider is not approved or environment is mock-only. | Prevent transfer and public payout claims. | Admin-only environment record; `payout_disabled`. | No real-money transition can leave this state. |
| Creation | `pending_eligibility` | System | OD-32 is approved and an order/payment may create Mitra earnings. | Create provider-neutral payout record with gross, fee, net, currency, and order/payment references. | Mitra status; `payout_pending_eligibility`. | Creation remains unavailable before approval. |
| `pending_eligibility` | `on_hold` | System/admin | Active dispute, account restriction, unverified payout account, refund exposure, or reconciliation exception exists. | Block scheduling and record hold reason. | Mitra/admin safe notice; `payout_held`. | Review manually or on synchronized event. |
| `pending_eligibility` | `eligible` | System/admin | Approved earnings event occurred; fee/net calculation reconciles; payout account is verified; no hold exists. | Lock eligible amount/version. | Mitra; `payout_eligible`. | Timing follows OD-32. |
| `pending_eligibility` | `cancelled` | System/admin | Earnings never became payable under approved policy; reason required. | Close record without transfer. | Mitra/admin; `payout_cancelled_before_eligibility`. | Does not alter Payment by itself. |
| `on_hold` | `pending_eligibility` | System/admin | Hold is removed but eligibility must be recalculated. | Re-run approved eligibility checks. | Mitra/admin; `payout_hold_released_for_review`. | Idempotent reconciliation. |
| `on_hold` | `eligible` | System/admin | Hold is removed and all eligibility checks pass. | Lock eligible amount/version. | Mitra; `payout_hold_released`. | Timing restarts under OD-32. |
| `on_hold` | `cancelled` | Authorized admin/system | Final approved refund/dispute/account outcome removes payout entitlement. | Close without transfer; preserve reason and linked decision. | Mitra/admin; `payout_cancelled_after_hold`. | No implicit refund decision. |
| `eligible` | `on_hold` | System/admin | A dispute, restriction, mismatch, or verified risk appears before transfer. | Stop scheduling/processing where provider permits. | Mitra/admin; `payout_hold_applied`. | If provider already paid, use correction path. |
| `eligible` | `processing` | System/payout adapter | Approved payout time reached; destination and amount revalidated; idempotency key unused. | Submit provider-neutral transfer attempt. | Mitra; `payout_processing`. | Provider callback/reconciliation completes it. |
| `eligible` | `cancelled` | Authorized admin/system | Approved final outcome removes entitlement before transfer. | Close record without transfer. | Mitra/admin; `payout_cancelled`. | Requires linked policy decision and reason. |
| `processing` | `paid` | Authenticated callback/reconciliation | Provider reference, destination, amount, currency, and idempotency match. | Record paid time and immutable transfer result. | Mitra/admin; `payout_paid`. | Duplicate callbacks are no-ops. |
| `processing` | `failed` | Authenticated callback/reconciliation | Transfer failed or timed out without a paid result. | Record safe failure code and preserve amount. | Mitra/admin; `payout_failed`. | Retry only after destination/eligibility review. |
| `failed` | `eligible` | Authorized admin/system | Failure is recoverable; payout account and amount revalidate. | Permit a new distinct transfer attempt. | Mitra/admin; `payout_retry_ready`. | Prior attempt remains immutable. |
| `failed` | `on_hold` | Authorized admin/system | Failure reveals destination, account, dispute, or reconciliation concern. | Block retries pending review. | Mitra/admin; `payout_failure_held`. | Manual recovery. |
| `failed` | `cancelled` | Authorized admin | Final approved outcome closes the failed payout without transfer. | Close record and preserve reconciliation evidence. | Mitra/admin; `payout_failure_cancelled`. | Reason required. |
| `paid` | `adjustment_pending` | Authorized finance/admin | Approved correction or reversal is linked to an immutable source decision; amount cannot be silently edited. | Open adjustment record without rewriting paid history. | Mitra/admin; `payout_adjustment_started`. | No user-initiated reversal. |
| `adjustment_pending` | `adjustment_pending` | System/admin | Prior adjustment attempt failed or timed out and a safe idempotent retry is approved. | Record new attempt while retaining failure history. | Mitra/admin; `payout_adjustment_retried`. | Reconcile before retry. |
| `adjustment_pending` | `paid` | Authorized finance/admin | Proposed adjustment is cancelled or provider confirms no money moved. | Close adjustment attempt and retain original paid result. | Mitra/admin; `payout_adjustment_cancelled`. | Reason required. |
| `adjustment_pending` | `adjusted` | Authenticated callback/reconciliation | Approved correction/reversal completes and amounts reconcile. | Record corrected net position without overwriting prior transfer. | Mitra/admin; `payout_adjusted`. | Further correction uses a new adjustment. |
| `adjusted` | `adjustment_pending` | Authorized finance/admin | Another approved correction is required. | Open a new immutable adjustment version. | Mitra/admin; `payout_additional_adjustment_started`. | Exceptional, audited. |

**Control classification**

- Impossible: real-money payout before OD-05/OD-32 approval, payout to an unverified destination, silent fee/net changes, or rewriting a paid transfer.
- Terminal: `disabled` for disabled phases and `cancelled`; `paid`/`adjusted` are binding but permit explicit audited correction.
- Reversible: `on_hold` and `failed`; correction retries remain in `adjustment_pending`.
- Administrator-only: holds, cancellation after eligibility, reconciliation, reversal, and correction authorization.
- Payment webhook: may establish collected-funds evidence but never alone establishes payout eligibility.
- Scheduled: payout release only under approved OD-32 timing.
- Manual MVP: mock payout states only; no real funds move.

## Cross-Machine Event Synchronization

Cross-machine changes use one correlation ID and one authoritative initiating event. State updates inside one product transaction are atomic. Provider callbacks or other external side effects use an idempotent command/event key, durable retry, and reconciliation; a partially completed external sequence must expose a recoverable pending/failed state rather than contradictory success.

| Event | Affected machines | Required synchronized outcome |
|---|---|---|
| Offer acceptance and order creation | Permintaan, Penawaran, Pesanan | Atomically reserve one offer/request acceptance, create one Pesanan from immutable snapshots, then mark the request/offer converted. On failure, restore `offer_selected`/`accepted` through their documented recovery states without creating a second order. |
| Competing offers close | Penawaran, Permintaan | After one conversion commits, every other `submitted` offer closes as `rejected` or `expired` under one correlated event; retries cannot close the accepted offer. |
| Payment success | Payment, Pesanan, Payout | Record `paid` once and move an eligible order from `awaiting_payment` to `ready_to_start`. If OD-32 is approved and payout is enabled, create/update it only as `pending_eligibility`, never directly `paid`; otherwise no real payout leaves `disabled`. Amount mismatch or duplicate callback leaves order/payout unchanged and opens reconciliation. |
| Work start | Pesanan, Work Execution | `ready_to_start → in_progress` and `ready → in_progress` commit together. Failure leaves both at their pre-start states or enters audited reconciliation; notification is emitted after commit. |
| Digital delivery | Digital Delivery, Work Execution, Pesanan | One immutable submitted delivery version atomically moves execution and order to `submitted`. Upload processing failure leaves both work/order active and the delivery `failed`/`draft`. |
| Local proof | Local Proof, Work Execution, Pesanan | One immutable proof submission atomically moves execution and order to `submitted`. Validation failure leaves the order/execution active and proof recoverable. |
| Revision open | Revision, Pesanan, Work Execution, Digital Delivery/Local Proof | A valid request creates `requested`, then accepted revision synchronizes order `revision_in_progress` and work `revision`; referenced submission remains immutable. Any failed side effect rolls back or routes to reconciliation before new work is enabled. |
| Revision fulfill | Revision, Work Execution, Digital Delivery/Local Proof, Pesanan | A new delivery/proof version commits with revision `fulfilled`, work `submitted`, order `submitted`, and prior version `superseded`. Duplicate fulfillment cannot create another version. |
| Order completion | Pesanan, Work Execution, Digital Delivery/Local Proof, Review, Payout | Completion requires the accepted submission/proof; atomically mark order/work complete and create review eligibility. Payout eligibility is evaluated separately and may remain pending/on hold. |
| Cancellation | Cancellation, Pesanan, Work Execution, Payment, Payout | Approved execution stops work and cancels the order exactly once. Cancellation records but does not decide refund/payout entitlement; separately approved financial events update Payment/Payout. Failed effects enter `failed`/reconciliation without duplicating cancellation. |
| Refund | Payment, Payout, Pesanan/Dispute or Cancellation | A separately authorized refund changes Payment once and places any unpaid payout on hold/cancel or starts an audited correction for paid payout. It does not rewrite the order outcome or originating decision. |
| Dispute open | Dispute, Pesanan, Digital Delivery/Local Proof, Payout | Create one dispute, preserve referenced evidence, block auto-completion where applicable, and place eligible/unpaid payout on hold. Failure to apply a hold is visible to admin reconciliation. |
| Dispute resolve | Dispute, Pesanan, Digital Delivery/Local Proof, Payment, Payout, Account/Jasa where ordered | Implement only the versioned remedy; resolve the dispute after every required side effect succeeds. Failures enter `implementation_failed`; retries use the same remedy/correlation ID. |
| Mitra/account suspension with active Jasa/Pesanan | User Account, Verification, Jasa, Pesanan, Work Execution, Payout | Immediately block new publishing/offers/orders and pause or hide active Jasa. Existing Pesanan are evaluated individually: preserve safe participant/support access, stop unsafe work, and hold payouts when required. Never silently cancel active orders; each linked action uses its own valid transition and audit reason. |

Every synchronized event records actor/trigger, timestamp, source and destination states for each affected object, immutable object/version references, correlation and idempotency keys, reason, and evidence reference where applicable. Automated retries append attempts; they never rewrite the initiating audit event. Manual recovery requires the scoped permission in OD-31 and records the mismatch, decision, and final reconciliation.

## Cross-Machine Impossible Transitions

The following are always rejected:

1. Publishing or ordering a Jasa that is not `published`.
2. Submitting a Penawaran to a Permintaan that is not `published`.
3. Accepting more than one Penawaran for one Permintaan.
4. Creating a Pesanan without a valid Jasa snapshot or accepted Penawaran snapshot.
5. Starting paid-required work before Payment is `paid`.
6. Submitting delivery/proof before assigned work is `in_progress` or `revision`.
7. Completing a Pesanan without accepted delivery/proof or an approved auto-completion policy.
8. Creating a Review before Pesanan is `completed`.
9. Exposing the closed-beta `Profil Mitra diperiksa` status unless onboarding review is `verified`, or exposing `Identitas terverifikasi` at all during closed beta.
10. Allowing a suspended/banned account to bypass restrictions through another non-admin role.
11. Moving any `is_demo` object into production.
12. Treating a Report or Dispute submission as proof that the reported party violated policy.

## Policy Decisions Required Before Production

| Policy | Decision | Status | Approval reference |
|---|---|---|---|
| Refund behavior | No automatic refund; manual approved outcome only. | Open P2 | OD-08 |
| Cancellation behavior | State-based cancellation; refund and payout outcomes are determined separately. | Approved for closed beta | OD-07 |
| Auto-completion | Reminder-led 72-hour review period, then auto-complete only if approved and no issue. | Open P1 | OD-10, OD-11 |
| Revision allowance | Snapshot from Jasa/accepted Penawaran; one included custom-digital revision; local proof correction; new agreement for added scope. | Approved for closed beta | OD-09 |
| Dispute deadline | Seven calendar days after completion/cancellation. | Open P1 | OD-12 |
| Verification expiry | Annual renewal with advance notice. | Open P1 | OD-14 |
| Request/offer expiry | Permintaan 14 calendar days; offers expire with it or earlier stated validity; reopening starts a new window. | Approved for closed beta | OD-26 |
| Existing-Jasa confirmation | Explicit Mitra response; reminder after 12 hours; idempotent no-response cancellation after 24 hours in the order timezone; no payment before acceptance. | Approved for closed beta | OD-29 |
| Mitra settlement/payout | Provider-neutral model only; all real-money settlement/payout disabled until approved. | Open P2 | OD-32 |
| Verification evidence/lifecycle | No government ID or identity-match media in closed beta; use `Profil Mitra diperiksa`; future production verification/lifecycle remains open. | Approved for closed beta; production P2 open | OD-13, OD-33 |
| Permintaan visibility/eligibility | Privacy-minimized visitor view, no external indexing, authenticated eligible Mitra responses only. | Approved for closed beta | OD-34 |

Approved closed-beta policies are active only within their recorded limits. Open P1/P2 production behavior remains disabled until its approval record exists.
