# Codex Phase Prompts

Replace bracketed values. Each template is intentionally phase-bound; it does
not authorize work in later phases or changes to approved authorities.

## 1. Plan one phase

```text
Plan Phase [N — name] only. Do not implement it.

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, then the Phase [N] entry in
docs/IMPLEMENTATION_PLAN.md and every source document it names. Inspect the
existing repository before proposing new files or dependencies. Do not silently
change approved requirements, decisions, states, or transition pairs.

Map the phase objective to concrete deliverables, ordered migrations, commands,
RLS, tests, observability, demo behavior, security, accessibility, entry/exit
evidence, and recovery. Identify blockers instead of approving P1/P2 behavior.
Run any applicable read-only checks. Report files changed (expected: none),
checks run, failures, assumptions, and remaining blockers. Stop at the Phase
[N] boundary.
```

## 2. Implement one phase

```text
Implement only Phase [N — name].

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, then the selected phase and every relevant authority
and contract named there. Inspect existing files before creating anything and
reuse the smallest approved pattern. Do not silently change approved
requirements, decisions, states, transition pairs, or phase scope.

Meet the phase entry gate before editing. Implement only its in-scope database,
application, command/RPC, RLS, observability, demo, security, accessibility, and
test work. Add no speculative later-phase foundation unless the plan explicitly
justifies it. Run every applicable scheduled check. Report exact files changed,
tests/checks run, failures, assumptions, and remaining blockers. Demonstrate
the exit-gate evidence, or state why it is unmet. Stop at the Phase [N]
boundary and do not begin the next phase.
```

## 3. Audit a completed phase

```text
Audit completed Phase [N — name]; do not implement later phases.

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, the phase plan, its named source documents, and the
actual diff/files. Inspect existing implementation and generated artifacts
before suggesting new work. Do not reinterpret or silently change approved
requirements, decisions, states, or transition pairs.

Check every phase field and entry/exit gate, migration order, command atomicity,
RLS, tests, observability, demo/production separation, security, accessibility,
and recovery. Run all applicable scheduled checks. Give evidence-backed
findings in severity order with file/line references. Report files changed
(none unless explicitly asked), checks/tests run, failures, assumptions, and
remaining blockers. Stop at the Phase [N] boundary.
```

## 4. Fix a failed test

```text
Fix this failure within Phase [N — name] only:
[paste command and failure]

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, the selected phase, the relevant source contracts,
and the failing test. Inspect the implementation and every caller/shared path
before editing. Do not weaken the test or silently change approved requirements,
decisions, states, transition pairs, RLS, or security behavior.

Find the root cause and make the smallest correct phase-local fix. Add or adjust
only the regression coverage required by that cause. Re-run the failing check
and all applicable scheduled checks affected by the change. Report exact files
changed, tests/checks run, failures, assumptions, and remaining blockers. Stop
at the Phase [N] boundary.
```

## 5. Review an SQL migration

```text
Review migration [path] for Phase [N — name]. Do not apply or rewrite it unless
explicitly requested.

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, the selected phase, DATABASE_SCHEMA.md,
SECURITY_RULES.md, API_EVENTS_AND_JOBS.md, TEST_STRATEGY.md, and the relevant
authorities/state contracts. Inspect prior migrations and generated types
before assessing this file. Do not silently change approved requirements,
decisions, states, transition pairs, or create later-phase tables.

Check forward-only safety, ordering, exact types/FKs/checks/uniqueness/indexes,
immutable/audit rules, demo-production guards, grants/RLS, idempotent deployment,
lock/recovery risk, and type regeneration. Run applicable static, migration,
unit, and RLS checks available for this phase. Report findings with file/line
evidence, exact files changed, checks/tests run, failures, assumptions, and
blockers. Stop at the Phase [N] boundary.
```

## 6. Review RLS

```text
Review RLS for [tables/feature] within Phase [N — name] only.

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, the selected phase, SECURITY_RULES.md,
DATABASE_SCHEMA.md, API_EVENTS_AND_JOBS.md, TEST_STRATEGY.md, and relevant
product/state contracts. Inspect existing policies, grants, functions, Storage
policies, and tests before proposing changes. Do not silently change approved
requirements, decisions, states, transition pairs, or trust boundaries.

Build an actor-by-operation matrix and test deny-by-default, ownership,
participation, scope, self-action, demo/production, service-role, provisioning,
private-file, and revoked-access cases. Treat signed URLs as delivery, not
authorization. Run every applicable RLS and scheduled check. Report findings
with evidence, exact files changed, tests/checks run, failures, assumptions,
and blockers. Stop at the Phase [N] boundary.
```

## 7. Review accessibility

```text
Review accessibility for [journey/components] in Phase [N — name] only.

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, DESIGN.md, the selected phase, and its relevant
product/PRD/homepage/test documents. Inspect the rendered implementation and
existing tests before creating anything. Do not silently change approved copy,
hierarchy, interaction requirements, decisions, states, or phase scope.

Check semantics, landmarks/headings, labels/instructions/errors, keyboard order
and traps, solid focus indicators, dialogs, live status, contrast, zoom/reflow,
touch targets, reduced motion, Indonesian copy, and loading/empty/error states.
Run applicable automated and manual checks plus scheduled phase checks. Report
evidence-backed findings, exact files changed, tests/checks run, failures,
assumptions, and blockers. Stop at the Phase [N] boundary.
```

## 8. Review security

```text
Review security for [journey/command] in Phase [N — name] only.

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, the selected phase, SECURITY_RULES.md,
TECHNICAL_SPEC.md, DATABASE_SCHEMA.md, API_EVENTS_AND_JOBS.md,
TEST_STRATEGY.md, and relevant authorities/state contracts. Inspect existing
code, migrations, policies, grants, tests, and data flow before suggesting new
controls. Do not silently change approved requirements, decisions, states,
transition pairs, or enable gated behavior.

Threat-model authorization, validation, transaction/idempotency, audit/outbox,
secrets, privacy, storage, uploads, environment kill switches, abuse/rates,
logging, and recovery. Verify privileged and provisioning paths are server-only
and inaccessible at runtime. Run applicable security, RLS, unit, E2E, and build
checks. Report evidence-backed findings, exact files changed, checks/tests run,
failures, assumptions, and blockers. Stop at the Phase [N] boundary.
```

## 9. Run Impeccable critique and polish

```text
Use the Impeccable skill to critique and, only if requested, polish
[page/journey] within Phase [N — name].

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, DESIGN.md, the selected phase, and all relevant
product/PRD/homepage/test documents before acting. Inspect existing components,
styles, states, responsive behavior, and rendered output before creating files.
Do not silently change approved requirements, copy constraints, hierarchy,
decisions, states, transition pairs, or add later-phase functionality.

Evaluate hierarchy, information architecture, cognitive load, typography,
spacing, color/focus, responsive behavior, accessibility, performance, natural
Indonesian copy, empty/loading/error states, and design-token reuse. Preserve
security and data boundaries. Run applicable visual, accessibility, E2E, and
scheduled checks. Report exact files changed, tests/checks run, failures,
assumptions, and blockers. Stop at the Phase [N] boundary.
```

## 10. Prepare the next phase

```text
Assess readiness for Phase [N — name] without implementing it.

Read AGENTS.md and relevant source documents. Work only in the selected phase.
Inspect existing files before creating new ones. Do not silently change approved
requirements. Run applicable checks. Report exact files changed, tests run,
failures, assumptions, and remaining blockers. Stop at the requested phase
boundary.

Read AGENTS.md completely, the target phase, the completed prior-phase records,
and every source document named by the target phase. Inspect existing files,
migrations, generated types, test results, approvals, and open blockers before
proposing anything. Do not silently change approved requirements, decisions,
states, transition pairs, dependencies, or gate status.

Verify the prior exit gate and target entry gate with evidence. List required
approvals, environments, secrets/providers, data, migration sequence, commands,
RLS/tests, observability, security, accessibility, rollback readiness, and
unresolved P1/P2 gates. Run applicable read-only/scheduled checks. Report files
changed (expected: none), checks/tests run, failures, assumptions, and remaining
blockers. Stop at the requested readiness assessment; do not begin Phase [N].
```
