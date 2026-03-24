# 技术决策日志

## D001 — 状态管理: flutter_bloc
备选: riverpod, provider, getx
理由: HanaNote 状态复杂度高，BLoC 显式事件-状态模型利于调试测试
缓解: 用 freezed 生成减少样板代码

## D002 — 数据库: sqflite_sqlcipher
备选: drift+sqlcipher, hive, isar
理由: 隐私核心要求加密；sqflite 生态最大；SQLCipher 是工业标准
远期: 可评估迁移到 drift 获得更强类型安全

## D003 — 目录结构: Feature-First
备选: Layer-First
理由: 16个功能模块需独立性，Feature-First 支持并行开发

## D004 — 错误处理: Either<Failure, T>
备选: sealed class Result, try-catch
理由: 函数式风格，强制调用者处理错误，类型安全

## D005 — PK模拟器参考: estrannaise.js
理由: 三室模型+MCMC最精确；已有Dart移植指导；TFS数据权威

## D006 — 应用切换模糊（社群反馈 2026-03-24）
来源: 目标用户群社群讨论
理由: iOS/Android 任务切换器会截屏，必须在 inactive 时遮挡
实现: WidgetsBindingObserver + Stack overlay
