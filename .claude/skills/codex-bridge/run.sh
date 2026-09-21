#!/usr/bin/env bash
# codex-bridge runner — 被 Stop hook 异步调用
# 作用：跑 codex review（订阅 auth）→ 写 REVIEW-QUEUE.md → 同步到 PR comment
#       + 自动开 PR（如有未推 commits 且无 open PR）
# 文档：手册 §48 + .agents/skills/codex-bridge/SKILL.md
# 哲学：AI-native autopilot — 不询问、不打扰，能自动就自动
set +e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -z "$REPO_ROOT" ] && exit 0
cd "$REPO_ROOT"

# 0. TOCTOU 防护：mkdir 原子锁 + stale lock auto-clear (>60min)
LOCK_DIR="docs/ai-cto/.codex-bridge.lock"
mkdir -p docs/ai-cto

# Stale lock auto-clean（防止前次进程崩溃后永久阻塞）
if [ -d "$LOCK_DIR" ]; then
  LOCK_AGE=$(find "$LOCK_DIR" -maxdepth 0 -mmin +60 2>/dev/null | wc -l)
  if [ "$LOCK_AGE" -gt 0 ]; then
    rmdir "$LOCK_DIR" 2>/dev/null
    echo "$(date -Iseconds 2>/dev/null || date) | sha=$(git rev-parse --short HEAD 2>/dev/null) | mode=lock-stale-cleared | reason=lock_age>60min" \
      >> docs/ai-cto/CODEX-REVIEW-LOG.md
  fi
fi

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  # 不再 silent skip — 写 audit log（v3.7 反 silent-failure）
  echo "$(date -Iseconds 2>/dev/null || date) | sha=$(git rev-parse --short HEAD 2>/dev/null) | mode=skipped-lock-held | reason=concurrent_run" \
    >> docs/ai-cto/CODEX-REVIEW-LOG.md
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT INT TERM

TARGET="${1:-HEAD}"
SHA=$(git rev-parse "$TARGET" 2>/dev/null)
SHORT_SHA=$(echo "$SHA" | cut -c1-7)

# safe-grep：grep 退出码 0=match, 1=no-match, 2+=real error（避免静默吞错）
SAFE_GREP="$REPO_ROOT/scripts/safe-grep.sh"
[ ! -x "$SAFE_GREP" ] && SAFE_GREP=""

run_grep() {
  if [ -n "$SAFE_GREP" ]; then
    bash "$SAFE_GREP" "$@"
  else
    grep "$@" || true
  fi
}

# 1. Forbidden 路径过滤（SSOT 来自 scripts/forbidden-paths.txt）
SSOT="scripts/forbidden-paths.txt"
if [ -f "$SSOT" ]; then
  PATTERN=$(grep -v '^#' "$SSOT" | grep -v '^$' | tr '\n' '|' | sed 's/|$//')
else
  PATTERN='auth/|payment/|secrets/|migration|crypto/|infra/'
fi
FORBIDDEN=$(git diff --name-only "${TARGET}~1" "${TARGET}" 2>/dev/null | run_grep -E "$PATTERN")

if [ -n "$FORBIDDEN" ] && [ "${FORCE:-0}" != "1" ]; then
  echo "$(date -Iseconds 2>/dev/null || date) | sha=${SHORT_SHA} | mode=skipped-forbidden | reason=touched_${FORBIDDEN}" \
    >> docs/ai-cto/CODEX-REVIEW-LOG.md
  exit 0
fi

# 2. Business 路径过滤（SSOT 来自 scripts/business-paths.txt）
BIZ_SSOT="scripts/business-paths.txt"
if [ -f "$BIZ_SSOT" ]; then
  BIZ_PATTERN=$(grep -v '^#' "$BIZ_SSOT" | grep -v '^$' | sed 's|^|^|' | tr '\n' '|' | sed 's/|$//')
else
  BIZ_PATTERN='^(src|app|lib|apps|packages)/'
fi
BUSINESS=$(git diff --name-only "${TARGET}~1" "${TARGET}" 2>/dev/null | run_grep -E "$BIZ_PATTERN")

if [ -z "$BUSINESS" ] && [ "${FORCE:-0}" != "1" ]; then
  echo "$(date -Iseconds 2>/dev/null || date) | sha=${SHORT_SHA} | mode=skipped-non-business | reason=docs_or_config_only" \
    >> docs/ai-cto/CODEX-REVIEW-LOG.md
  exit 0
fi

# 3. Debounce：同 commit 不重复 review
if [ -f docs/ai-cto/CODEX-REVIEW-LOG.md ] && \
   grep -q "sha=${SHORT_SHA}.*mode=success" docs/ai-cto/CODEX-REVIEW-LOG.md 2>/dev/null; then
  echo "$(date -Iseconds 2>/dev/null || date) | sha=${SHORT_SHA} | mode=skipped-debounce | reason=already_reviewed" \
    >> docs/ai-cto/CODEX-REVIEW-LOG.md
  exit 0
fi

# 4. 检测 codex / claude / gh 可用性
HAS_CODEX=0
HAS_CLAUDE=0
HAS_GH=0
command -v codex >/dev/null 2>&1 && HAS_CODEX=1
command -v claude >/dev/null 2>&1 && HAS_CLAUDE=1
command -v gh >/dev/null 2>&1 && HAS_GH=1

# 4a. Codex 配额冷却
COOLDOWN_FILE="docs/ai-cto/.codex-quota-cooldown"
SKIP_CODEX=0
if [ -f "$COOLDOWN_FILE" ]; then
  COOLDOWN_TS=$(cat "$COOLDOWN_FILE" 2>/dev/null || echo 0)
  NOW=$(date +%s 2>/dev/null || echo 0)
  if [ "$NOW" -gt 0 ] && [ "$COOLDOWN_TS" -gt 0 ] && [ $((NOW - COOLDOWN_TS)) -lt 3600 ]; then
    SKIP_CODEX=1
  fi
fi

if [ "$HAS_CODEX" = "0" ] && [ "$HAS_CLAUDE" = "0" ]; then
  echo "$(date -Iseconds 2>/dev/null || date) | sha=${SHORT_SHA} | mode=ci_pending | reason=no_local_reviewer" \
    >> docs/ai-cto/CODEX-REVIEW-LOG.md
  exit 0
fi

# 5. 异步跑 review + PR sync
{
  TS=$(date -Iseconds 2>/dev/null || date)
  REVIEWER=""
  MODE=""
  OUTPUT=""
  STATUS=1

  # 5a. 主路径：codex review
  if [ "$HAS_CODEX" = "1" ] && [ "$SKIP_CODEX" = "0" ]; then
    OUTPUT=$(codex review --commit "$SHA" --title "ai-playbook §48 cross-model review" 2>&1)
    STATUS=$?
    if [ $STATUS -eq 0 ]; then
      # Codex exit 0 ≠ actual review happened. Detect Windows sandbox
      # failure (CreateProcessWithLogonW 1326) and "could not identify"
      # boilerplate as DEGRADED — Claude fallback should still run.
      if echo "$OUTPUT" | grep -qiE "(CreateProcessWithLogonW failed|windows sandbox:|exit code -1|could not identify any actionable defects)"; then
        MODE="codex-degraded-windows-sandbox"
        STATUS=98
        # fall through to claude fallback below
      else
        REVIEWER="codex-gpt5.5"
        MODE="success"
      fi
    elif echo "$OUTPUT" | grep -qiE "(rate.?limit|quota|exceeded|insufficient|usage.?limit|429|402)"; then
      echo "$(date +%s 2>/dev/null || echo 0)" > "$COOLDOWN_FILE"
      MODE="codex-quota-exhausted"
      STATUS=99
    else
      MODE="codex-failed"
    fi
  fi

  # 5b. Fallback 到 Claude
  if [ -z "$REVIEWER" ] && [ "$HAS_CLAUDE" = "1" ]; then
    PROMPT="按手册 §10.5 八维评审 commit ${SHORT_SHA} 的改动。先用 Bash 跑 'git show ${SHA}' 看 diff，再按八维（架构/代码质量/性能/安全/测试/DX/功能/UX）逐条 ✅⚠️🔴 + 行号。仅输出 markdown 报告，不修改任何文件。"
    CLAUDE_OUTPUT=$(claude -p "$PROMPT" --max-turns 5 2>&1)
    CLAUDE_STATUS=$?
    if [ $CLAUDE_STATUS -eq 0 ]; then
      OUTPUT="$CLAUDE_OUTPUT"
      REVIEWER="claude-fallback-opus"
      if [ "$MODE" = "codex-quota-exhausted" ] || [ "$SKIP_CODEX" = "1" ]; then
        MODE="fallback-to-claude"
      else
        MODE="claude-only"
      fi
      STATUS=0
    else
      MODE="${MODE}+claude-failed"
    fi
  fi

  # 6. 写 REVIEW-QUEUE.md（仅成功）
  if [ $STATUS -eq 0 ] && [ -n "$OUTPUT" ]; then
    {
      echo ""
      echo "## $TS — Review for $SHORT_SHA"
      echo "**Reviewer**: $REVIEWER | **Mode**: $MODE"
      if [ "$MODE" = "fallback-to-claude" ]; then
        echo ""
        echo "> ⚠️ Codex 额度耗尽（1h 冷却中），本次由 Claude 完成。**失去跨模型价值**（Claude 自审有相同认知偏差）。"
      fi
      echo ""
      echo '```markdown'
      echo "$OUTPUT"
      echo '```'
      echo ""
      echo "---"
    } >> docs/ai-cto/REVIEW-QUEUE.md
    echo "$TS | sha=${SHORT_SHA} | mode=$MODE | reviewer=$REVIEWER | bytes=${#OUTPUT}" \
      >> docs/ai-cto/CODEX-REVIEW-LOG.md
  else
    echo "$TS | sha=${SHORT_SHA} | mode=${MODE:-no-reviewer-available} | reviewer=none" \
      >> docs/ai-cto/CODEX-REVIEW-LOG.md
    exit 0  # 没 review 结果 → 后续 PR 同步无意义
  fi

  # ============================================================
  # 7. 🆕 PR autopilot — 不需要 reviewer 介入也能自动跑
  # ============================================================
  # 触发条件（全部满足）：
  #   - gh CLI 可用 + gh auth 已登录
  #   - 当前 branch 非 main/master
  #   - 至少有 1 个 commit ahead of base
  # 行为：
  #   - 若无 open PR → 自动 push + gh pr create（auto-generated title/body）
  #   - 若有 open PR → 跳过创建
  #   - 用 sha marker 防止重复 comment
  # 关闭：在 settings.local.json 关闭 Stop hook，或设 NO_PR_AUTOPILOT=1
  if [ "$HAS_GH" = "1" ] && [ "${NO_PR_AUTOPILOT:-0}" != "1" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ] && [ "$BRANCH" != "HEAD" ]; then

      # 7a. 检测 PR 是否存在
      PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null)

      # 7b. 不存在则自动开 PR（先 push）
      if [ -z "$PR_NUMBER" ]; then
        # 推 branch（首次或更新）
        git push -u origin "$BRANCH" 2>&1 | tail -3 >> docs/ai-cto/CODEX-REVIEW-LOG.md

        # 自动生成 title（从最近 commit message）+ body（从最近 commits）
        AUTO_TITLE=$(git log -1 --format=%s)
        AUTO_BODY=$(printf "## Summary\n\n%s\n\n## Recent commits\n\n%s\n\n---\n\n_由 codex-bridge autopilot 自动开启。codex review 见下方 comment。_" \
          "$(git log -1 --format=%b | head -20)" \
          "$(git log --format='- %h %s' main..HEAD 2>/dev/null | head -10 || git log --format='- %h %s' HEAD~5..HEAD)")

        gh pr create --title "$AUTO_TITLE" --body "$AUTO_BODY" 2>&1 | tail -3 >> docs/ai-cto/CODEX-REVIEW-LOG.md
        PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null)
        if [ -n "$PR_NUMBER" ]; then
          echo "$TS | sha=${SHORT_SHA} | mode=pr-autopilot-created | pr=#${PR_NUMBER}" \
            >> docs/ai-cto/CODEX-REVIEW-LOG.md
        fi
      fi

      # 7c. 同步 review 到 PR comment（按 sha 去重）
      if [ -n "$PR_NUMBER" ]; then
        MARKER="<!-- codex-bridge:${SHORT_SHA} -->"
        # 查重：用 gh api 看 comments，找 marker
        EXISTING=$(gh api "repos/{owner}/{repo}/issues/${PR_NUMBER}/comments" --jq ".[].body" 2>/dev/null | grep -c "$MARKER" || echo 0)
        if [ "${EXISTING:-0}" = "0" ]; then
          {
            echo "$MARKER"
            echo "## 🤖 Codex Cross-Model Review (\`$SHORT_SHA\`)"
            echo ""
            echo "**Reviewer**: \`$REVIEWER\` | **Mode**: \`$MODE\` | $TS"
            if [ "$MODE" = "fallback-to-claude" ]; then
              echo ""
              echo "> ⚠️ Codex 额度耗尽，本次由 Claude 完成。失去跨模型价值（同模型自审）。"
            elif [ "$MODE" = "claude-only" ]; then
              echo ""
              echo "> ℹ️ codex 未装/未登录，本次由 Claude 完成。"
            fi
            echo ""
            echo "$OUTPUT"
            echo ""
            echo "---"
            echo "_由 \`.agents/skills/codex-bridge/run.sh\` 本地跑（订阅 auth），非 CI。autopilot 自动同步。_"
          } | gh pr comment "$PR_NUMBER" --body-file - 2>&1 | tail -3 >> docs/ai-cto/CODEX-REVIEW-LOG.md

          echo "$TS | sha=${SHORT_SHA} | mode=pr-comment-posted | pr=#${PR_NUMBER}" \
            >> docs/ai-cto/CODEX-REVIEW-LOG.md
        fi
      fi
    fi
  fi
} &

disown 2>/dev/null
exit 0
