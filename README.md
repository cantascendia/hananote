<p align="center">
  <img src="assets/icon/app_icon.png" width="120" alt="HanaNote" />
</p>

<h1 align="center">HanaNote</h1>

<p align="center">
  <strong>隐私至上的跨性别 HRT 健康记录工具</strong>
</p>

<p align="center">
  <a href="./README.md">简体中文</a> &nbsp;|&nbsp;
  <a href="./docs/README_EN.md">English</a> &nbsp;|&nbsp;
  <a href="./docs/README_JA.md">日本語</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/i18n-中文%20%7C%20English%20%7C%20日本語-blue" alt="Languages" />
  <img src="https://github.com/cantascendia/hananote/actions/workflows/ci.yml/badge.svg" alt="CI" />
  <img src="https://img.shields.io/badge/encryption-AES--256--GCM-green" alt="Encryption" />
</p>

---

> *你每天唯一可以安全地与自己的身体变化互动的私密空间。*

HanaNote 是一款面向 MTF 跨性别群体的一站式 HRT 健康记录应用。全栈加密、离线优先、零数据上传。你的身体，你的数据，只属于你。

---

## 为什么选择 HanaNote？

中国大陆超过 84% 的跨性别激素使用者缺乏充分的医疗指导。HanaNote 用科学、隐私和温暖，陪你走过这段旅程。

| 特性 | 说明 |
|------|------|
| **零知识加密** | Argon2id 密钥派生 + SQLCipher 数据库 + AES-256-GCM 文件加密。没有 PIN 码，任何人都无法读取你的数据。 |
| **双引擎 PK 模拟器** | V2 + Hana-PK 两个药代动力学引擎，支持 7 种药物制剂，可用真实血检校准参数。 |
| **全功能整合** | 用药管理、血检记录、身体围度、加密相册、心情日记、跨功能时间线——一个 App 全部搞定。 |
| **用药参考** | 内置 [HRT 药典](https://hrtyaku.com) WebView，循证安全用药指南，不离开 App 即可查阅。 |
| **完全离线** | 核心功能零网络依赖，你的健康数据永远不会经过任何服务器。 |
| **三语支持** | 简体中文 / English / 日本語 |

---

## 功能一览

### 日常追踪
- **今日 Tab** — 个性化问候、服药倒计时、每日一言
- **用药管理** — 添加药物、设置方案（每日/每周/自定义）、跟踪剂量、库存预警
- **服药提醒** — 本地通知，支持全局开关和分药物控制

### 健康记录
- **血检记录** — 记录激素面板（E2、T、PRL、P4、LH、FSH、SHBG），自动标注 WPATH 目标范围
- **身体测量** — 9 个围度指标（胸围、腰围、臀围、体重等），追踪历史变化
- **加密相册** — 端到端加密的照片存储，缩略图懒解密
- **心情日记** — 每日记录 + 情绪标签

### 数据分析
- **趋势图表** — 激素指标趋势，可切换时间范围（1月 / 3月 / 6月 / 1年 / 全部）
- **PK 模拟器** — 预测注射（EV/EC/EEn）、口服、舌下、贴片、凝胶的血药浓度曲线
- **时间线** — 跨功能时间轴，自动生成 HRT 里程碑

### 隐私与安全
- **6 位 PIN + 生物识别** 解锁（指纹 / 面部）
- **Argon2id** 密钥派生（64MB 内存、3 轮迭代、4 并行度）
- **SQLCipher** 加密数据库 — 所有结构化数据静态加密
- **AES-256-GCM** 加密照片 — 内存中加密后写入磁盘，明文永不落盘
- **切换模糊遮罩** — 最近任务中隐藏 App 内容
- **紧急清除** — 一键销毁全部数据

### 应用内更新
- 启动时自动检查 GitHub Releases 新版本
- 一键下载安装

---

## 下载

### Android

从 [GitHub Releases](https://github.com/cantascendia/hananote/releases/latest) 下载最新 APK。

App 启动时会自动检查更新，有新版本时弹窗提示。

### iOS

iOS 版本计划在未来发布。

---

## 技术架构

```
Presentation (Flutter Widgets + BLoC/Cubit)
        ↓
    Domain (Use Cases + Entities + Services)
        ↓
    Data (Repository Impl + DataSources + CryptoEngine)
```

**Feature-first Clean Architecture**，10 个独立功能模块：

```
lib/features/
  auth/          # PIN + 生物识别认证
  blood_test/    # 血检记录与趋势
  journal/       # 心情日记 + Record Tab
  knowledge/     # 用药参考 (WebView)
  measurement/   # 身体测量
  medication/    # 药物管理 + 方案
  notification/  # 提醒设置
  photo/         # 加密相册
  settings/      # 个人中心 + 偏好
  simulator/     # PK 药代动力学引擎
  timeline/      # 跨功能事件聚合
```

### 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter 3.24+ / Dart 3.5+ |
| 状态管理 | flutter_bloc (BLoC + Cubit) |
| 导航 | go_router |
| 依赖注入 | get_it + injectable |
| 数据库 | sqflite_sqlcipher |
| 加密 | pointycastle (AES-256-GCM) + hashlib (Argon2id + SHA-256) |
| 安全存储 | flutter_secure_storage |
| 序列化 | freezed + json_serializable |
| 错误处理 | fpdart (Either\<Failure, T\>) |
| 图表 | fl_chart |
| 代码规范 | very_good_analysis |
| 测试 | bloc_test + mocktail |
| CI/CD | GitHub Actions |

### 设计系统

视觉语言叫做 **数码纸笺** — 一种温暖的、受动漫美学启发的设计风格，让每次打开 App 都像在精美的花笺上落笔。

- **樱色** `#864E5A` — 主色调，温柔的力量
- **薰衣草** `#745475` — 辅助色，宁静放松
- **奶油白** `#FFF8F1` — 背景色，如高级信纸
- **"无线条"原则** — 区域边界通过色调层叠定义，杜绝生硬分割线
- **玻璃拟态导航** — 毛玻璃效果底部导航栏
- **Plus Jakarta Sans** 排版体系

---

## 开发

### 环境要求

- Flutter 3.24.0+
- Dart SDK 3.5.0+
- Android SDK 34

### 快速开始

```bash
git clone https://github.com/cantascendia/hananote.git
cd hananote

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

dart analyze
flutter test
flutter run
```

### 发布

```bash
# 构建 Release APK
flutter build apk --release

# 或通过 git tag 触发 GitHub Actions 自动发布
git tag v1.0.0
git push origin --tags
# → 自动构建 APK + 创建 GitHub Release
```

---

## 参与贡献

欢迎通过 [GitHub Issues](https://github.com/cantascendia/hananote/issues) 提交 Bug 报告和功能建议。

### 提交规范

```
type(scope): description

类型: feat, fix, refactor, test, docs, chore, style
```

### 代码准则

- 严格遵守 Clean Architecture 边界
- Domain 层零 Flutter 依赖
- 所有用户可见字符串必须使用 ARB 国际化
- 新代码必须有测试
- 隐私是不可谈判的底线 — 日志和存储中不允许明文健康数据

---

## 致谢

- [estrannaise.js](https://github.com/WHSAH/estrannaise.js) — PK 模型参考
- [Transfem Science](https://transfemscience.org) — 药代动力学研究
- [HRT 药典](https://hrtyaku.com) — 循证用药参考
- [WPATH SOC8](https://www.wpath.org/soc8) — 临床指南

---

## 许可证

本项目为专有软件，保留所有权利。

---

<p align="center">
  <sub>为那些值得拥有安全空间的人，用心构建。</sub>
</p>
