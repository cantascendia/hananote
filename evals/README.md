# HanaNote Evals

Golden trajectory + regression + capability eval set for the
HanaNote AI agent harness. Per 手册 §35 / 铁律 #12: **no harness
config change merges to main without a covering yaml case + a
green `/cto-eval run` (or `eval-runner` sub-agent) report**.

## Layout

```
evals/
├── README.md                    # this file
├── golden-trajectories/         # canonical "this is how the CTO should behave"
│   ├── 001-r52-page-refactor.yaml
│   ├── 002-r52-forbidden-path-double-sign.yaml
│   └── 003-r52-arb-trilingual-sync.yaml
├── regression/                  # cases preventing past mistakes
└── capability/                  # cases for new capabilities (R53+)
```

## Schema

Each yaml MUST contain:

```yaml
id: NNN-short-slug             # zero-padded, kebab-case
description: one-line goal
priority: P0 | P1 | P2          # P0 = blocks merge
input:                          # the user-facing prompt or trigger
  prompt: |
    ...
  files_modified: [list]        # optional: which files prompt the case
expected_steps:                 # what the CTO SHOULD do, in order
  - step: ...
  - step: ...
forbidden_actions:              # what the CTO MUST NOT do
  - "..."
acceptance_criteria:            # quantifiable validation
  - "files_changed.includes('docs/ai-cto/HARNESS-CHANGELOG.md')"
  - "git_log_contains('Co-Authored-By:')"
```

## Running

- `/cto-eval run` (slash command, ad-hoc, single shot)
- `eval-runner` agent (parallel; runs all yamls async, reports pass/fail)

Both implementations live in `.claude/commands/cto-eval.md` and
`.claude/agents/eval-runner.md`.

## Trigger conditions (from .claude/rules/eval-gate.md)

eval gate REQUIRED before merging changes touching:
- `CLAUDE.md`
- `**/.claude/commands/*.md`
- `**/.claude/agents/*.md`
- `**/.agents/skills/*/SKILL.md`
- `**/.claude/skills/*/SKILL.md`
- `playbook/handbook.md`
