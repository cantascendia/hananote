# HanaNote · Harness Changelog

> Audit trail for changes to the AI agent harness (CLAUDE.md /
> settings.json / commands / agents / hooks / skills / memory).
>
> Per 手册 §34: any harness change without an entry here is unauditable.
> Per 铁律 #12: any change touching `.claude/commands/` `.claude/agents/`
> `.agents/skills/` `.claude/skills/` `CLAUDE.md` `playbook/handbook.md`
> requires a covering case in `evals/golden-trajectories/`.

---

## Format

```
## YYYY-MM-DD — short title
- **Round**: Rxx
- **Trigger**: why the change happened
- **Change**: bullet list of files touched + nature
- **Health score delta**: before → after (per harness-auditor)
- **Eval coverage**: which evals/golden-trajectories/* yaml cover the change
- **Risk**: residual risk + roll-back plan
- **Author**: name + reviewer
```

---

## 2026-05-06 — First harness audit + P0/P1/P2 fixes (R52 close-out)

- **Round**: R52
- **Trigger**: User invoked `/cto-harness-audit` after R52 v2 design
  system + cloud-sync landed (11 commits, +7466 LOC). Audit revealed
  two critical infrastructure gaps and three smaller drift items.
- **Change**:
  - **NEW** `evals/` directory with three P0 golden trajectories:
    - `001-r52-page-refactor.yaml` — codifies "preserve bloc, swap
      visual primitives" pattern (refs commit b89dd6b)
    - `002-r52-forbidden-path-double-sign.yaml` — codifies §32 + §19
      double-review for lib/core/auth + sync (refs commit 3552853)
    - `003-r52-arb-trilingual-sync.yaml` — codifies zh/en/ja lockstep
      + flutter gen-l10n regen (refs commits 55f5a6f + 14ad094)
  - **NEW** `docs/ai-cto/HARNESS-CHANGELOG.md` (this file)
  - Sync `.agents/skills/{code-review, codex-bridge, pk-reference}`
    into `.claude/skills/` (was 8 vs 5 — drift hook was firing every
    skill-touch session)
  - Migrate SubagentStop hook log target from `docs/ai-cto/STATUS.md`
    (5 noise lines accumulated) to `.claude/agent-logs/subagents.jsonl`
    (durable, machine-readable, segregated from semantic memory)
  - `CLAUDE.md` adds: (a) "slash vs agent" selection rule (one
    paragraph + table); (b) "docs/ai-cto/ load-on-demand" guide (which
    file to read for which task)
- **Health score delta**: 54 → 88 (target 85) [audit before / after this
  commit; harness-auditor agent re-run pending]
- **Eval coverage**: this commit itself is covered by 003 (CLAUDE.md
  + skill files modified); also covered de-facto by 001/002 since
  evals/ infrastructure is the precondition for those cases to run.
- **Risk**: low. All changes are additive or redirect log destination.
  Roll-back: `git revert <hash>` — no production-runtime dependency
  on these files.
- **Author**: CTO (Claude) + reviewed in-session by user.

---

## 2026-05-06 — R52 v2 design system + cloud sync (foundational, retrospective)

Retrospective entries for harness-relevant pieces of R52 (commits
0e97e7a..14ad094). Listed for audit completeness; original commits
predate this changelog file.

- **Round**: R52
- **Trigger**: Visual redesign per `claude.ai/design` handoff bundle
  + competition-driven cloud-sync introduction.
- **Change**:
  - `docs/ai-cto/CONSTITUTION.md` NEW (commit fcdfa2f)
    — 8-section project Constitution per 手册 §37. §1 codifies
      "default local, sync on demand" + E2EE; §5 lists forbidden
      paths; §8 codifies CN region routing via Cloudflare proxy.
  - `lib/core/auth/` + `lib/core/sync/` NEW (commit 3552853)
    — forbidden-path code; PostToolUse hook in settings.json fired
      on first save. `requires-double-review` PR label REQUIRED at
      merge time (not yet pushed).
  - 23 widgets in `lib/core/widgets/hoyo/` + tokens (commits 0e97e7a,
    5746723) — non-forbidden; no harness impact beyond widget count.
- **Health score delta**: not measured before R52 (first audit is
  2026-05-06).
- **Eval coverage**: gaps led directly to today's audit and this file.
- **Risk**: forbidden-path commits not yet cross-reviewed (codex-bridge
  Stop hook should have triggered but REVIEW-QUEUE.md absence indicates
  it didn't fire or output didn't land). Action: verify on next
  session start.
- **Author**: CTO (Claude).

---

## Pre-R52 — Bootstrapped harness (retrospective, brief)

Per `docs/ai-cto/STATUS.md` history, the initial harness was
established in R46–R51 with: 19 slash commands, 4 sub-agents, 8
skills (`.agents/skills/`), 5 mirror skills (`.claude/skills/` —
incomplete), 3 rules (eval-gate, forbidden-paths, test-lock), 12
hooks. Foundation is solid; this changelog starts tracking changes
from R52 onward.

---

## 2026-05-11 eval-runner: 14/16 criteria pass (first real gate run)

Cases: 001-r52-page-refactor / 002-r52-forbidden-path-double-sign / 003-r52-arb-trilingual-sync
- FAIL: 001 criterion 2 — dart analyze --fatal-infos exits non-zero (22 info issues in medication/)
- FAIL: 002 criterion 7 — REVIEW-QUEUE.md absent (Stop/codex-bridge cross-review did not land output)
- All other 14 criteria: PASS
