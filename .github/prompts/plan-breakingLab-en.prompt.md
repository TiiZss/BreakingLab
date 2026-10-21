# BreakingLab 60-90 Day Plan

## Summary
BreakingLab needs layered stabilization, not a rewrite. The correct priority is to harden the core, formalize the configuration contract, separate normal user flows from privileged operations, validate Linux and WSL2 as an explicit workstream, and make updates, CI, and rollback predictable.

## Recommended Decision
Run a 90-day roadmap focused on core hardening, configuration governance, runtime reliability, update/release safety, and embedded-lab governance. Do not open deep modernization of third-party labs before security, contract migration, rollback, and platform validation are closed.

## Executive Priorities
1. P0: runtime safety, dynamic execution containment, configuration contract, rollback, and Linux/WSL2 validation.
2. P1: image pinning, runtime performance, contract migration, configurable networking, and minimum test coverage.
3. P2: core modularization, better logging/observability, and deeper first-party lab audits.

## Policy Gates
1. No normal usage path may install packages, add repositories, or mutate persistent host state outside install, doctor, or update flows.
2. Any mitigation of dynamic execution must cover breakinglab.sh, lib/menu.sh, lib/utils.sh, config/projects.conf, and scripts/hooks.
3. No configuration contract change may be closed without migration, temporary compatibility, and legacy mode retirement criteria.
4. Any change touching Docker, privileges, URL opening, installation, or update must be explicitly validated on Linux and WSL2.
5. archive/ is out of operational scope unless explicitly justified.

## Roadmap
1. Baseline and governance: inventory, ownership, Definition of Done, and rollback minimums.
2. Policy gates: runtime safety, Linux/WSL2 lane, and scope control.
3. Core security: hosts, hooks, menu paths, public-start paths, and dynamic execution.
4. Configuration and migration: contract, validator, and planned legacy retirement.
5. Supply chain and runtime: pinning, import policy, Docker state caching, healthchecks, networking, and resource profiles.
6. Operational quality: doctor, validate, verify, dry-run, safer updates, CI, and minimum tests.
7. Embedded labs and docs: ownership, drift resolution, targeted audits, and operational runbook.

## 90-Day Milestones
1. Milestone 1: secure core and defined configuration contract.
2. Milestone 2: faster and more reproducible runtime.
3. Milestone 3: reliable updates, CI, and operational support.
4. Milestone 4: maintainable core and governed labs.

## Delivery Rules
1. Do not mix deep core refactors with deep lab changes in the same delivery.
2. Do not close update work without tested rollback.
3. Do not close configuration work without migration evidence.
4. Do not claim platform compatibility without Linux and WSL2 validation.
5. Keep the roadmap, backlog, and execution artifacts aligned at all times.

## Main Backlog
1. Governance: BL-00, BL-01, BL-25.
2. Security: BL-02, BL-03, BL-07.
3. Configuration: BL-04, BL-05.
4. Runtime: BL-06, BL-08, BL-09, BL-10, BL-11, BL-13.
5. Release and quality: BL-14, BL-15, BL-16, BL-17, BL-18, BL-19, BL-24.
6. Labs and docs: BL-20, BL-21, BL-22, BL-23.

## Verification
1. Configuration validation before runtime execution.
2. Linux and WSL2 coverage for critical flows.
3. Update flow with rollback and post-change validation.
4. Measurable menu and startup improvements.
5. Embedded labs with ownership and update policy.

## Executive Success Criteria
The plan succeeds if BreakingLab remains easy to use while becoming measurably safer, more predictable to update, more reliable at runtime, and easier to govern as an evolving product.