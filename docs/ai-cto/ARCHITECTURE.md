# HanaNote 架构文档

## 层次总览
见 .agents/rules/flutter-project.md 的 Directory Structure 章节。

## 核心基础设施模块

### CryptoEngine (core/crypto/)
- AES-256-GCM 加解密（文件级）
- 密钥派生：Argon2id from user password
- 密钥存储：flutter_secure_storage
- 重操作在 Isolate 中执行
- 接口：encrypt(bytes) → bytes, decrypt(bytes) → bytes, encryptFile(path) → path

### SecureDatabase (core/database/)
- sqflite_sqlcipher 封装
- 自动迁移管理
- 表定义集中在 core/database/tables/
- 对外暴露类型安全的查询接口

### EncryptedFileStore (core/storage/)
- 照片/备份文件的加密存储管理
- 写入时加密，读取时解密
- 缩略图缓存（解密后的低分辨率版本，内存中）
- Isolate 池管理并发加解密

## Feature 间通信
- 通过 Domain 层公开的 Entity + Repository 接口
- 绝不直接 import 其他 feature 的 data 层
- App 级 BLoC 协调跨 feature 流程（如：用药记录触发时间线更新）

## 隐私架构图

User Password → Argon2id → DB Key → SQLCipher → File Key → AES-256-GCM → Photos/Backups

flutter_secure_storage (Keychain/KeyStore) → caches derived keys

App Lifecycle → inactive → blur overlay
Task Switcher → sees blur, not content
Notifications → vague text only
Clipboard → never auto-read
