---
name: github-workflow-update
description: 'Updates GitHub Actions workflow dependencies in the current repository to the latest stable compatible versions. Use when asked to update GitHub Actions, upgrade workflow actions, refresh reusable workflow versions, or update workflow Docker images.'
---

# GitHub Workflow Update

Update versioned workflow dependencies in one repository, preserving their pinning style by default.

<Scope>
- Operate only on the current repository's `.github/workflows/*.yml` and `*.yaml` files.
- Include remote actions and reusable workflows in `uses`, Docker actions in `uses: docker://...`,
  and job or service container images.
- Leave local paths, branch refs, expressions, and floating tags such as `latest` unchanged and report
  them unless the user explicitly directs otherwise. Do not guess whether an ambiguous ref is a tag
  or a branch. Do not change unrelated dependencies.
- A fleet orchestrator may explicitly invoke or delegate this procedure with a target checkout as
  the current repository. It owns fleet scope, approvals, and aggregate reporting; this skill never
  discovers or edits other repositories and does not implicitly authorize publishing.
</Scope>

<Workflow>
<Step1>
**Inventory and establish boundaries.** Check the worktree and read the workflow files, including
existing comments on pins, relevant repository instructions, and available validation configuration.
Preserve unrelated work. If there are no workflow files or no eligible references, report that and
any skipped references with reasons, then stop. Respect the user's scope and version policy when
specified; otherwise use the defaults below.
</Step1>

<Step2>
**Resolve versions and compatibility.** For each distinct dependency:

1. Use authoritative upstream GitHub releases, tags and commit metadata, or the image registry and
   publisher's release information. Use available credentials without exposing them. Exclude
   prereleases unless explicitly requested, and releases whose provenance or version ordering
   cannot be established. For the default policy, also exclude releases of uncertain stability.
2. Select the latest stable release compatible with the repository. Include major upgrades when
   compatibility can be established; review relevant intervening release notes and migration guides
   for changed inputs, permissions, runtime, runner requirements, and other breaking changes.
3. Check that the selected action subdirectory or reusable workflow exists at the target ref. For
   images, verify the registry tag and, where applicable, the digest and required platform support.
   Do not assume the newest published tag, a floating tag, or `latest` identifies a stable release.
4. If metadata, access, release notes, or compatibility evidence is insufficient, leave the
   reference unchanged and report the dependency and reason. Never invent a version, SHA, or digest.
</Step2>

<Step3>
**Preserve the reference style.** Unless the user specifies another policy:

- Keep major-only, major-minor, and exact version tags at the same precision and retain their prefix
  and any meaningful tag conventions. Verify that a proposed moving tag resolves to the selected
  release; if it does not, leave it unchanged and report the mismatch.
- Keep commit-SHA pins as commit SHAs and image-digest pins as digests, resolving the selected
  release to its verified immutable identifier. Preserve tag-plus-digest form when present and
  update both consistently. For a SHA or digest without an identifiable current release, do not
  infer a version from the hash; report it unless the mapping can be verified.
- Preserve `owner/repo/path`, registry paths, comments, and formatting. Update version comments
  alongside changed immutable pins when they identify the old release. If equivalent pinning
  precision or verified immutable metadata is unavailable, skip and report the reference.
</Step3>

<Step4>
**Review and apply.** Present the proposed old-to-new references, evidence, breaking changes,
required compatibility edits, and skipped or blocked items. Follow the applicable interview, plan,
and approval workflow before editing; an existing fleet approval applies only within its explicit
scope. Obtain renewed approval if necessary compatibility edits materially expand that scope.
Make surgical, consistent changes to approved workflow references and approved compatibility edits.
Do not stage, commit, push, or open a pull request unless separately authorized by applicable rules.
</Step4>

<Step5>
**Validate and report.** Parse changed YAML without rewriting it, run available repository workflow
validation such as `actionlint`, and run relevant existing checks for any compatibility edits.
Check the diff for preserved unrelated content and consistent pins. Report changed references,
compatibility changes, skipped or unverifiable references with reasons, and checks passed, failed,
or unavailable. Report honestly when local checks cannot establish runtime compatibility.
</Step5>
</Workflow>

<UpdateProtocol>
If asked to change this skill's conventions, propose the exact addition or change, classify it as
required or conditional, and wait for explicit confirmation before editing this skill. After
confirmation, update its source in the appropriate dotfiles repository and remind the user to commit
the change there.
</UpdateProtocol>
