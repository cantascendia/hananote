# HanaNote 产品与技术愿景

## 产品愿景
MTF HRT 全能型私密健康管理 App。面向中国大陆、日本、东南亚华人圈药娘群体。
核心差异化：隐私极致 + 二次元审美 + 中日双语 + MTF HRT 专精。
竞品空白：市场无 App 同时满足上述四项，这是蓝海。

## 技术栈
Flutter 3.x / Dart ^3.10.3 / flutter_bloc / go_router / get_it+injectable /
freezed / sqflite_sqlcipher / pointycastle / fl_chart / flutter_local_notifications / camera

## 架构
Feature-First Clean Architecture (Presentation → BLoC/Cubit → Domain → Data)
数据层全加密：SQLCipher + AES-256-GCM 文件加密
本地优先、100% 离线可用

## 核心架构决策
| ID | 决策 | 选择 | 理由 |
|----|------|------|------|
| D001 | 状态管理 | flutter_bloc | 复杂数据流需要显式事件-状态模型 |
| D002 | 数据库 | sqflite_sqlcipher | 隐私核心要求，SQLCipher是加密SQLite工业标准 |
| D003 | 目录结构 | Feature-First | 16个功能模块需独立性，可并行开发 |
| D004 | 错误处理 | Either<Failure, T> | 函数式错误处理，类型安全 |
| D005 | 数据模型 | Freezed | 不可变、copyWith、JSON序列化一体化 |
| D006 | PK模拟器 | 参考estrannaise.js 3室模型 | 最精确的开源参考实现 |

## 竞品定位
- Stabilize: 面向更年期，非MTF专精
- Hormone Helper: iOS-only, 英语only, 无加密
- Trans Memo: UX差，功能残缺，无隐私保护
- TFS E2 Simulator: Web-only工具，无App形态
