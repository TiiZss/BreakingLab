# GitHub Planning Conventions

## Purpose
This document defines how BreakingLab planning should be represented in GitHub issues, epics, labels, and pull requests.

## Naming
1. Epics should use `EP-XX` identifiers.
2. Roadmap work items should use `BL-XX` identifiers.
3. Pull requests should reference the related `EP-*` and `BL-*` items when applicable.

## Label Sets
### Priority
1. `priority:P0`
2. `priority:P1`
3. `priority:P2`
4. `priority:P3`

### Area
1. `area:security`
2. `area:performance`
3. `area:scalability`
4. `area:functionality`
5. `area:update-process`
6. `area:ci`
7. `area:docs`

### Scope
1. `scope:core`
2. `scope:config`
3. `scope:hooks`
4. `scope:labs`
5. `scope:release`
6. `scope:docs`
7. `scope:platform`

### Type
1. `type:epic`
2. `type:story`
3. `type:task`
4. `type:bug`
5. `type:chore`

### Platform
1. `platform:linux`
2. `platform:wsl2`
3. `platform:cross-platform`

## Epic Rules
1. Each epic must map to a roadmap phase or workstream.
2. Each epic must define scope, exclusions, acceptance criteria, and rollback expectations if relevant.
3. Each epic must identify the main BL-* items it contains.

## Work Item Rules
1. Each BL-* item must state the problem, proposed change, affected files, validation plan, and rollback plan when relevant.
2. Any configuration change must reference the configuration contract and migration path.
3. Any platform-sensitive change must include Linux and WSL2 evidence.
4. Any lab-related item must specify whether the target is project-owned, vendored, a snapshot, or a maintained fork.

## Pull Request Rules
1. Every PR should reference the roadmap artifact it advances.
2. Every PR should state whether runtime behavior, configuration contract, platform behavior, or release behavior changes.
3. Security-, config-, and update-related PRs require explicit rollback notes.

## Recommended Initial Labels
1. `priority:P0`
2. `priority:P1`
3. `priority:P2`
4. `priority:P3`
5. `area:security`
6. `area:performance`
7. `area:scalability`
8. `area:functionality`
9. `area:update-process`
10. `area:ci`
11. `area:docs`
12. `scope:core`
13. `scope:config`
14. `scope:hooks`
15. `scope:labs`
16. `scope:release`
17. `scope:platform`
18. `type:epic`
19. `type:story`
20. `type:task`

## Governance Rules
1. Do not open BL-* work without clear roadmap alignment.
2. Do not close P0 work without manual validation and rollback clarity.
3. Do not mix deep core refactors with deep lab changes in one PR unless justified.
4. Do not expand planning scope into `archive/` unless explicitly approved.
