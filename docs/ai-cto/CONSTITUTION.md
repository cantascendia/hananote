# HanaNote 花笺 · Constitution

> 不可破坏的项目约束。任何 PR 违反此文件即拒绝合并（手册 §37）。

## 1. 隐私承诺：默认本地，按需同步

旧版 v1 (≤1.2.2) 承诺「零云端」。v2 起正式重写：

> **「默认本地，按需同步」** — 你可以选择把加密备份同步到云端用于跨设备访问，
> 或保持零云端。所有云端数据用你设备上的密钥端到端加密 — 服务器只存乱码，
> 连我们也读不到。

### 强制实现

| 约束 | 不可妥协 |
|---|---|
| **opt-in** | 默认关闭云同步；首次启动必须用三选 landing 明确询问 |
| **E2EE** | `encrypted_records.ciphertext` 在客户端 Argon2id + AES-256-GCM 加密；server 永不解密 |
| **可选退出** | Profile 任何时候可一键「退出云端 → 清空 server + 拉回本地」 |
| **紧急清除** | 三连按确认后 `account-wipe` Edge Function 永久删除：cascade auth.users + 全部 records + storage |

任何修改 `lib/core/auth/`、`lib/core/sync/`、`supabase/migrations/`、
`supabase/functions/` 的 PR 必须由 CTO + 第二模型独立审一遍（手册 §32 + §19）。
Test-Lock 铁律 #14 适用：测试 read-only 锁定后只能改实现不能改断言。

## 2. 域层零依赖（DEC-042 / DEC-043）

`lib/features/*/domain/` 禁用 Flutter / 第三方 package。UI 文案通过
`enum_l10n.dart` 的 `localizedName(l10n)` 扩展。

## 3. 硬编码占位 = 未完成（铁律 #9）

任何 `// TODO`、`mock`、`placeholder` 必须有 issue 跟踪 + 截止日期。

## 4. 国际化 + 环境分离（铁律 #10）

用户可见文本必须经 ARB（zh / en / ja 三语）。Cubit/Bloc 验证消息返回
key，UI 层翻译。

## 5. 不允许 vibe coding（铁律 #13）

`lib/core/auth/`、`lib/core/sync/`、`lib/core/database/`、`lib/core/crypto/`
属于 forbidden 路径。必须 spec-driven（先 SPEC → PLAN → TASKS → 实现）。

## 6. CI 锁版

| 项 | 锁 |
|---|---|
| Flutter | 3.38.4 |
| bloc_test | ^10.0.0 |
| Supabase region | us-east（CN 用户走 §8 Cloudflare Worker 反代，非纯本地） |

## 7. 模型路由（手册 §5 / §14）

- 默认 Claude Code 直接执行（Opus 规划/Sonnet 编码/Haiku 轻量）
- 浏览器验证 / UI 设计 → 委派 Antigravity
- 隔离并行 / 自动化 → 委派 Codex

## 8. 国家可访问性 — 双区路由（v2 重写）

中国大陆用户走 **Cloudflare Worker 反代 Supabase Cloud** 的路径，**不**强制保持纯本地。

| 区域 | endpoint | 客户端路由触发 |
|---|---|---|
| Global（en/ja/其他） | `https://<project>.supabase.co`（直连） | locale 非 zh-CN |
| CN（zh-Hans-CN / zh-CN） | `https://cn-api.hrtyaku.com`（Cloudflare Worker，反代到同一个 Supabase 项目） | locale = zh-CN 或用户手动切换 |

`RegionResolver` 在 main() 启动时根据 locale + 用户 override（flutter_secure_storage）选择 region；
`HanaSupabase.ensureInitialized(region: ...)` 用对应 URL 初始化客户端。
两个 region 共用同一个 anon_key + 同一个 backend project — server 端零差异。

### Cloudflare 反代策略
- 反代 worker 在 `cloudflare-proxy/` 目录，免费 tier 100k req/day
- Cloudflare 自定义域名（cn-api.hrtyaku.com）走境外 anycast，**不需要 ICP 备案**（流量在境外 PoP 终结）
- 仅透明转发已知 Supabase 路径（`/auth/v1`、`/rest/v1`、`/storage/v1`、`/functions/v1`、`/realtime/v1`）

### PIPL 风险声明
当前阶段：服务器仍在境外（Supabase us-east），**不满足** PIPL「境内数据境内存储」要求。
本约束在用户尚未做 ICP 备案 + 公司化运营前**短期接受**。CN 用户首次登录时
Onboarding 必须显示明确告知，并允许用户选择「保持纯本地」作为知情后的退路。

R54+ 路线图：完成主体 ICP 备案后部署境内 region（阿里云 ECS + Supabase OSS Self-Hosted）+
切换 RegionResolver 默认到境内 region。

---
最后修订：2026-05-06（R52 v2 redesign + cloud sync 引入）
