<p align="center">
  <img src="../assets/icon/app_icon.png" width="120" alt="HanaNote" />
</p>

<h1 align="center">HanaNote</h1>

<p align="center">
  <strong>Privacy-first HRT health tracker for the transgender community</strong>
</p>

<p align="center">
  <a href="../README.md">简体中文</a> &nbsp;|&nbsp;
  <a href="./README_EN.md">English</a> &nbsp;|&nbsp;
  <a href="./README_JA.md">日本語</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/i18n-中文%20%7C%20English%20%7C%20日本語-blue" alt="Languages" />
  <img src="https://github.com/cantascendia/hananote/actions/workflows/ci.yml/badge.svg" alt="CI" />
  <img src="https://img.shields.io/badge/encryption-AES--256--GCM-green" alt="Encryption" />
</p>

---

> *Your safest private space to track your body's journey.*

HanaNote is a full-featured, offline-first health tracking app built for MTF transgender individuals undergoing hormone replacement therapy. Every byte of your data is encrypted. Nothing leaves your device.

---

## Why HanaNote?

Over 84% of transgender hormone users in China lack adequate medical guidance. HanaNote bridges that gap with a scientific, privacy-obsessed, and emotionally warm companion app.

| Feature | |
|---|---|
| **Zero-knowledge encryption** | Argon2id key derivation + SQLCipher database + AES-256-GCM file encryption. Your data is unreadable without your PIN. |
| **Dual PK simulator** | Two pharmacokinetic engines (V2 + Hana-PK) predict blood estradiol levels across 7 drug preparations. Includes MAP calibration against real blood tests. |
| **All-in-one tracking** | Medications, blood tests, body measurements, encrypted photos, mood journals, and a cross-feature timeline -- in a single app. |
| **HRT drug reference** | Built-in evidence-based safety guide from [HRT Yakuten](https://hrtyaku.com), accessible without leaving the app. |
| **Offline-first** | Core functionality requires zero network access. Your health data never touches a server. |
| **Tri-lingual** | Chinese, English, and Japanese. |

---

## Features

### Daily Tracking
- **Today Tab** -- personalized greeting, medication schedule with countdown timers, daily motivational quotes
- **Medication management** -- add drugs, set schedules (daily/weekly/custom), track doses, monitor inventory
- **Notification reminders** -- scheduled local notifications with per-drug control

### Health Records
- **Blood test logging** -- record hormone panels (E2, T, PRL, P4, LH, FSH, SHBG) with WPATH target range indicators
- **Body measurements** -- track 9 measurement types over time
- **Encrypted photo journal** -- end-to-end encrypted photo storage with thumbnail caching
- **Mood diary** -- daily journal entries with mood tracking and tags

### Analysis
- **Trend charts** -- hormone level trends with configurable time ranges
- **PK Simulator** -- predict blood drug concentrations for injections, oral, sublingual, patch, and gel preparations
- **Timeline** -- unified chronological view with HRT milestone celebrations

### Privacy & Security
- 6-digit PIN + biometric unlock
- Argon2id key derivation (64MB memory, 3 iterations, 4 parallelism)
- SQLCipher encrypted database
- AES-256-GCM encrypted photo storage
- App-switch blur overlay
- Emergency data wipe

---

## Download

Download the latest APK from [GitHub Releases](https://github.com/cantascendia/hananote/releases/latest).

The app checks for updates automatically on launch.

---

## Development

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

---

## Acknowledgments

- [estrannaise.js](https://github.com/WHSAH/estrannaise.js) -- PK model reference
- [Transfem Science](https://transfemscience.org) -- pharmacokinetic research
- [HRT Yakuten](https://hrtyaku.com) -- evidence-based drug reference
- [WPATH SOC8](https://www.wpath.org/soc8) -- clinical guidelines

---

## License

Proprietary software. All rights reserved.

---

<p align="center">
  <sub>Built with care for those who deserve a safe space to track their journey.</sub>
</p>
