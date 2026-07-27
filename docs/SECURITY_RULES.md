# Jasama Closed-Beta Security Rules

Status: binding authorization, RLS, Storage, privacy, and operational-security contract.

## 1. Security principles

- Deny by default. Browser state, hidden controls, and supplied identifiers are not authorization.
- Supabase Auth establishes an account; it does not confer a role. Authorization combines base profile, optional Mitra capability, ownership/context, restrictions, and explicit administrator permissions.
- All privileged mutations, service-role access, private-file grants, and administrative reads execute server-side.
- RLS remains enabled on every exposed application table. The service role is never sent to the browser and is not used for routine participant reads.
- Product state transitions happen only through domain commands that recheck state and authorization in the transaction.
- Public reads use explicit safe projections/functions. Broad `SELECT *` on base tables is prohibited.
- Data minimization, append-only audit, short-lived grants, least privilege, and safe failure apply throughout.

## 2. Auth and actor resolution

Every authenticated request resolves:

1. `auth.uid()` and its unique `profiles` row;
2. current `profiles.account_state` and capability-specific restrictions;
3. optional `mitra_profiles` row and current closed-beta review state;
4. contextual participation/ownership for the target object;
5. active, unexpired `admin_permission_assignments`;
6. verified reauthentication evidence when a high-risk action requires it.

Missing profile, inactive session, banned/suspended account, absent contextual membership, or absent permission produces denial. A limited account may retain only the explicitly allowed capabilities needed to handle existing obligations, evidence, appeal, or support. That exception is an explicit permission decision, not a blanket RLS bypass.

There is no `users.role`, `is_admin`, or `is_verified`. Contact verification, Mitra review, and administrator grants are independently evaluated.

Phone verification is a phase blocker, not an operational capability: no onboarding gate or trust claim may depend on it until a mechanism/provider is selected, integrated, threat-reviewed, and tested.

## 3. RLS matrix

Legend: **own** means row ownership verified by `auth.uid()` through `profiles`; **party** means active contextual membership; **scoped admin** means an exact active permission and scope. Administrative writes call reviewed server/database functions rather than direct table DML.

| Domain / tables | Anonymous | Authenticated non-owner | Owner / contextual party | Mitra capability | Scoped administrator | Server job/service role |
|---|---|---|---|---|---|---|
| Base profile/contact: `profiles`, `contact_verifications` | Safe public profile projection only; no contact row | Safe projection only | Read/update allowlisted own fields; read own verification | Same as base account | Support permission reads only needed fields; no arbitrary auth changes | Auth callback/job only for exact operation |
| Mitra profile/review: `mitra_profiles`, review/events, service areas | Approved public projection | Approved public projection | Candidate reads/edits own draft and safe review feedback | Submit/withdraw only in allowed state | `mitra.review` queue/read/transition; cannot claim government-ID review | Scheduled expiry disabled while OD-14 open |
| Admin permissions | Deny | Subject may read own effective grants; cannot provision | Same | Same | Ordinary `grant_source=admin` only; no self-grant; cannot invoke provisioning; high-risk grants unavailable | Reviewed migration/provisioning owner alone may bootstrap/recover with `grant_source=provisioning` |
| Taxonomy/localities | Read active public rows | Read active rows | No write | No write | Exact taxonomy permission; closed-beta top-level changes require product approval | Migration seed |
| Jasa/version/media/moderation | Published safe projection only | Same plus own contextual data | Mitra owner manages draft/submission; cannot self-publish | Requires eligible Mitra review to submit/order | `jasa.moderate` queue/decision; private notes restricted | Scheduled tasks only where approved |
| Favorites | Deny | Deny | Read/insert/delete own rows | Same | Deny absent support/legal need | No routine access |
| Permintaan/version | Privacy-minimized, non-indexable safe projection for published non-demo rows | Eligible browse projection or own full row | Pemesan creates/edits/transitions own request | Eligible reviewed Mitra reads response projection | `permintaan.moderate` for removal/recovery | Expiry job with expected version |
| Penawaran/version | Deny | Request owner reads chain/history for own request | Mitra author replaces by creating a new linked aggregate; old replaced aggregate stays terminal; Pemesan selects only the active link | Review/eligibility required; `mitra_profile_id` resolves `mitra_profiles(id)` | Only scoped safety/dispute context | Expiry/conversion transaction; dedicated successor thread |
| Pesanan/snapshot/history/participants/private location | Deny | Deny | Parties read every immutable terms version and safe history; `terms_version` selects current applicability; customer controls private location | `mitra_profile_id` resolves `mitra_profiles(id)`; participant auth resolves its base profile | Exact order/dispute/safety permission, field-minimized | OD-29 and cross-machine jobs; no broad export |
| Work/delivery/proof/revision | Deny | Deny | Parties read; actor writes only allowed command/state; submitted versions immutable | Mitra performs provider commands | Dispute/safety permission for held evidence/outcome | Cross-machine event jobs only |
| Threads/messages/attachments | Deny | Deny | Active participants in exactly one Jasa inquiry, Permintaan, Penawaran, Pesanan, Report, or Dispute context read/write; sender cannot rewrite sent content | No unsolicited thread creation; Penawaran has a dedicated thread | Scoped case admin reads only linked case threads | Validation/notification processing only |
| Cancellation/mock payment/payout | Deny | Deny | Parties see/request/answer cancellation and visible simulation result | Same | Cancellation permission decides exceptional case | Mock command only outside production; payout only disabled |
| Reviews/versions | Published safe projection | Same | Eligible completed-order reviewer creates/edits once within seven days/withdraws; subject cannot respond | Same | `review.moderate` hide/remove/restore | Eligibility event creates state |
| Reports/evidence | Deny | Deny | Reporter creates and sees safe status/own submitted evidence | Same | `report.triage`/`report.investigate` by scope; private evidence minimized | Routing/notification only |
| Disputes/evidence | Deny | Deny | Order party opens/withdraws and sees safe case; evidence disclosure purpose-limited | Same | Scoped nonfinancial review/decision; restricted export and financial remedy unavailable | Implementation retry only |
| Account restrictions | Deny | Subject sees own safe current status | Deactivate/reactivate own account when eligible; appeal if provided | Same | `account.moderate`; cannot act on self; active orders handled individually | Scheduled expiry/review only if decision authorizes |
| Notifications | Deny | Deny | Recipient reads/marks own notifications | Same | Support cannot impersonate recipient | Creates from allowlisted outbox events |
| Outbox/deliveries/jobs/idempotency/audit/environment | Deny | Deny | Deny | Deny | Narrow diagnostic/audit read permissions; no environment mutation or audit mutation | Each named consumer accesses only its delivery rows; exact Cron/workers and reviewed provisioning |

RLS policies call small stable helper functions such as `current_profile_id()`, `has_admin_permission(code, scope_type, scope_id)`, `is_order_party(order_id)`, and `is_account_capability_allowed(code)`. Helpers are `STABLE`, use a fixed `search_path`, and never trust function parameters when an identity can be derived from `auth.uid()`.

## 4. Public projection rules

Public projections expose only:

- approved display name/avatar and coarse approved service area;
- closed-beta `Profil Mitra diperiksa` status when the manual review actually passed;
- published, moderated Jasa fields and active approved `media_renditions`;
- privacy-minimized published Permintaan fields allowed by OD-34;
- genuine completed-order review rating/body/provenance;
- real aggregate rating/count calculated only from visible genuine reviews.

They exclude internal UUID relationships where unnecessary, email/phone, exact address, auth identifiers, draft/superseded terms, offer details, participants, thread data, private storage paths, restrictions, admin identity, moderation notes, reports, disputes, evidence, audit metadata, and demo data in production.

Visitor Permintaan pages return `X-Robots-Tag: noindex, nofollow` and page metadata with the same intent. Sitemaps exclude them. This is defense in depth; it does not replace field minimization.

Thread authorization always derives from the thread's one real context FK. Participant creation is a server command triggered by explicit inquiry/response/order/case intent; revocation records actor, time, and reason. A context transition creates a linked successor thread and a fresh participant set rather than changing ownership of the old thread. Penawaran uses a dedicated Penawaran thread. There is no direct-message context or endpoint.

## 5. Command authorization

Every mutation:

1. verifies session and CSRF/same-origin properties appropriate to the transport;
2. validates the input schema and rejects unknown keys;
3. derives the actor and owned/contextual object;
4. checks account/capability restrictions;
5. checks exact administrator permission and scope if applicable;
6. locks the aggregate and reads current state/version;
7. validates the allowed transition and cross-machine preconditions;
8. performs all writes, audit, idempotency result, scheduled jobs, and outbox in one transaction.

No client can supply `actor_profile_id`, `is_demo`, `reviewed_by`, state source, permission code, price snapshot, published status, payment outcome, or audit identity as an authoritative value.

JWT issue time, token refresh, or ordinary session age is not reauthentication. Until a verified mechanism exists, permanent bans, high-risk permission grants, restricted-evidence export, financial remedies, and production-environment changes remain unavailable. Ordinary scoped moderation, including proportionate temporary restrictions and nonfinancial case handling, may continue. This is a closed-beta deny gate, not approval of OD-22.

An administrator cannot grant a permission to themselves. A grantor must already hold the authorized permission-management capability. Every successful grant and denied grant attempt is audited; high-risk grants remain unavailable until verified reauthentication exists.

### Initial administrator bootstrap

Bootstrap is deployment-controlled. The target Supabase Auth user and active, non-demo base profile must already exist. Reviewed migration/provisioning ownership supplies the exact target, permission/scope set, and `provisioning_change_ref`; the assignment has no grantor and audit actor kind is `system_provisioning`.

Runtime application roles—including ordinary users, scoped administrators, the Next.js application role, and public APIs—have no insert/execute path for provisioning-source grants. Exact replay is idempotent. Reusing a reference with another target or any expanded/reduced permission set fails and is audited. Controlled recovery uses the same reviewed path; there is no UI or administrator command.

## 6. Storage policy

### Buckets and access

All source objects are private. Public Jasa imagery is delivered only as an approved rendition, never by making the source bucket public.

| Bucket | Upload actor and context | Read actor | Additional rules |
|---|---|---|---|
| `jasa-media` | Owning eligible Mitra on a draft version | Owner/moderator; approved rendition public | Moderation required before public use |
| `message-attachments` | Active thread participant | Active participants; linked scoped admin | No open-DM or cross-thread reuse |
| `delivery-files` | Order Mitra in delivery/revision state | Order parties; linked dispute admin | Submitted version immutable |
| `local-proof` | Order Mitra in local proof state | Order parties; linked dispute admin | Strip EXIF; no GPS requirement/storage |
| `report-evidence` | Reporter or requested party in open case | Submitter and scoped case admin | Disclosure to others only by explicit safe process |
| `dispute-evidence` | Order party/admin during allowed state | Submitter and scoped dispute admin | Legal-hold aware |
| `approved-public-media` | Server derivative worker only | Public, but only active rendition paths | Generated Jasa/portfolio/Mitra-avatar derivatives only; no originals or contextual/evidence files |

There is no identity bucket or identity upload purpose.

### Upload flow

- Browser requests an upload grant with parent object, purpose, normalized filename, declared MIME/extension, and `declared_byte_size`. These are untrusted declarations used only for grant screening.
- Server verifies actor, parent state/context, current item count, and purpose allowlist; it returns a short-lived path-bound grant.
- Object path is unguessable and includes environment, purpose, parent UUID, owner UUID, and generated object UUID—not user-controlled path segments.
- Pending/uploaded rows may have `sha256=NULL`. Finalization derives actual MIME, signature, extension, `validated_byte_size`, and SHA-256 server-side, then advances `pending_upload → uploaded → validating → validated`, or ends in `quarantined`/`rejected`. `validated` is impossible unless every derived field and SHA-256 is present and allowed.
- Files are unavailable to other participants until `validated`. This is content/type validation, not a malware-scan claim.

### Allowlist and limits

The direct-upload allowlist is:

| Extension | MIME |
|---|---|
| JPEG | `image/jpeg` |
| PNG | `image/png` |
| PDF | `application/pdf` |
| TXT | `text/plain` |
| CSV | `text/csv` |
| DOCX | `application/vnd.openxmlformats-officedocument.wordprocessingml.document` |
| XLSX | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` |
| PPTX | `application/vnd.openxmlformats-officedocument.presentationml.presentation` |

The size limit is 10 MB per file. The count limit is five files per message or submission; it is not a five-file-type limit. SVG, HTML, scripts, executables, archives, macro-enabled Office files, password-protected files, and MIME/extension/signature mismatches are rejected. Large audio/video uses a typed, access-controlled HTTPS link with a safe label, access note, creator, immutable delivery version, and optional user-supplied expiration. Jasama never fetches arbitrary links server-side and does not guarantee third-party availability.

Malware scanning remains a disabled future extension point until a real scanner is selected, integrated, monitored, and reflected truthfully in policy/UI.

PDF, DOCX, XLSX, and PPTX remain disabled until a tested content validator can detect unsupported, macro-enabled, encrypted, and password-protected content. MIME/signature validation does not claim this capability.

### Approved public derivatives

The only public media bucket is `approved-public-media`. It accepts generated `media_renditions` after source validation and Jasa-version or Mitra-review approval. Bucket policy rejects originals and every message, delivery, proof, report, or dispute purpose. Active rendition URLs are version/content-addressed; replacement creates a new object and row. Revocation removes database eligibility and purges/denies cached access. Public UI falls back to an approved placeholder or no image and never to a private source URL.

Signed downloads expire quickly, are object-specific, and are issued only after a fresh authorization check. URLs, paths, file contents, and filenames are not logged.

## 7. Government-ID and future identity boundary

The closed beta may collect only contact verification, profile completeness, portfolio, and manual onboarding suitability information described in OD-13/33. It must not:

- ask for KTP, passport, driver license, family card, or other government identifier;
- accept identity-document or selfie/face-match uploads;
- store document numbers, OCR output, facial templates, ID-derived birth date/address, or verification-provider payloads;
- imply government-ID verification in UI, schema, analytics, audit, support scripts, or public copy.

Generic evidence/upload flows exclude identity purposes by enum/check and server validation. If a user attempts to upload an ID into another evidence context, operations must restrict access, remove it under the incident process, and record only a safe incident classification—not extracted identity content.

Future identity work requires a newly approved P2 decision, privacy/security/legal design, data map, retention/deletion schedule, vendor review, separate bucket/schema, and copy review. It cannot be enabled by reusing closed-beta tables.

## 8. Demo and mock-payment containment

- `app_environment=production` forces `demo_allowed=false` and `mock_payment_allowed=false`.
- Base profiles carry the authoritative demo-account marker; descendant rows inherit it. Database triggers reject production demo profiles, demo descendants, and mock-payment writes, including privileged application paths.
- Production reads still add `is_demo=false`.
- Deployment validation scans all demo-bearing tables.
- Staging shows a persistent demo banner; mixed datasets get per-object labels.
- No real payment provider credentials, network adapter, webhook, bank account, payout destination, refund command, or settlement command exists.
- Mock payment accepts only predetermined simulation scenarios and writes no provider-looking evidence.
- `app_environment` has no normal administrator UI, RLS write policy, or runtime command. Only reviewed provisioning or migration ownership may change it, and production cannot be switched to a nonproduction mode.

Any attempt to set `PAYMENT_MODE=mock` in production fails build/start and raises an alert. This is a kill switch, not a normal recoverable warning.

## 9. Audit requirements

Append `audit_events` for:

- authentication-sensitive profile/contact changes;
- Mitra and Jasa submissions/reviews;
- all 16 machine transitions, including disabled-machine creation;
- accepted terms, snapshot creation, and version conflicts;
- private-address release;
- attachment rejection/deletion and restricted evidence access;
- report/dispute decisions and implementation;
- review moderation;
- account restrictions and appeals;
- ordinary administrator grant/revoke and denied attempts to invoke unavailable high-risk permissions;
- environment/demo/mock-payment guard changes or violations;
- scheduled-job and outbox terminal failures.

Events include actor, actor kind, action, object, from/to state where relevant, reason code, permission code, request/correlation IDs, and safely hashed network/client context. They exclude secrets, tokens, exact address, message body, evidence content, full filename, raw email/phone, and free-form sensitive admin notes. Database triggers revoke update/delete on audit rows. Exact retention remains pending OD-30.

## 10. Secrets and environment management

- Vercel encrypted environment variables hold the Supabase URL/public key and server-only service-role material. No unverified step-up signing shortcut is proposed.
- Public variables use only the explicit `NEXT_PUBLIC_` set. A CI check rejects service-role, job, signing, or future-provider secrets with that prefix or in client bundles.
- Environments have separate Supabase projects/buckets/keys. Production data is never copied into development/staging.
- Rotate keys after exposure, personnel change, and on the documented schedule. Log rotation metadata, not secret values.
- Local `.env*` files are ignored; checked-in example files contain names and safe comments only.

## 11. Abuse prevention and availability

Apply account/IP-aware rate limits at sign-in, contact verification, search abuse points, message send, upload grant/finalize, offer submission, report/dispute opening, review publish, and administrative commands. Limits are stricter for anonymous and newly created accounts and return accessible recovery guidance.

Additional controls:

- normalize/bound text and render it escaped;
- use parameterized SQL only;
- protect same-origin mutations against CSRF and validate `Origin`;
- prevent SSRF by never server-fetching arbitrary delivery links;
- set CSP, HSTS, frame restrictions, referrer policy, MIME sniffing protection, and secure cookies;
- paginate and cap all lists;
- validate files asynchronously while keeping them inaccessible; malware scanning remains disabled until operational;
- use generic account-recovery responses to prevent enumeration;
- alert on brute-force, permission probing, evidence-download spikes, and invalid-transition spikes.

## 12. Privacy, deletion, and retention

Data is purpose-limited and exposed at the minimum granularity. Exact address is released only after confirmation and required mock payment; GPS is never requested. Deactivation is reversible and does not erase binding orders, safety cases, or audit history. Deletion is manual while OD-28 duration remains open.

Exact addresses are encrypted in application code before database insertion using authenticated encryption. The database stores `address_ciphertext`, `address_iv`, `address_auth_tag`, and `encryption_key_version`, with coarse locality separate. Encryption/decryption and key access are server-only. Logs exclude plaintext and every cryptographic field. Key rotation re-encrypts in a reviewed, audited transaction, verifies the new ciphertext before retiring old key use, and requires no application dependency choice in this contract.

Until exact retention is approved:

- do not promise a duration;
- mark data by retention class and legal-hold state;
- restrict access after account deactivation;
- support manual, reviewed deletion/anonymization where compatible with binding/safety obligations;
- retain no government-ID data because none may be collected;
- test that deletion does not orphan commercial snapshots or destroy append-only evidence needed for an active case.

## 13. Security release gates

Release fails if any of these are false:

- all tables have RLS enabled and deny-by-default tests;
- public projections expose only allowlisted fields;
- all administrative commands test missing/wrong-scope/self-action denial;
- service-role and private Storage credentials are absent from client bundles;
- production demo and mock-payment guards are proven;
- no identity schema/bucket/copy path exists;
- all allowed uploads pass signature/size/count tests and forbidden files fail;
- the 266 transition allowlist and conditional-decision denylist pass at the database boundary;
- audit rows cannot be updated/deleted;
- OD-29 jobs are timezone-correct, idempotent, stale-version safe, and observable.
