# SPEC: R52-C — Cloud Sync (Encrypted Bidirectional)

> 状态: Draft (Spec-Driven, awaiting CTO sign-off)
> 作者: CTO + Tech Lead (Claude)
> 创建日期: 2026-04-28 | 关联会话: R52 系列
> 上游文档: PRODUCT-VISION.md / TECH-VISION.md / ARCHITECTURE.md / DECISIONS.md
> 关联 BACKLOG: M-34 (`docs/ai-cto/REVIEW-BACKLOG.md`)
> 计划周期: R52-C-1 (MVP) → R52-C-2 (Photo + Web) → R52-C-3 (Recovery + Conflict)

---

## 0. TL;DR

我们要给 HanaNote 加端到端加密的双向云同步，让用户换手机不丢数据；服务端永远只看到密文，密钥永不离开设备。本 SPEC 比较了 4 种架构（Supabase / Firebase / 自建 Cloudflare D1+R2+Workers / Y-CRDT 本地优先），**推荐方案 C：自建 Cloudflare Workers + D1 + R2**，因为 R51 已经有 R2 + cdn.hrtyaku.com 的运维肌肉记忆（DEC-052），且中国大陆可用性最高、锁定风险最小。MVP（R52-C-1）只同步 drugs / schedules / journals，移动端，无照片，无 Web，约 4 轮交付。

---

## 1. Context & Problem

### 1.1 现状

HanaNote 截至 v1.2.2（R51）数据完全本地化：

- **移动端**：SQLCipher（`lib/core/database/secure_database.dart`，DEC-002）+ FlutterSecureStorage（DEC-018） + 照片 AES-256-GCM 写沙盒（DEC-031）
- **Web 端**：sqlite3.wasm 直连（DEC-051），无加密层
- **导出/导入**：`ExportData` UseCase 输出 JSON 字符串、`ImportData` UseCase 解析回写（R52-A 交付），但需要用户手动操作文件
- **CDN**：仅用于版本元数据 + APK 单向下发（DEC-052），**没有任何用户数据上行**

### 1.2 用户痛点

| 场景 | 当前体验 | 期望 |
|---|---|---|
| 换新手机 | 必须先在旧机导出 JSON、传到新机、再导入；忘记导出就丢光 | 登录新机 → 自动恢复全部数据 |
| 手机丢失/损坏 | 数据完全丢失（除非提前导出） | 至少能从云端恢复，最多丢失最近一次同步前的数据 |
| Web 与 Android 双开 | 两端各一份独立数据，互不可见 | 同账号下双向看到同一份数据 |
| 照片备份 | 用户最珍惜的对比记录无任何容灾 | 加密照片云备份 |

### 1.3 为什么是现在

`docs/ai-cto/PRODUCT-VISION.md` 把 Cloud Sync 列为 v1.2.2 之后的最高价值缺口；TECH-VISION.md "如果只能做三件事" 中 Cloud Sync 设计与崩溃监控、v1.1.0 三件套并列。R52-A 已经交付 Onboarding + Import + PDF（最大信任风险已修），R52-B（崩溃监控）正在路上，R52-C 自然承接 — 用户开始信任这个 App，于是更怕换设备时丢失它。

### 1.4 与"隐私第一"愿景的张力

云同步天然引入信任面。HanaNote 的 USP 是"私密空间"（PRODUCT-VISION.md 原话），任何让服务端能看到明文的方案都是产品级否决。本 SPEC 的**第一原则**是端到端加密；第二原则才是体验。如果两者冲突，我们牺牲体验。

---

## 2. Goals & Success Criteria

### 2.1 必达 Goals (MVP, R52-C-1)

| ID | Goal | 可度量标准 |
|---|---|---|
| G-1 | 用户在新设备登录后能恢复所有 medication / schedule / journal 数据 | 端到端测试：旧机 100 条记录 → 新机登录 → 同步完成 → 100 条记录可见 |
| G-2 | 服务端永不持有明文 | 任意一个 row 的 ciphertext blob 在没有客户端密钥时无法解密；CI 检查 server schema 不含 plaintext column |
| G-3 | 加密密钥永不离开设备 | KeyManager 派生密钥从不被序列化 / 网络传输；账号注册流程 code review |
| G-4 | 中国大陆三大运营商能稳定连通 | 北上广深各采样 P95 push/pull 延迟 < 3s |
| G-5 | 离线优先 | 飞行模式下所有读写仍可用；恢复网络后自动续传 |

### 2.2 软目标 (R52-C-2/3)

| ID | Goal | 度量 |
|---|---|---|
| G-6 | 加密照片同步 | 一张 2MB 照片端到端 < 8s（4G） |
| G-7 | Web ↔ Android 双向同步 | 两端 5 分钟内可见对方变更 |
| G-8 | 账号恢复（无邮箱） | recovery phrase + PIN 重建密钥链 |
| G-9 | 冲突可恢复 | 用户能看到冲突记录，并选择保留版本（不静默丢数据） |

### 2.3 Out of Scope（明确放弃）

见 §3 Non-goals。

---

## 3. Non-goals

云同步不是"做一个云端 HanaNote"，下列功能**显式排除**，避免范围蔓延：

| 排除项 | 原因 |
|---|---|
| 多账号 / 家庭计划 | 产品定位单人私密空间，多账号会强制引入用户管理 / 计费 |
| 社交 / 评论 / 分享 | PRODUCT-VISION.md "不是社交平台" |
| 远程医疗 / 医生端 | 未来可能，但需要独立合规分析（HIPAA/PIPL/APPI） |
| 实时协作（多端同时编辑同一条记录） | 不是 HanaNote 使用场景；引入 OT/CRDT 复杂度不划算 |
| 服务端搜索 | 服务端只见密文，全文搜索本身违反 G-2 |
| 服务端衍生计算（PK 模拟、统计） | 同上，且模拟器是离线纯函数 |
| 跨用户聚合（趋势/匿名研究） | 即使去标识也违反"私密空间"信任承诺 |
| 自助账户删除等长流程 | MVP 提供"客户端删除本地 + 标记服务端逻辑删除" 即可，正式 GDPR/PIPL 流程进 R52-C-3 |
| 服务端推送（Push Notification） | 已有本地 NotificationService（DEC-022），不需要 |
| 多设备主从（设备 A 决定 B 的能见数据） | 所有同账号设备对等 |

---

## 4. Threat Model & Privacy Constraints

### 4.1 资产

- **A-1**: 用户身份信息（profile.displayName、startDate）
- **A-2**: 用药数据（drugs + schedules + medication logs，可逆推 HRT 状态）
- **A-3**: 血液检测结果（HormoneReading，强敏感医疗数据）
- **A-4**: 身体围度 + 照片（极强敏感性，对目标用户群是出柜级别风险）
- **A-5**: 日记内容（自由文本，可能包含 deadname / 家庭关系 / 心理状态）
- **A-6**: 行为元数据（同步时间、设备数、地理签名）— 即使密文，模式本身泄露信息

### 4.2 攻击者模型

| 代号 | 描述 | 能力 | 防御目标 |
|---|---|---|---|
| T-1 | 服务端运营者（含未来的我） | 完整数据库访问 + 服务端日志 | 永远只见密文；元数据最小化 |
| T-2 | 服务端被攻破（数据泄露） | 数据库 dump | 与 T-1 同；离线暴力破解成本极高 |
| T-3 | 网络中间人（运营商 / 公共 WiFi / 国家级） | 拦截 + 篡改 + 重放 | TLS + 应用层 MAC + 重放保护 |
| T-4 | 设备失窃（屏锁绕过） | 拿到解锁后的手机 | 已有 PIN+生物识别防护，不归本 SPEC |
| T-5 | 设备失窃（屏锁未绕过 + 离线） | SecureStorage / Keychain dump | 密钥用 Argon2id 派生，加上 PIN entropy |
| T-6 | 应用商店供应链 | 替换 APK | 不在本 SPEC 范围（依赖签名 + R2 校验） |
| T-7 | 同账号 evil device | 一旦获得密钥可看全部历史 | 设备列表 + 撤销 + 重新加密（R52-C-3） |

### 4.3 不可协商的不变量

> 这些是产品红线，任何实现方案违反任一条都直接否决。

- **INV-1**：服务端在任何时刻、任何接口、任何日志都不持有明文用户数据。包括：行内容、字段名（值）、文件名、photo blob。允许见到：用户 ID（随机 UUID）、密文长度、时间戳、设备 ID。
- **INV-2**：加密密钥（master key）永不离开生成它的设备的内存或 SecureStorage。同步上行的"密钥"必须是经过另一密钥包裹的密钥（key wrap，详见 §9）。
- **INV-3**：客户端在 push 前必须本地加密；在 pull 后必须本地解密。中间任何 SDK / 框架不得提供"server-side encryption" 替代。
- **INV-4**：账号注册不要求邮箱 / 手机号 / 身份证。最小用户标识：随机生成的账号 ID + 用户记忆的 password / passphrase。
- **INV-5**：服务端 schema 中所有用户内容字段名为 `ciphertext` / `nonce` / `aad`，禁止 `name` / `dose` / `mood` 等具名 plaintext column。CI 添加 schema lint。
- **INV-6**：Crash log / analytics 即便存在，也不传输任何用户数据 ciphertext 或可识别 ID 之外的内容（与 R52-B 协同）。

---

## 5. User Scenarios

### 5.1 S-1: 换设备（最重要）

**用户**：小 K，使用 HanaNote 18 个月，一台旧 Android 即将报废。

**前置**：旧机已开启云同步，账号 `hn_8f3a...`，PIN `*****`，recovery phrase 已截图保存。

**流程**：
1. 新机安装 HanaNote → 进入 Onboarding。
2. 新增分支"我已经在用了" → 输入账号 ID + PIN。
3. 客户端用 PIN + 服务端 salt 派生 master key（Argon2id），调用 `/sync/auth/challenge` 拿挑战，签名后发回 `/sync/auth/verify`。
4. 服务端确认成功后下发当前向量时钟与对象列表。
5. 客户端逐对象拉取密文，本地解密，写入新数据库。
6. 进度条显示"恢复中… 142/200"，完成后显示"欢迎回来，记录连续 543 天 ✿"。

**成功标准**：旧机的所有 drugs / schedules / journals / blood_tests / measurements 在新机完全可见，1000 条记录在 4G 网络下 < 60 秒。

### 5.2 S-2: 备份安全感（损坏 / 失窃）

**用户**：小 J，把手机掉进涩谷的便池里。

**前置**：开启云同步且账号信息（ID + recovery phrase）保存在云笔记里。

**流程**：
1. 新机 → Onboarding → "我已经在用了" → 选"我忘记 PIN" → recovery flow（R52-C-3）。
2. 输入 recovery phrase（24 词）→ 客户端用 phrase 派生 recovery key → 解密保存在服务端的 `wrapped_master_key` → 拿回 master key → 让用户设置新 PIN（用新 PIN + salt 派生 PIN-derived key 重新包裹 master key 上传）。
3. 同步 + 解密所有数据。

**成功标准**：用户能在 5 分钟内、不需要任何客服交互、恢复全部数据。

### 5.3 S-3: Web ↔ Mobile 同账号

**用户**：小 L，平时在公司用 Web 端记血检结果（公司电脑没法装 App），晚上回家在手机上看 PK 曲线。

**前置**：Web 已登录账号；Android 已登录同账号。

**流程**：
1. 公司浏览器打开 cdn.hrtyaku.com（或 PWA） → 输入账号 + PIN。
2. Web 端拉取远端，本地解密（注意 Web 用降参 Argon2 / PBKDF2，DEC-055）。
3. 录入血检 → 本地加密 → push。
4. 回家手机端 → 后台轮询发现版本变化 → pull → 解密 → BLoC 更新 UI。

**成功标准**：Web 录入后 5 分钟内 Android 端可见。注意 Web 端 KDF 强度差异，不能通过同一密码独立派生出同一密钥（见 §9）。

### 5.4 S-4: 飞行模式 → 恢复

**用户**：地铁里写日记。

**流程**：客户端始终走本地 SQLCipher；同步引擎是后台 Worker，飞行模式下队列累积；恢复网络后批量 push。

**成功标准**：用户在地铁里完全无感；恢复网络 60 秒内完成 backlog push。

### 5.5 S-5: 同账号双设备并发编辑（冲突）

**用户**：小 M，在 Web 改了昨天日记的拼写，同时手机也在改同一条日记加了一句话。

**流程（MVP, last-write-wins）**：后到的 push 更新服务端版本；先到的客户端下次 pull 时发现自己的本地 updatedAt < 服务端 updatedAt，提示"此条记录在另一台设备被更新，是否覆盖你的本地版本？"，用户选择。R52-C-3 升级为字段级 CRDT 自动合并文本字段。

**成功标准**：MVP 不丢数据（败者保留在 conflicts 表中），用户可恢复。

---

## 6. Architecture Options

我们评估了四类架构。比较维度：**隐私（端到端可控性）**、**中国大陆可用性**、**开发成本（含运维）**、**锁定风险**、**与现有栈契合度（DEC-052 R2）**。

### 6.1 Option A: Supabase

> Postgres + GoTrue Auth + Realtime + Storage，可自托管或托管在 supabase.com（AWS / Fly）。

| 维度 | 评估 |
|---|---|
| 隐私 | 客户端只 push ciphertext blob 到 `data` 表完全可行，服务端不见明文。但 Supabase Auth 默认走 email/phone — 与 INV-4 不兼容，需要自定义匿名 auth 或绕过 GoTrue。 |
| 中国大陆 | supabase.com 公网在 CN 不稳定；自托管需要单独购买中国大陆 / 香港服务器。 |
| 开发成本 | SDK + Realtime 现成，能省 30%+ 后端代码。但要写 RLS（Row-Level Security）防止用户互相读到彼此密文。 |
| 锁定风险 | 中。开源版本能自托管；schema 是标准 Postgres，迁移成本可控。 |
| 与 R2 契合 | Supabase Storage 用 S3 协议，但与 R2 重叠；需要决定保留哪个。 |
| Verdict | **替补**。技术成熟、社区活跃，但 Auth 与 INV-4 冲突的 workaround 不优雅；且与现有 R2 + Workers 路线增加新服务面。 |

### 6.2 Option B: Firebase

> Firestore + Firebase Auth + Cloud Storage，Google 托管。

| 维度 | 评估 |
|---|---|
| 隐私 | 文档级加密可行，但 Firestore 的查询模型偏向于明文索引，端到端加密会让 query 几乎全部退化为 collection scan。 |
| 中国大陆 | **致命**。Firestore + Auth 在 CN 大概率被墙；商城客户端需要 Google Play Services 才能跑 Firebase SDK，HanaNote 不依赖 GMS。 |
| 开发成本 | 极低（如果不考虑 CN）。 |
| 锁定风险 | 极高。Firestore 文档 + 安全规则全是 Google 私有 DSL，迁移基本等于重写。 |
| Verdict | **直接否决**。CN 不可用 + 锁定风险 + 与"隐私第一" 哲学不匹配（Google 数据生态信任问题）。 |

### 6.3 Option C: 自建 Cloudflare D1 + R2 + Workers

> Workers 提供 HTTP 接口；D1 (SQLite-compatible) 存元数据 + 小密文行；R2 存大密文 blob（照片）；Cloudflare Access / WAF 当边缘安全。

| 维度 | 评估 |
|---|---|
| 隐私 | 完全自控。Workers 代码我们写，schema 我们定，能严格满足 INV-1~6。 |
| 中国大陆 | R2 已经在用 cdn.hrtyaku.com（DEC-052）— 公网联通在 CN 实测可用。Workers 同一边缘网络，理论上等同。需要 R52-C-1 在北上广深做一次 P95 测量验证。 |
| 开发成本 | 中等偏高。Workers + D1 文档充足（已用于 R2 sync），但需要自己写：账号 / Auth challenge / Sync 协议 / 速率限制 / 配额。代码量估 2000-3000 行 TypeScript。 |
| 锁定风险 | **最低**。D1 是 SQLite，schema 与本地数据库同源；R2 是 S3 兼容；Workers 代码本质上是 fetch handler，迁移到 Fastly Compute / Bun.serve 都可行。 |
| 与 R2 契合 | **最高**。复用 cdn.hrtyaku.com 域名 + 现有 GitHub Actions secrets（R2_ACCOUNT_ID / KEY 已存在，DEC-059）。 |
| 成本（钱） | Workers 免费 100k 请求/天，付费 $5/千万；R2 $0.015/GB 月 + 零出口费；D1 免费 5GB。预估初期 < $20/月。 |
| Verdict | **首选**。 |

### 6.4 Option D: CRDT Local-First (Y-CRDT + S3 中继)

> 客户端用 Y.js / Automerge 维护 CRDT 状态，定期把整个 CRDT update vector 加密推到任意 S3 兼容存储。服务端只是 dumb relay。

| 维度 | 评估 |
|---|---|
| 隐私 | 极佳。服务端字面意义上的 dumb storage，连 schema 都不需要看。 |
| 中国大陆 | R2 OK。 |
| 开发成本 | **极高**。需要：(a) 把整个数据模型用 CRDT 重新建模（drugs / schedules 是简单 K-V 还好，blood test 多字段 + journal 长文本要选 Y.Map / Y.Text）；(b) 全 SQLCipher 链路与 CRDT 状态保持同步；(c) photo 不可能纯 CRDT，仍需混合。 |
| 锁定风险 | 低（标准协议）。 |
| Verdict | **未来方向，不在 R52-C 内**。冲突解决体验最好，但 4-6 轮内推全 CRDT 不现实。可在 R52-C-3 之后单独评估。 |

### 6.5 Side-by-side 总览

| 选项 | 隐私 | CN | 开发 | 锁定 | R2 契合 | 推荐度 |
|---|---|---|---|---|---|---|
| A Supabase | 良 | 中 | 低 | 中 | 中 | ★★ |
| B Firebase | 良 | **差** | 极低 | **高** | 低 | ✗ |
| C **CF Workers + D1 + R2** | 极佳 | 良 | 中 | **低** | **极高** | ★★★★★ |
| D CRDT Relay | **极佳** | 良 | **极高** | 低 | 良 | ★★（远期） |

---

## 7. Recommended Architecture (CTO 判断)

### 7.1 选定 Option C: Cloudflare Workers + D1 + R2

**一句话理由**：复用 R51 已经验证的 R2 运维路径，零新供应商，最小锁定，最大隐私可控性。

### 7.2 整体分布图

```
┌──────────────────────────── Client (Flutter) ─────────────────────────────┐
│                                                                            │
│   UI / BLoC                                                                │
│       │                                                                    │
│   Use Cases (existing) ──────────►  SyncEngine (NEW)                       │
│                                          │                                 │
│   Domain Repositories (existing)         │                                 │
│       │                                  │                                 │
│   SQLCipher / sqlite3.wasm (existing)    │                                 │
│       │                                  │                                 │
│   KeyManager (existing, DEC-060)         │                                 │
│       │                                  │                                 │
│       └─► CryptoEngine (existing) ──────►│                                 │
│                                          │                                 │
│                          ┌───────────────┴────────────────┐                │
│                          │ outbox queue (NEW table)       │                │
│                          │ vector clock (NEW table)       │                │
│                          └───────────────┬────────────────┘                │
└─────────────────────────────────────────│─────────────────────────────────┘
                                          │   HTTPS (TLS 1.3)
                                          │   Bearer: device_token
                                          ▼
┌────────────────────────── Cloudflare Workers (sync.hrtyaku.com) ──────────┐
│                                                                            │
│   Router /sync/v1/*                                                        │
│   ├─ /auth/register   POST  → D1 accounts INSERT                           │
│   ├─ /auth/challenge  POST  → returns nonce                                │
│   ├─ /auth/verify     POST  → returns device_token (24h)                   │
│   ├─ /push            POST  → batch ciphertext rows → D1 + R2              │
│   ├─ /pull            GET   → cursor-paginated ciphertext rows             │
│   ├─ /blob/:id        PUT   → R2 ciphertext put                            │
│   └─ /blob/:id        GET   → R2 ciphertext get (302 to signed URL)        │
│                                                                            │
│   Middleware: rate-limit (KV) / WAF / structured logging (no PII)          │
└────────┬─────────────────────────────┬─────────────────────────────────────┘
         │                             │
         ▼                             ▼
┌────────────────────┐         ┌──────────────────────┐
│ D1 (SQLite)        │         │ R2 (S3-compatible)   │
│ accounts           │         │ blobs/:account/:id   │
│ devices            │         │ (photo ciphertext)   │
│ objects (small CT) │         │                      │
│ vector_clock       │         │                      │
└────────────────────┘         └──────────────────────┘
```

### 7.3 设计原则

1. **客户端为主，服务端为辅**：所有业务逻辑、加密、冲突解决都在客户端。Worker 只做认证 + 持久化 + 路由。
2. **与现有架构同构**：D1 是 SQLite，schema 类比现有 SQLCipher 表 — 减少 mental load。
3. **Photo 走 R2，metadata 走 D1**：D1 有行大小限制（单行建议 < 2MB），照片密文通过签名 URL 直接 PUT 到 R2，绕开 Worker 流量限制。
4. **离线优先**：客户端永远先写本地数据库 + outbox，再异步 sync。
5. **域名规划**：`sync.hrtyaku.com` 与 `cdn.hrtyaku.com`（DEC-052）平行，独立 Worker 路由，避免 CDN 缓存策略与同步语义冲突。

### 7.4 R52-C-3 之后的演进路径

如果未来发现 Worker 上 SQL 维护成本过高，可以平滑迁移到：

- 替换 D1 为 PlanetScale / Neon（schema 兼容）
- 替换 R2 为 Backblaze B2（S3 兼容）
- 替换 Workers 为 Bun.serve self-host（fetch API 兼容）

锁定面只剩下：账号 ID 命名空间。

---

## 8. Data Model

### 8.1 同步对象清单

下表列出哪些 entity 进入同步管线。所有 ✔️ 行都按 §10 协议进行端到端加密同步。

| Feature | Entity | 表 | 同步 | 备注 |
|---|---|---|---|---|
| medication | Drug | drugs | ✔️ | MVP P0 |
| medication | MedicationSchedule | medication_schedules | ✔️ | MVP P0 |
| medication | MedicationLog (打卡) | medication_logs | ✔️ | MVP P0 |
| journal | JournalEntry | journal_entries | ✔️ | MVP P0 |
| blood_test | BloodTestReport + readings | blood_test_reports / hormone_readings | ✔️ | MVP P1 |
| measurement | MeasurementEntry | measurements | ✔️ | MVP P1 |
| photo | PhotoEntry (metadata) | photos | ✔️ | R52-C-2 |
| photo | original / thumbnail blob | filesystem | ✔️ via R2 | R52-C-2 |
| settings | UserProfile | secure storage | ✔️ | MVP P0 |
| settings | AppSettings (locale, darkMode) | secure storage | ✔️ | MVP P0 |
| settings | per-drug notification | secure storage | ❌（设备本地偏好） | 设备私有 |
| simulator | PK 推断结果 | （无落盘） | ❌ | 离线纯函数，可重算 |
| timeline | TimelineEvent | （聚合视图） | ❌ | 由其他 entity 派生 |
| notification | Pending notifications | platform | ❌ | 平台调度，不跨设备 |
| auth | PIN hash / salt | secure storage | ❌ | 见 §9 — 走特殊密钥包裹路径 |

### 8.2 Server-side Schema（D1）

```sql
-- D1 schema, sync.hrtyaku.com Worker 启动时通过 wrangler migrations 初始化
-- 严守 INV-5：所有用户内容只以 ciphertext blob 出现，没有具名字段

CREATE TABLE accounts (
  id            TEXT PRIMARY KEY,                -- 32 字节 base32 random，e.g. hn_8f3a...
  created_at    INTEGER NOT NULL,                -- epoch ms
  -- Auth material (server stores ONLY public verifier, never password)
  auth_salt     BLOB    NOT NULL,                -- 16 bytes, used for password Argon2id
  auth_verifier BLOB    NOT NULL,                -- SHA-256 of derived auth key
  -- Master key wrapping (see §9)
  wrapped_master_key BLOB NOT NULL,              -- master_key XOR-with / AEAD-with auth-derived KEK
  wrap_nonce         BLOB NOT NULL,
  -- Recovery
  recovery_verifier  BLOB,                       -- only present if recovery enrolled
  recovery_wrapped_master_key BLOB,
  recovery_wrap_nonce BLOB,
  -- Soft delete
  deleted_at    INTEGER
);

CREATE TABLE devices (
  id            TEXT PRIMARY KEY,                -- random UUID per device
  account_id    TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  created_at    INTEGER NOT NULL,
  last_seen_at  INTEGER NOT NULL,
  device_label  BLOB,                            -- ciphertext, optional client label
  revoked_at    INTEGER
);

CREATE TABLE objects (
  -- Logical key
  account_id    TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  object_id     TEXT NOT NULL,                   -- random per row, opaque server-side
  collection    TEXT NOT NULL,                   -- 'drug' | 'schedule' | 'journal' | ...
  -- Versioning
  hlc           INTEGER NOT NULL,                -- hybrid logical clock (see §10.4)
  device_id     TEXT NOT NULL,
  -- Payload
  ciphertext    BLOB    NOT NULL,                -- AEAD ciphertext (AES-256-GCM)
  nonce         BLOB    NOT NULL,                -- 12 bytes
  aad           BLOB,                            -- additional auth data (collection + object_id)
  blob_ref      TEXT,                            -- nullable; key into R2 if photo
  size_bytes    INTEGER NOT NULL,
  -- Bookkeeping
  tombstone     INTEGER NOT NULL DEFAULT 0,      -- 0/1 logical delete
  created_at    INTEGER NOT NULL,                -- server receive time
  PRIMARY KEY (account_id, object_id, hlc)
);

CREATE INDEX idx_objects_account_collection_hlc
  ON objects(account_id, collection, hlc);

CREATE TABLE vector_clock (
  account_id   TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  device_id    TEXT NOT NULL,
  hlc          INTEGER NOT NULL,                 -- highest hlc seen from this device
  PRIMARY KEY (account_id, device_id)
);

CREATE TABLE rate_limits (
  -- Just a hint table; primary rate limiting in KV namespace
  account_id TEXT,
  endpoint   TEXT,
  count      INTEGER,
  reset_at   INTEGER
);
```

### 8.3 Photo 处理（R52-C-2）

照片密文很大，**不进 D1 objects 表**：

```
PhotoEntry metadata    →  D1 objects table   (collection='photo_meta', size ~ 1KB ciphertext)
                          ciphertext 包含: id, takenAt, caption, blob_id (random)

Photo binary content   →  R2 blobs/{account_id}/{blob_id}
                          AES-256-GCM(file_key) ciphertext, where file_key
                          itself is wrapped by master_key inside the metadata ciphertext
                          (i.e. envelope encryption — server never sees file_key)
```

理由：
- D1 单行 binary 限制 + Worker request body 限制 (~100MB) 在 4MB 照片场景下没问题，但避免把热路径堵在 Worker。
- 单独 file_key per photo，意味着需要 revoke 时只需删除 metadata + R2 object，不必 re-encrypt 全部库。
- 缩略图同上，独立 blob_id（与 DEC-031 / DEC-032 一致策略）。

### 8.4 冲突解决（MVP）

**MVP（R52-C-1 / R52-C-2）：last-write-wins by HLC**

- 每条同步对象在客户端写入时更新 `updatedAt` 与 `hlc`。
- Pull 时如果发现 server hlc > local hlc 且 local 未 push 修改，直接覆盖本地。
- 如果 local 与 server 各自有未同步修改（即 local hlc 与 server hlc 同时有自己的更新），客户端在 pull 时检测到冲突，把 server 版本写入本地新表 `sync_conflicts`，UI 弹通知"此条记录在另一台设备被修改，请选择保留版本"。

**R52-C-3：字段级 CRDT（探索）**

- 文本字段（journal.content）改为 Y.Text；
- 数值字段（measurement.weight）保留 last-write-wins；
- 集合字段（drug.notes 标签）改为 LWW-Element-Set。

---

## 9. Auth & Key Model

### 9.1 设计目标

满足 INV-2/3/4：

- 账号注册零 PII（不要邮箱 / 手机号）。
- master encryption key 永不离开设备。
- 服务端能验证账号但不能解密用户数据。
- 支持账号恢复（用户能换设备，但密钥泄露需要可控）。

### 9.2 密钥架构

```
                    User PIN (string)
                        │
            Argon2id (mem=64MB, iter=3, native)
            Argon2id (lighter / PBKDF2, web — DEC-055)
                        │
                        ▼
                 PIN-derived KEK
                  (32 bytes)
                        │
        ┌───────────────┼───────────────────┐
        │               │                   │
        ▼               ▼                   ▼
  authVerifier   wrap(masterKey)    wrap(masterKey)
  = SHA-256(KEK)                    [server-side blob]
        │
        │ — uploaded once at registration
        ▼
   D1 accounts.auth_verifier      D1 accounts.wrapped_master_key

                    Master Key (32 bytes random, generated at registration)
                        │
                        ▼
          Used as SQLCipher password (existing flow)
          Used as key for AES-256-GCM (existing photo flow, DEC-031)
          Used as key for sync ciphertext envelopes
```

### 9.3 注册流程（首次开通云同步）

```
client                                                     server
  │                                                          │
  │  1. random masterKey ← CSPRNG(32B)                       │
  │  2. random salt ← CSPRNG(16B)                            │
  │  3. KEK ← Argon2id(PIN, salt)                            │
  │  4. authVerifier ← SHA256(KEK)                           │
  │  5. wrappedMK ← AES-256-GCM(KEK, masterKey)              │
  │  6. accountId ← random 32B base32                        │
  │                                                          │
  │  POST /auth/register {accountId, salt,                   │
  │                       authVerifier, wrappedMK, nonce}    │
  │  ─────────────────────────────────────────────────────►  │
  │                                                          │
  │                          server: insert into accounts   │
  │                          (no password ever sent)         │
  │                                                          │
  │  ◄───────── 200 OK + deviceId + token (24h) ──────────   │
  │                                                          │
  │  client persists: accountId locally + masterKey in cache │
  │                                                          │
  │  IMPORTANT: client shows recovery UI:                    │
  │    "Save this account ID: hn_8f3a... and your PIN.       │
  │     We cannot recover them for you."                     │
  │                                                          │
  │  Optional: if user enrolls recovery phrase:              │
  │    7. recoveryKey ← Argon2id(phrase, salt')              │
  │    8. recoveryWrappedMK ← AES-256-GCM(recoveryKey, mk)   │
  │    POST /auth/enroll-recovery {recoveryWrappedMK,        │
  │                                recoveryVerifier}         │
```

### 9.4 登录流程（已注册，登录新设备）

```
client                                                     server
  │  POST /auth/challenge {accountId}                        │
  │  ──────────────────────────────────────────────────────►│
  │  ◄─── salt, nonce ────────────────────────────────────  │
  │                                                          │
  │  user inputs PIN (UI)                                    │
  │  KEK ← Argon2id(PIN, salt)                               │
  │  authProof ← HMAC(KEK, nonce)                            │
  │                                                          │
  │  POST /auth/verify {accountId, authProof, deviceId}      │
  │  ──────────────────────────────────────────────────────►│
  │                       server: SHA256(KEK) check; HMAC?  │
  │                       returns wrappedMK if OK            │
  │  ◄─── token + wrappedMK + wrapNonce ─────────────────    │
  │                                                          │
  │  masterKey ← AES-256-GCM-decrypt(KEK, wrappedMK)         │
  │  cache locally; existing KeyManager flow takes over      │
```

注意：server-side 比对 `authProof` 而不是 `authVerifier` 直接 — 这要求 `verifier` 是 KEK 自身的 hash（INV-2: server 拿到 KEK 也只能验证身份不能反推 PIN，因为 KEK 已经经过 Argon2id 单向派生）。

### 9.5 跨设备密钥转移（B 设备已经手上有 A 的账号）

不需要。任何设备只要能正确输入 PIN 就能从 server 拿 wrappedMK 自己解开。**密钥从未离开过设备的"内存"** — 派生它的能力（PIN）才是真正的认证因子。

可选的 R52-C-3 增强：QR code pairing（A 设备显示 QR，B 设备扫描），可在不输入 PIN 的情况下完成 transfer — 但本质是 A 设备直接把 masterKey 通过 ECDH 加密传给 B 设备的临时公钥，避免 B 设备的人需要知道 PIN。这是体验优化，不是安全增强。

### 9.6 Recovery Phrase（R52-C-3）

- 用 BIP-39 词表（24 词，CN 用户可选中文版词表）。
- 客户端在用户开通时强制提示"请抄写这 24 个词"，并要求倒数验证。
- recoveryKey ← Argon2id(phrase, salt')。recoveryKey 与 PIN-derived KEK 平行，都能解开 wrappedMK 的不同副本。
- 失去 PIN → 输入 phrase → 拿回 masterKey → 用户设置新 PIN → 客户端用新 KEK 重新包裹 masterKey 上传替换。

### 9.7 Web 端密钥派生差异（DEC-055 联动）

Web 端 Argon2 降参（mem=4MB, iter=2）会导致**同一 PIN 在 Web 和 Native 派生出不同 KEK**。两种解决方案：

- **方案 1（推荐）**：账号注册阶段强制把 KDF 参数附加在 server-side `auth_salt` 旁边的 `kdf_params` 字段中。所有设备无论平台都使用 server 下发的参数。代价：所有设备的 KDF 强度被首次注册的设备决定（如果首次注册在 Web → 全部降参）。
- **方案 2**：Web 端把 Argon2 移到 WebWorker（M-32 R52 候选）+ 使用 wasm-argon2 包，恢复全参数。代价：实现成本，且首次冷启动延迟增加。

R52-C-1 采用方案 1 简化 + 提示 "尽量在移动端首次注册"；R52-C-3 升级为方案 2。

---

## 10. Sync Protocol

### 10.1 Endpoints 总览

| Method | Path | 说明 |
|---|---|---|
| POST | /v1/auth/register | 创建账号，写入 wrappedMK |
| POST | /v1/auth/challenge | 拿 salt + nonce |
| POST | /v1/auth/verify | 提交 authProof，拿 token + wrappedMK |
| POST | /v1/auth/refresh | 刷新 24h token |
| POST | /v1/auth/enroll-recovery | 注册 recovery phrase |
| POST | /v1/sync/push | 批量上传 ciphertext rows |
| GET | /v1/sync/pull?since=...&collection=... | 增量拉取 |
| PUT | /v1/blob/:blob_id | 单 blob 上传（photo 密文） |
| GET | /v1/blob/:blob_id | 重定向到 R2 signed URL |
| DELETE | /v1/sync/object/:id | 标记 tombstone（实质 push 一条 tombstone=1 的 row） |

### 10.2 Push (批量)

```http
POST /v1/sync/push
Authorization: Bearer <device_token>
Content-Type: application/cbor

{
  "device_id": "dev_a8f...",
  "rows": [
    {
      "object_id": "obj_77c...",
      "collection": "drug",
      "hlc": 1714200000000,        // hybrid logical clock from client
      "ciphertext": <bytes>,
      "nonce": <12 bytes>,
      "aad": <bytes>,              // collection + object_id, integrity-checked
      "tombstone": 0,
      "blob_ref": null
    },
    ...
  ]
}
```

Server 响应：

```http
200 OK
{
  "accepted": [obj_77c, obj_78d, ...],
  "rejected": [],                  // e.g. quota exceeded, malformed
  "server_hlc": 1714200001234      // server 的 hybrid clock，client 用作 floor
}
```

Quota：每账号每天上限 100MB ciphertext（预防滥用，未来调整）。

### 10.3 Pull (增量)

```http
GET /v1/sync/pull?since_hlc=1714199500000&collections=drug,journal&limit=200
Authorization: Bearer <device_token>
```

```http
200 OK
{
  "rows": [...],          // same shape as push input
  "next_cursor": "...",   // null if no more
  "server_hlc": 1714200002000
}
```

Cursor 分页保证 Worker 单请求响应时间稳定（< 500ms）。

### 10.4 Hybrid Logical Clock

为什么不是简单 `updatedAt`：手机时间会跳，跨时区 / 用户手动改时间会让 last-write-wins 失败。

HLC = `(physical_ms_high_48, logical_low_16)`，64-bit。客户端：

```dart
int now = DateTime.now().millisecondsSinceEpoch;
int newHlc;
if (now > _lastHlc >> 16) {
  newHlc = (now << 16);
} else {
  newHlc = _lastHlc + 1;  // logical increment, physical stuck
}
_lastHlc = newHlc;
```

服务端在收到 push 时，比较 `client_hlc` 与自己的 `server_hlc`，把更大的 (physical_ms 部分) 反馈回去 — 客户端下次刷新自己的 clock 时不能小于这个。这避免了恶意客户端伪造未来时间。

### 10.5 错误处理

| HTTP | 含义 | 客户端处理 |
|---|---|---|
| 401 | token 失效 | 自动 refresh，重试 1 次 |
| 403 | 账号被吊销 / quota 满 | 弹用户层错误 |
| 409 | hlc 冲突 | 写入 sync_conflicts，UI 提示 |
| 429 | rate limit | exponential backoff (1s → 2s → 4s ...) max 60s |
| 5xx | server 故障 | retry queue，max 1 day |

### 10.6 后台 Worker（客户端）

```
┌── SyncEngine (NEW core/sync/) ──────────────┐
│   - subscribes to outbox via stream         │
│   - timer.periodic(5min) for pull           │
│   - on connectivity_plus connected event    │
│   - photo blob upload uses isolate          │
└─────────────────────────────────────────────┘
       │
       ▼
   outbox (SQLCipher table: id, op, ciphertext, hlc, retry_count, last_error)
   inbox  (SQLCipher table: id, raw_row, decrypted=0/1)
```

注意：所有 ciphertext **生成在客户端**，outbox 存的就是已加密内容。Sync 失败重试不会重新加密。

---

## 11. MVP Scope (R52-C-1)

### 11.1 范围

| 维度 | MVP | 后置 |
|---|---|---|
| 平台 | Android only | Web 进入 R52-C-2 |
| 同步对象 | drugs / schedules / medication_logs / journals / blood_tests / measurements / profile / app_settings | photo (C-2)、tombstones 完整生命周期 (C-3) |
| 加密 | AES-256-GCM 行级 + Argon2id KDF + wrappedMK | 不变 |
| 冲突 | last-write-wins by HLC + sync_conflicts 表 + UI 提示 | 字段级 CRDT (C-3) |
| 认证 | accountId + PIN | recovery phrase (C-3) |
| 服务端 | Workers + D1 (R2 暂不用) | R2 photo blobs (C-2) |
| Quota | 100MB ciphertext / account / day | 弹性升级 |
| 设置入口 | Settings → "Cloud Sync" 开关 + "Setup new account" + "Sign in to existing" | Recovery, device list |
| 网络 | TLS 1.3，原生 http package（已用于 UpdateService） | 离线队列 + 断点续传 (C-2) |
| 错误处理 | UI snackbar + 详细错误日志（脱敏后送 R52-B 崩溃监控） | 用户能查看 sync 历史 |

### 11.2 不做 / 显式排除（MVP 内）

- Web 端任何同步代码（条件编译 stub）。
- 照片同步（即使 metadata 也不同步）。
- recovery phrase（用户必须自己保管 accountId + PIN）。
- 多设备 device label / 列表 / 撤销。
- Quota 升级流程（fail closed at 100MB）。
- 服务端 admin 工具（手工 SQL 解决）。

### 11.3 交付里程碑（4 轮）

| Round | 内容 | 验收 |
|---|---|---|
| R52-C-1.1 | Worker 骨架 + D1 schema + accounts/devices/auth + 单元测试 | curl 走通注册/登录 |
| R52-C-1.2 | 客户端 SyncEngine + outbox + push 路径 + injectable 配置 | 单设备能 push，server 见到密文 |
| R52-C-1.3 | 客户端 pull 路径 + 冲突检测 + UI 入口 + i18n | 双设备 demo：A 改数据 → B 拉到 |
| R52-C-1.4 | E2E 测试 + 北上广深 P95 测量 + 文档 + DEC-NN 写入 | dart analyze 0 / flutter test 全绿 / 性能达标 |

每轮约 1-2 天，含 review。

---

## 12. Future Iterations (R52-C-2+)

### 12.1 R52-C-2 — Photo & Web

- Photo 同步（envelope encryption + R2 blobs）
- 缩略图独立 blob，懒加载（DEC-032 一致）
- Web 端 SyncEngine（条件编译 + WebWorker 内 Argon2 — 联动 M-32）
- 断点续传 + 弱网重试（联动 M-33）

预期：3-4 轮。

### 12.2 R52-C-3 — Recovery & Conflict

- BIP-39 24 词 recovery phrase（中英日词表）
- 字段级 CRDT（journal.content / drug.notes）
- 设备列表 + 远程吊销（用户能在 Settings 看到 "iPhone 13, last seen 2026-04-22, [revoke]"）
- Quota 升级（如需 — 取决于第一波用户 ciphertext 体积分布）

预期：4-5 轮。

### 12.3 R52-C-4 — 运维 & 隐私可见性

- 服务端 admin dashboard（账号 / 用量 / 异常分布，无明文）
- 用户自助账户删除流程（GDPR / PIPL 合规）
- 透明度报告（年度发布请求统计、密钥不可读证明）

---

## 13. Risk Register

| ID | Risk | 影响 | 概率 | Mitigation |
|---|---|---|---|---|
| R-1 | 服务端被攻破，数据库 dump 流出 | 用户密文外泄 | 中 | INV-1/5 严格执行；密文 + Argon2id 离线破解成本 N×$10⁹（HanaNote 用户量级下不值得攻击）；CI lint server schema |
| R-2 | 忘记 PIN 且无 recovery phrase（MVP） | 用户永久失去数据 | 高 | MVP 完成 onboarding 时强制双重弹窗 "我们无法恢复你的账号 ID + PIN"；R52-C-3 加 recovery phrase 后概率显著降低 |
| R-3 | Web 端 KDF 降参（DEC-055）使 PIN 暴力破解可行 | Web 用户密钥强度低 | 中 | §9.7 方案 1 - 全设备统一最低参数 + 警示用户优先移动端注册；R52-C-3 升级 WebWorker 全参 |
| R-4 | hlc 时钟漂移 / 客户端伪造未来时间 | 错误覆盖正常更新 | 中 | server 校正 hlc，拒绝远超 server_hlc + 10min 的请求 |
| R-5 | Cloudflare Workers 在 CN 不稳定 | 同步频繁失败 | 中 | R52-C-1.4 必须包含真实 CN 测量（至少 4 城）；如果 P95 > 5s，启用 China-direct 备份路径或回滚到 R52-C-2 重新评估 |
| R-6 | Quota 滥用 | 单用户拖垮服务 | 低 | 100MB/day fail-closed + KV rate limit；账号注册需要 PoW（极简）防 sybil |
| R-7 | Photo 同步流量成本失控（R52-C-2） | R2 月费爆炸 | 中 | R52-C-2 启动前必须重新建模流量（按 1k 用户 × 50 photos × 2MB = 100GB ≈ $1.5 R2 可接受） |
| R-8 | 合规风险（PIPL / GDPR / APPI） | 法律风险 | 低 | 端到端加密 + 无 PII 注册 + 用户自删除（C-4）; 但仍需国家政策追踪 — China 数据出境法可能要求境内服务器（届时考虑迁到 Hangzhou Workers 或 ECS） |

---

## 14. Open Questions for CTO

> 这些是必须人类 CTO 拍板的硬权衡，不能 Agent 默认决定。

### Q-1: Recovery Phrase 强制还是可选？

- 强制：用户首次开通时必须抄写 24 词，不抄写不让继续。**影响**: 流失率上升（用户嫌麻烦），但 R-2 概率显著降低。
- 可选（MVP 默认）：用户 opt-in，但有醒目警示。**影响**：用户友好，但一旦丢失 PIN 无法恢复。

我的倾向：**MVP 可选 + 强警示，R52-C-3 改强制**。理由：MVP 阶段用户已经接受过 Onboarding（R52-A），再加一道 24 词强制门槛会让"换设备恢复"这个核心价值在第一次接触时就被浇灭。

### Q-2: 服务端地理位置 — Cloudflare 全球 vs 中国大陆境内 vs 香港

- Cloudflare 全球 (Workers + D1)：默认；CN 大陆访问走 Anycast，**可能**触发 PIPL 数据出境义务（HRT 数据可能被认定为敏感个人信息）。
- 中国大陆境内（阿里云 / 腾讯云）：合规但需要 ICP 备案、与隐私第一愿景的"国家级攻击者也看不到明文" 形成 PR 张力。
- 香港自托管：折中，但运维成本陡增。

我的倾向：**Cloudflare 全球 + 法务文件明确"端到端加密下境内出境争议"**。不是技术问题，是商业风险问题。

### Q-3: 同步范围 — 全部 entity 还是分级订阅？

MVP 默认同步所有 entity。但用户可能想"只同步 medication 不同步日记"（日记最敏感）。

- 全部同步：UX 简单，但用户被迫 trust all-or-nothing。
- 分级订阅：UI 复杂，但用户能微调。

我的倾向：**MVP 全部，R52-C-3 加分级**。理由：MVP 用户量不足以反馈分级需求，过早加 UI 反而困惑。

### Q-4: 关闭云同步时怎么处理服务端数据？

- 选项 A：保留服务端密文（用户重新开通时直接同步回来）。
- 选项 B：立即标记 tombstone，30 天后物理删除。
- 选项 C：用户选（"暂停" vs "彻底注销"）。

我的倾向：**C（暂停 vs 注销）**。"暂停"对应 A，"注销" 对应 B。这是产品级决策（信任承诺），不是技术决策。

### Q-5: 计费模型？

MVP 不收费（在我们个人成本预算内）。但当用户量上升或照片同步开启后：

- 完全免费：成本可能压垮项目（可持续性风险）。
- 订阅制（$2-5/月解锁照片同步）：违反"工具不收用户钱" 的初心？
- 一次性买断：体验好但用户基数小则收入有限。

我的倾向：**MVP + R52-C-2 完全免费；用量上来后再引入"赞助" 模式（非订阅，类似 Wikipedia）**，避免商业引入信任损耗。但这是 v1.3+ 的事。

---

## 附录 A: 与现有 DEC 的关系

| DEC | 关系 |
|---|---|
| DEC-002 安全第一 | 本 SPEC 全文遵循；INV-1/2/3 是其延伸 |
| DEC-006 隐私增强 | 同向；剪贴板 / blur / 备份密钥分离不变 |
| DEC-012 Argon2id | §9.2/9.7 直接复用 native 参数；Web 参数与 DEC-055 联动 |
| DEC-031 Photo crypto | §8.3 envelope encryption 设计沿用其内存加密原则 |
| DEC-032 Photo thumbnail cache | §8.3 缩略图独立 blob 一致 |
| DEC-051 sqlite3.wasm | Web 同步的本地存储仍然走 wasm 直连 |
| DEC-052 R2 CDN | §7.2 sync.hrtyaku.com 与 cdn.hrtyaku.com 平行；复用 secrets |
| DEC-055 Web Argon2 降参 | §9.7 方案 1 需要在 D1 accounts.kdf_params 字段记录参数 |
| DEC-059 CI/CD 三流水线 | sync Worker 部署作为第 4 个工作流（wrangler deploy on push to main） |
| DEC-060 KeyManager hash 升级 | §9 沿用 verifier-not-key 模式 |
| DEC-062 Web 平台条件导入 | SyncEngine 走相同模式 (`sync_engine_native.dart` / `sync_engine_web.dart`) |

## 附录 B: 待新增 DEC

R52-C-1 落地后写入：

- DEC-NN: Cloud Sync 选型 — Cloudflare Workers + D1 + R2
- DEC-NN+1: 端到端加密密钥架构 — PIN-derived KEK wraps masterKey on server
- DEC-NN+2: 同步协议 — HLC + last-write-wins (MVP)
- DEC-NN+3: 账号模型 — 零 PII，accountId + PIN，可选 recovery phrase

## 附录 C: 验收清单（R52-C-1 Definition of Done）

- [ ] `dart analyze --fatal-warnings` 通过
- [ ] `flutter test` 全绿（新增至少 30 个 sync engine 单元测试）
- [ ] CI 锁版 Flutter 3.38.4 不变
- [ ] 客户端 SyncEngine 在飞行模式下正常入队、恢复网络后清空 outbox
- [ ] 双设备 demo：A 写 100 条 → B 拉到 100 条 一致
- [ ] CN 测量：北上广深 P95 push < 3s, pull < 3s
- [ ] 服务端 D1 schema 通过 INV-5 lint
- [ ] 没有任何 master key 离开设备的代码路径（manual code review + grep）
- [ ] i18n 中英日三语完成（`l10n/arb/app_*.arb` 新增约 15 keys）
- [ ] 文档：DEC 写入 + REVIEW-BACKLOG M-34 状态从 ⏳ → ✅
- [ ] 隐私页（DEC-058）补充云同步章节

---

> 本文档是 R52-C 系列的契约。任何实现偏离本 SPEC 必须先更新 SPEC，再写代码。
> Spec-Driven 不允许"先做了再改文档"。


## 附录 D: 2026-05-06 ARE 审计修复（实现合规）

post-R52 reliability-auditor (handbook §43) flagged 3 places where the
initial implementation diverged from this SPEC. None of the SPEC's
contracts changed — only the code was brought into alignment.

| # | SPEC 原条款 | 偏离 | 修复 |
|---|---|---|---|
| D-1 | §10.2 — 服务端必须返回 `accepted: [obj_77c, obj_78d, ...]`（ID 数组） | `supabase/functions/sync-push/index.ts` 返回 `accepted: <count>`（数字）；客户端 `sync_engine.dart` `markClean(dirty.map(.id))` 把全部 dirty 一刀切标 clean，partial-ack 丢数据 | sync-push 改返 `accepted: [id, id, ...]` + `rejected: [...]`；sync_engine 改用 List<String> 仅 markClean 服务端确认的；老的数字格式 fallback 为「保守全保留 dirty」+ telemetry 报 `legacy_count_response_no_ids` |
| D-2 | §10.6 — 客户端 inbox 用 `decrypted=0/1` 标记，单条坏记录留待 R53 manual recovery | sync_engine pull 路径在第一条 GCM-tag mismatch / nonce corrupt 直接 `return Left(SyncCryptoFailed)` → 整批拉取 abort + 后续每次 pull 在同位置再 abort | sync_engine 改为 per-record try/catch；失败 ID 进 `decryptFailedIds`，cursor 推进；telemetry 累计 `decrypt_fail` |
| D-3 | §43.4（手册） — 必须有 silent-failure detection；SPEC 验收清单 §C 提到「双设备 demo」但缺持久化遥测 | 无 last_successful_sync_at、无 counter、无 fail reason 持久化 → 用户感知不到 stall | 新文件 `lib/core/sync/sync_telemetry.dart`：FlutterSecureStorage 持久化 last_push_ok_at / last_pull_ok_at / last_failure_reason + at；内存 counter（push_ok/fail、pull_ok/fail、decrypt_fail、totalAccepted/Applied/Rejected）；Profile UI 后续读 `lastSuccessfulSyncAt()` 渲染「上次同步 X 分钟前」 |

修复 commits（feat/r52-hoyo-redesign）：将在 ARE-fix commit 中一并落地。

> 这是 SPEC-Driven 流程的正向闭环范例：审计 → 发现偏离 → 修代码（不改 SPEC）。


## 附录 E: MedicationSyncQueue 实现规范（R52-C-1 prototype）

> Plan agent 2026-05-11 设计。这是 4 个 feature 模块 SyncQueue 真实实现的
> **原型** — journal / measurement / blood_test 按此模式复制。
>
> 状态：spec 完成，代码未落地。Per CONSTITUTION §5：本附录必须先合并；
> 然后才能动 `lib/features/medication/data/sync/` 和 schema 迁移。

### E.1 Schema delta

3 张本地 SQLCipher 表添加 sync 元数据列：

| 表 | 新列 | 类型 | 默认 |
|---|---|---|---|
| drugs | dirty | INTEGER | 0 |
| drugs | synced_at | TEXT | NULL |
| drugs | is_deleted | INTEGER | 0 |
| drugs | updated_at | TEXT | NOT NULL（backfill = created_at） |
| medication_schedules | 同上 4 列 | 同 | 同 |
| medication_logs | 同上 4 列 | 同 | 同 |

`drug_inventory` **本轮不同步**（per-device 消耗追踪；R53 再决定）。

新增部分索引：`CREATE INDEX idx_<table>_dirty ON <table>(dirty) WHERE dirty=1;`

### E.2 写入规则

`medication_repository_impl.dart` 每次 mutation：
- `addX / updateX` → `dirty=1, updated_at=now()`
- `deleteX` → **软删**：`UPDATE ... SET is_deleted=1, dirty=1, updated_at=now()`（避免删除-同步竞态）
- 所有 SELECT 查询新增 `WHERE is_deleted=0` 过滤

### E.3 SyncedRecord payload 契约

```json
{ "table": "drugs" | "medication_schedules" | "medication_logs",
  "op": "upsert" | "delete",
  "row": <DrugModel.toJson() | …> }
```
- `SyncedRecord.kind = "medication"`（与 supabase enum 单值）
- `SyncedRecord.id = row.id`（域 UUID 直接复用，无需新 ID 空间）
- `SyncedRecord.occurredAt = row.updated_at`（喂 ConflictResolver）

### E.4 applyRemote 算法

1. 按 `payload.table` 路由到本地表
2. `SELECT WHERE id = ?`
3. 若本地无 → INSERT（dirty=0）
4. 若本地有 → 调 `ConflictResolver.remoteWins(local, remote)`：
   - true → overwrite（dirty=0）
   - false → 保留本地（仍 dirty=1，下次推）
5. 若 `op = "delete"` 且远端胜 → `UPDATE SET is_deleted=1, dirty=0`

### E.5 DI 模式：SyncQueueRegistry composite

新增 `lib/core/sync/sync_queue_registry.dart`。它**本身实现 SyncQueue**：
- `takeDirty()` → 聚合所有注册 queue 的脏行
- `markClean(ids)` → 按 id 路由回各自的 queue
- `applyRemote(record)` → 按 `payload.table` 派遣

`SyncEngine` 构造参数仍是 `SyncQueue`（registry 透明）。新增 feature 模块时只需注册自己的 queue 实现，不改 SyncEngine。

### E.6 任务清单（atomic，依赖序）

| # | 任务 | 测试 |
|---|---|---|
| T-1 | 新增 migration 004：ALTER 3 表 + bump DB version 3→4 + 双路（initial / upgrade）| migration_004_test.dart（v3 → v4 数据无损） |
| T-2 | `medication_tables.dart` DDL 同步加列（fresh install）| secure_database_test 扩展 |
| T-3 | DrugModel / MedicationScheduleModel / MedicationLogModel 加 dirty/updatedAt/isDeleted（freezed regen）| JSON round-trip |
| T-4 | `medication_local_datasource.dart`：插入/更新置脏；删除→软删；查询过滤 is_deleted=0 | datasource test |
| T-5 | 新增 `lib/features/medication/data/sync/medication_sync_queue.dart` | takeDirty / markClean / applyRemote 全路径 |
| T-6 | 新增 `lib/core/sync/sync_queue_registry.dart` composite | registry routing |
| T-7 | DI：`injectable.config.dart` 把 NoopSyncQueue → registry + medication queue | injection_test |
| T-8 | （本附录 = T-8）E2EE round-trip 测试 medication payload | e2ee_codec_medication_test |

### E.7 风险（CONSTITUTION 引用）

- **PII 泄漏**（§1）：DrugModel.toJson 含药名等敏感字段；payload 经 codec 已加密；但任何 `debugPrint(record)` 都会泄漏。Mitigation：lib/features/medication/data/sync/ 内禁止 print/debugPrint（CI grep gate）。
- **Nonce 重用**：`E2eeCodec._randomBytes(12)` 用 `Random.secure()` 每记录新 nonce；12 字节 birthday bound 2^48 messages 安全。Web 端需验证 routes 到 `crypto.getRandomValues`。
- **迁移数据丢失**：`ALTER ADD COLUMN` 无损；`updated_at` backfill 用 `COALESCE(created_at, now())`；migration_004_test 必须断言行数前后相等。
- **Mark-clean-before-ack**：ARE-fix D-1 已保证 sync_engine 只用 server `acceptedIds` 标 clean；本设计直接消费此契约（无捷径）。
- **§5 forbidden path**：本附录 + T-1..T-8 全部触及 `lib/core/sync/` + `lib/features/medication/data/`，PR 必须打 `requires-double-review` 标签 + 第二模型审。

### E.8 Out of scope（本附录不做）

- 照片同步（kind='photo'，R2 envelope crypto — 见 §8.3）
- Realtime push（R53+）
- journal / measurement / blood_test queue 实现（复制模式后续）
- Conflict UI 提示（纯 LWW，无对话框）
- drug_inventory 同步
- Tombstone 物理清除（is_deleted=1 永久留存 MVP；R53 加 GC）
- HLC 时钟（§10.4 — 当前 `updated_at` 时间戳即可；HLC 后置迁移）

### E.9 Definition of Done（追加到 §C）

- [ ] migration 004 跑通 fresh + upgrade（断言 SQL 不变错误）
- [ ] medication_sync_queue_test 全绿（含 conflict matrix 6 cases）
- [ ] e2ee_codec 双端 round-trip：Drug + Schedule + Log + delete payload
- [ ] 双设备 demo：A 增删改 → B 拉到一致状态
- [ ] dart analyze --fatal-warnings 0
- [ ] 不破坏 324/324 baseline
- [ ] CONSTITUTION §5 PR 标签 `requires-double-review` 应用
