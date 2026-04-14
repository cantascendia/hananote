<p align="center">
  <img src="../assets/icon/app_icon.png" width="120" alt="HanaNote" />
</p>

<h1 align="center">HanaNote</h1>

<p align="center">
  <strong>プライバシー重視のトランスジェンダー向け HRT 健康記録アプリ</strong>
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

> *あなたの体の変化を安全に記録できる、最もプライベートな空間。*

HanaNote は、ホルモン補充療法（HRT）を受けている MTF トランスジェンダーの方のための、フル機能のオフラインファースト健康記録アプリです。すべてのデータは暗号化され、デバイスの外に出ることはありません。

---

## なぜ HanaNote？

| 特徴 | |
|------|------|
| **ゼロ知識暗号化** | Argon2id 鍵導出 + SQLCipher データベース + AES-256-GCM ファイル暗号化。PIN なしではデータを読めません。 |
| **デュアル PK シミュレーター** | V2 + Hana-PK の 2 つの薬物動態エンジンで、7 種類の薬剤の血中エストラジオール濃度を予測。実際の血液検査による MAP キャリブレーション対応。 |
| **オールインワン** | 服薬管理、血液検査、ボディ測定、暗号化写真、気持ち日記、クロスフィーチャータイムライン。 |
| **薬物リファレンス** | [HRT 薬典](https://hrtyaku.com)のエビデンスベースの安全ガイドをアプリ内で閲覧。 |
| **完全オフライン** | コア機能はネットワーク不要。健康データはサーバーに送信されません。 |
| **3 言語対応** | 中国語 / English / 日本語 |

---

## 主な機能

### 日常トラッキング
- **今日タブ** — パーソナライズされた挨拶、服薬カウントダウン、毎日の言葉
- **服薬管理** — 薬の追加、スケジュール設定、服薬追跡、在庫アラート
- **リマインダー通知** — ローカル通知による服薬リマインダー

### 健康記録
- **血液検査** — ホルモンパネル記録（E2、T、PRL、P4、LH、FSH、SHBG）、WPATH 目標範囲表示
- **ボディ測定** — 9 種類の測定項目の履歴追跡
- **暗号化写真** — エンドツーエンド暗号化写真ストレージ
- **気持ち日記** — 毎日のジャーナルとムードトラッキング

### 分析
- **トレンドチャート** — ホルモン指標のトレンドグラフ
- **PK シミュレーター** — 注射、経口、舌下、パッチ、ジェルの血中濃度予測
- **タイムライン** — クロスフィーチャーの時系列ビュー、HRT マイルストーン

### プライバシーとセキュリティ
- 6 桁 PIN + 生体認証ロック解除
- Argon2id 鍵導出（64MB メモリ、3 イテレーション、4 並列度）
- SQLCipher 暗号化データベース
- AES-256-GCM 暗号化写真ストレージ
- アプリ切替時のブラーオーバーレイ
- 緊急データ消去

---

## ダウンロード

[GitHub Releases](https://github.com/cantascendia/hananote/releases/latest) から最新の APK をダウンロードしてください。

アプリ起動時に自動でアップデートを確認します。

---

## 開発

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

## 謝辞

- [estrannaise.js](https://github.com/WHSAH/estrannaise.js) — PK モデルリファレンス
- [Transfem Science](https://transfemscience.org) — 薬物動態研究
- [HRT 薬典](https://hrtyaku.com) — エビデンスベースの薬物リファレンス
- [WPATH SOC8](https://www.wpath.org/soc8) — 臨床ガイドライン

---

## ライセンス

プロプライエタリソフトウェア。すべての権利を保有します。

---

<p align="center">
  <sub>安全な空間を必要とするすべての人のために、心を込めて開発しました。</sub>
</p>
