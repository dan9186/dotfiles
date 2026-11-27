---
name: github-workflow-create
description: 'Designs and creates GitHub Actions workflows for the current repository, favoring Go projects and dependency-aware jobs. Use when asked to create a GitHub workflow, set up CI, build a Go pipeline, or consolidate existing workflows.'
---

# GitHub Workflow Create

Design a repository-specific workflow with independent checks and explicit job dependencies.

<Scope>
- Work in the current repository only. A future fleet orchestrator may explicitly invoke or delegate
  this procedure per checkout; it owns fleet scope, approvals, and aggregate reporting.
- Favor Go projects. For other stacks, ask the user to supply job details; do not invent commands
  or stack-specific jobs. Do not consolidate or improve existing workflows unless requested.
- Preserve unrelated files and user changes. Do not stage, commit, push, or open a pull request unless
  separately authorized by applicable rules.
</Scope>

<Workflow>
<Step1>
**Inspect the target.** Read repository instructions and relevant existing workflow files. Inspect
the project layout, Go module and toolchain settings, build and test commands, lint configuration,
Dockerfiles, compose files, and release configuration when present. Identify existing events,
filters, jobs, permissions, secrets, artifacts, and external integrations. Check required status
checks where accessible; report unknown branch protection or ruleset requirements. Do not assume
reference examples or a globally installed Go version apply to this repository.
</Step1>

<Step2>
**Propose jobs and confirm scope.** Propose jobs based on project evidence and the requested outcome,
explaining commands, events, prerequisites, and tradeoffs. Go candidates include lint, tests, build,
compose-backed integration tests, container images, and releases when supported by the project.
For non-Go projects, obtain the job details from the user. Give the user an opportunity to select,
remove, or add jobs before finalizing the design. Ask rather than guess missing commands, services,
secrets, targets, or behavioral requirements.

If existing workflows overlap, explain duplication and migration risks. Only propose editing or
consolidating them when requested; otherwise leave them intact. Follow applicable interview, plan,
review, and approval gates before editing.
</Step2>

<Step3>
**Design the dependency graph.** Put independent checks in parallel. Give build, image, publish,
and release jobs `needs` only for checks and artifacts they actually require. Add discovery or matrix
jobs only when the project needs them. Confirm the graph is acyclic and that each prerequisite can
run on the events where its dependent job is intended to run.

Review GitHub Actions conditions and skipped or failed `needs`: do not accidentally prevent a
required job from running or allow a downstream job to bypass a failed check. When consolidation is
requested, compare old and new triggers, filters, job and check names, concurrency, permissions,
artifacts, and external effects. Identify branch-protection changes or unknowns before approval;
do not silently remove or rename required checks or discard existing behavior.
</Step3>

<Step4>
**Secure external effects and choose versions.** Propose publishing or deployment only when
appropriate; confirm its triggers, target, credentials, permissions, and release behavior with the
user. Separate read-only checks from write-capable jobs, use least-privilege token permissions, and
expose credentials only to jobs that need them. Do not publish from untrusted pull requests or
expose secrets to their code; avoid privileged event patterns that execute untrusted code.

Verify stable compatible action versions with authoritative upstream release and compatibility
information. Follow the repository's existing pinning policy, or confirm one with the user if none
is established. Check runner, Go, and action compatibility. If sources, required metadata, or
credentials are unavailable, report the limitation and ask or stop instead of guessing. Creation
does not require invoking the separate workflow-update skill.
</Step4>

<Step5>
**Apply and validate.** After approval, create the approved workflow files or make the specifically
approved consolidation changes. Preserve unrelated work and avoid copying credentials or
repository-specific configuration from examples. Parse changed YAML without rewriting it, run
available workflow validation such as `actionlint`, and run relevant existing project checks.
Review the graph, event and trust boundaries, job conditions, and diff; ensure test jobs propagate
failures, including service or compose test failures.

Report files changed, jobs and dependencies, publishing behavior, migration risks or unknowns,
and checks passed, failed, or unavailable. Distinguish local validation from an actual GitHub
Actions run, and do not claim remote execution or deployment without evidence.
</Step5>
</Workflow>

<UpdateProtocol>
If asked to change this skill's conventions, propose the exact change, classify it as required or
conditional, and wait for explicit confirmation before editing the skill. After confirmation,
update its source in the appropriate dotfiles repository and remind the user to commit it there.
</UpdateProtocol>
