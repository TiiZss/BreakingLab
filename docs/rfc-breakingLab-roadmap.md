# RFC: BreakingLab Stabilization Roadmap

> Related documents:
> - `.github/prompts/plan-breakingLab.prompt.md`
> - `.github/prompts/plan-breakingLab-execution.prompt.md`
> - `.github/prompts/plan-breakingLab-compact.prompt.md`
> - `.github/prompts/plan-breakingLab-en.prompt.md`
> - `docs/plan-breakingLab-roadmap.md`
> - `docs/github-planning-conventions.md`
> - `docs/issue-batch-1.md`
> - `docs/planning-handoff.md`
> - `docs/README.md`

## Status
Proposed

## Context
BreakingLab delivers useful lab orchestration today, but its operational risk is concentrated in a few places: dynamic execution in the core, host mutation, fragile project configuration, weak update/rollback guarantees, and inconsistent governance over embedded labs.

The project does not need a rewrite. It needs a staged stabilization plan that reduces real risk first and only later expands into deeper maintainability work.

## Decision
Adopt a 60-90 day roadmap with the following execution order:
1. Inventory and governance.
2. Policy gates for runtime safety, scope control, and Linux/WSL2 validation.
3. Core security hardening.
4. Configuration contract plus migration path.
5. Supply chain and runtime reliability improvements.
6. Operational commands, release hardening, CI, and rollback.
7. Embedded-lab governance and targeted audits.
8. Documentation and runbook closure.

## Guardrails
1. Normal runtime paths must not install packages or add repositories.
2. Configuration changes require migration, temporary compatibility, and legacy retirement criteria.
3. Update work requires tested rollback.
4. Linux and WSL2 are explicit target platforms.
5. `archive/` is out of operational scope unless explicitly approved.
6. Third-party labs are governed primarily through reproducibility, isolation, update policy, and packaging, not deep internal refactoring by default.

## Consequences
Positive:
1. The core becomes safer and more predictable.
2. Runtime and update behavior become easier to validate.
3. The backlog becomes easier to prioritize against real risk.
4. Labs can be governed according to ownership instead of assumption.

Tradeoffs:
1. Some visible UX work is intentionally delayed.
2. Legacy compatibility must be managed explicitly during configuration migration.
3. Platform validation adds effort to each sensitive change.

## Success Criteria
1. Configuration is validated before runtime execution.
2. Linux and WSL2 are both covered for critical flows.
3. Update and install flows have rollback and post-change validation.
4. Runtime improvements are measurable.
5. Embedded labs have ownership and update policy defined.

## References
1. `.github/prompts/plan-breakingLab.prompt.md`
2. `.github/prompts/plan-breakingLab-execution.prompt.md`
3. `docs/plan-breakingLab-roadmap.md`

## Navigation
1. Read this RFC first for context and decision summary.
2. Read `docs/plan-breakingLab-roadmap.md` for the full phased roadmap.
3. Read `.github/prompts/plan-breakingLab-execution.prompt.md` when converting the roadmap into implementation work.
4. Read `docs/github-planning-conventions.md` when creating epics, issues, labels, or PRs.
5. Read `docs/planning-handoff.md` when resuming the work in a future session.
