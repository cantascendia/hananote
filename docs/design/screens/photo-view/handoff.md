# Photo View 屏（全屏查看）v2 — Flutter Handoff Spec

> 配对 spec：docs/design/screens/photo-view/spec.md
> 屏幕：lib/features/photo/presentation/pages/photo_view_page.dart
> 受 CLAUDE.md 约束：保留 LoadPhotoFull / DeletePhoto UseCase 直连不动，仅改 UI；ARB 走 `lib/core/l10n/`；新增 SharePhoto UseCase
> Pilot Wave: 阶段 3.1.b（设计 → 工程交接）
> 跨性别敏感性 P0 红线：分享警告 BottomSheet **必须**实施 + 拒绝"保存到相册"按钮

---

## 1. 现有 UseCase 兼容性 + 新增

photo_view_page.dart 当前直连 `LoadPhotoFull` + `DeletePhoto` 两个 UseCase（不通过 Bloc，是 photo 模块的特例）。v2 保留此架构 + **新增 1 个 UseCase**：

**仍在用的 UseCase**：
- `LoadPhotoFull(entry)` — 解密并返回完整图像 bytes
- `DeletePhoto(entry)` — 删除单张

**新增 UseCase**（v2 必须）：
- `SharePhotoTempFile(entry)` — **新建** `lib/features/photo/domain/usecases/share_photo_temp_file.dart`
  ```dart
  /// 解密图像并写入临时文件，返回文件路径供系统 share sheet 使用。
  /// 安全契约：调用者必须在 share 完成 / 取消 / app 后台时立即删除该文件。
  ///
  /// 实现：
  /// 1. LoadPhotoFull 拿到 plaintext bytes
  /// 2. 写入 getTemporaryDirectory() / 'share_${entry.id}_${timestamp}.jpg'
  /// 3. 返回 Either<Failure, String filePath>
  /// 4. 调用方在 finally 中 File(path).delete()
  @injectable
  class SharePhotoTempFile {
    final LoadPhotoFull _loadPhotoFull;
    final FileSystem _fileSystem;
    Future<Either<Failure, String>> call(PhotoEntry entry);
  }
  ```

**新增 Bloc / Cubit**（**可选**——若 photo-view 内部状态管理变复杂可引入）：
- 当前 v1 用 `setState` 管理 `_imageBytes / _errorMessage / _isDeleting`，**v2 sufficient** 仍用 setState
- 仅在分享流程加 `_isSharing` 状态 + 临时文件清理逻辑

**HRT 第 N 天派生**：
- `PhotoEntry.date` 已存在
- 需读取 `userProfile.hrtStartDate`（来自 settings / profile feature）
- 在 photo-view 内部派生：`hrtDay = entry.date.difference(hrtStartDate).inDays + 1`
- 若 hrtStartDate 未设置 → 元数据降级为"4 月 28 日 · 周二"（无 HRT 第 N 天）
- 不增加 PhotoEntry domain 字段（保持 Photo domain 独立，跨 feature 派生在 presentation 层）

> **不动 LoadPhotoFull / DeletePhoto + 加 SharePhotoTempFile**：现有测试 mock 无需改；仅新增 share UseCase 需要新测试 case。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/photo/presentation/pages/photo_view_page.dart` — **完整重写**
  - 保留：`PhotoViewRouteExtra` class（13-26）、`_loadImage` 方法（215-238）、`_isDeleting` 状态、`Hero(tag: 'photo-${id}')` 共享元素
  - 删除：底部白色 panel `Container`（91-132）、`Column` 上下分栏（84-133）、`_formatFileSize` 方法（286-294）、`_buildImageArea` 占位 220×220 灰盒（189-202）、中央 spinner 黑半透明圆容器（203-211）、`Icons.broken_image_outlined` 错误图标（160）、`showDialog<bool>` Material AlertDialog（242-258）、`DateFormat('yyyy.MM.dd')` 写死（70）
  - 新结构：`Scaffold(backgroundColor: Colors.black, extendBodyBehindAppBar: true, body: Stack(children: [图像 InteractiveViewer + Hero, HanaTopBar.transparent 浮顶, 底部元数据浮底]))`

### 新增（presentation 层）
- `lib/features/photo/presentation/widgets/photo_view_metadata_bar.dart` — **新组件**
  ```dart
  /// 底部元数据浮底单行 — "4 月 28 日 · 周二 · HRT 第 245 天"
  class PhotoViewMetadataBar extends StatelessWidget {
    const PhotoViewMetadataBar({
      required this.date,
      required this.hrtStartDate,
      super.key,
    });
    final DateTime date;
    final DateTime? hrtStartDate;
    // mono 12 onPrimaryDark @ 70%
    // 左对齐 32px / SafeArea 底部
    // hrtStartDate == null 时降级显示日期 + 周次
  }
  ```
- `lib/features/photo/presentation/widgets/photo_share_warning_sheet.dart` — **新组件 / P0 关键**
  ```dart
  /// 分享前隐私警告 BottomSheet
  /// 跨性别敏感性 P0：用户每次分享必须显式确认
  class PhotoShareWarningSheet extends StatelessWidget {
    const PhotoShareWarningSheet({
      required this.onConfirm,
      super.key,
    });
    final VoidCallback onConfirm;
    // headline "分享前请确认。" + body 双行警告 +
    // HanaButton.primary "确认分享" + HanaButton.ghost "取消"
    // **不**有"不再提示"复选框（每次都要主动确认）
  }
  ```
- `lib/features/photo/presentation/widgets/photo_compare_picker_sheet.dart` — **新组件（P2 占位）**
  ```dart
  /// 对比模式选择器 — 显示按月分组的缩略图列表，供选择对比张
  class PhotoComparePickerSheet extends StatelessWidget {
    const PhotoComparePickerSheet({
      required this.currentEntryId,
      required this.allEntries,
      required this.onSelect,
      super.key,
    });
    // 当前查看的 disabled
    // 选某张 → onSelect(entry) → P2 进对比模式 / MVP 显示 toast
  }
  ```
- `lib/features/photo/presentation/widgets/photo_view_loading_view.dart` — **新组件**
  ```dart
  /// 加载态 — 半透明 thumbnail + 屏底 1px primary progress + 文字"解密中。"
  class PhotoViewLoadingView extends StatelessWidget {
    final Uint8List? thumbnailBytes;
  }
  ```
- `lib/features/photo/presentation/widgets/photo_view_error_view.dart` — **新组件**
  ```dart
  /// 错误态 — 黑底 + headline + body + ghost 重试雪宣文字
  class PhotoViewErrorView extends StatelessWidget {
    final String message;
    final VoidCallback onRetry;
  }
  ```

### 共享组件复用 / 待补
- `HanaTopBar.transparent` — **新 variant**：当前 components/top-bar.md 仅有 `defaultBar`，需补 `transparent` variant（透明背景 + onPrimaryDark 前景，给全屏黑底场景用）
- `HanaIconButton.transparentDark` — **新 variant**：透明背景 + onPrimaryDark icon
- `HanaButton.primary` / `HanaButton.ghost` / `HanaButton.destructive` — sheet / dialog 按钮
- `HanaButton.ghost` 在黑底上的 onPrimaryDark variant — **新 variant**：透明底 + 雪宣文字 + 1px 雪宣 outline @ 30%
- `HanaDialog.confirmDestructive` — 删除二次确认（已存在）
- `HanaBottomSheet.warning` — **新 variant**：分享警告专用（与 info 区分，配色 / 强调更重）

### 删除（v1 残留）
- `_formatFileSize` 方法（286-294）
- `_buildImageArea` 内占位 220×220 灰盒分支（189-202）+ 中央 spinner 圆容器（203-211）
- 底部白色 panel `Container` 整段（91-132）
- `_confirmDelete` 内 `showDialog<bool>` + `AlertDialog`（242-258）—— 替换为 `HanaDialog.confirmDestructive(...)` 调用

### ARB 改动（`lib/core/l10n/arb/app_{en,zh,ja}.arb`）

| Key 新增 / 改动 | zh | ja | en |
|----------------|----|----|----|
| `photoView.metadata` | "{date} · {weekday} · HRT 第 {day} 天" | "{date} · {weekday} · HRT {day}日目" | "{date} · {weekday} · HRT day {day}" |
| `photoView.metadataNoHrt` | "{date} · {weekday}" | "{date} · {weekday}" | "{date} · {weekday}" |
| `photoView.decrypting` | 解密中。 | 復号中。 | Decrypting. |
| `photoView.errorTitle` | 无法读取。 | 読み込めません。 | Cannot be read. |
| `photoView.errorBody` | 图像可能已损坏，或加密密钥丢失。 | 画像が破損しているか、復号鍵が失われた可能性があります。 | The image may be corrupted, or the decryption key is lost. |
| `photoView.shareTitle` | 分享前请确认。 | 共有前に確認。 | Confirm before sharing. |
| `photoView.shareBody` | "图像将以未加密形式离开本机。\n接收方可以保存、转发、截屏。" | "画像は暗号化されずに端末を離れます。\n受信者は保存、転送、スクリーンショットが可能です。" | "Image will leave this device unencrypted.\nRecipient can save, forward, screenshot." |
| `photoView.shareConfirm` | 确认分享 | 共有を確認 | Confirm share |
| `photoView.shareCancel` (沿用 `cancel`) | 取消 | キャンセル | Cancel |
| `photoView.shareSubject` | "HanaNote 图像 · {date}" | "HanaNote 画像 · {date}" | "HanaNote image · {date}" |
| `photoView.compareTitle` | 与哪一张对比？ | どの一枚と対比？ | Compare with which? |
| `photoView.compareNoOther` | 暂无其他图像。 | 他の画像なし。 | No other images. |
| `photoView.deleteTitle` (沿用 `photoDeleteTitle` 调性对齐) | 删除这张。 | この一枚を削除。 | Delete this entry. |
| `photoView.deleteBody` (沿用 `photoDeleteMessage`) | 删除后无法找回。 | 削除後は復元できません。 | Cannot be recovered. |
| `photoView.retry` (沿用 `retry`) | 重试 | 再試行 | Retry |
| `photoView.notes` (沿用 `notes`) | 备注 | メモ | Notes |
| `photoView.tooltipDelete` | 删除 | 削除 | Delete |
| `photoView.tooltipShare` | 分享 | 共有 | Share |
| `photoView.tooltipCompare` | 对比 | 対比 | Compare |
| `photoView.semanticImageLabel` | "私人图像 {date} {weekday} HRT 第 {day} 天" | "プライベート画像 {date} {weekday} HRT {day}日目" | "Private image {date} {weekday} HRT day {day}" |

> **关键 i18n 约束**：
> - 分享警告 `shareBody` **必须双行**（不可压缩为单行）—— 警告强度需视觉权重
> - Semantics label 用"私人图像 / Private image"中性词，**不**用"身体照片 / 隐私照片"暗示
> - HRT 第 N 天的"day" 在 en 用 "day {N}" 而非 "Nth day" 减少 ICU placeholder

### Domain 改动（最小）
- `lib/features/photo/domain/usecases/share_photo_temp_file.dart` — **新建**（如上 §1）
- `lib/features/photo/domain/repositories/photo_repository.dart` — 可选扩展 `Future<Either<Failure, String>> writeTempFile(PhotoEntry)`（或在 SharePhotoTempFile 内部组合 LoadPhotoFull + path_provider）
- `injection.config.dart` 自动重新生成（freezed / injectable）

### 删除文件
（无 — 仅 photo_view_page.dart 内部 widget 重写）

---

## 3. 性能与安全

### 临时文件清理（**安全关键**）
分享流程的临时解密文件**必须立即清理**：

```dart
Future<void> _shareImage() async {
  final result = await _sharePhotoTempFile(widget.entry);
  if (result.isLeft()) return;
  final tempPath = result.getRightOrElse(() => '');
  try {
    await Share.shareXFiles(
      [XFile(tempPath)],
      subject: l10n.photoViewShareSubject(formattedDate),
    );
  } finally {
    // 关键：无论 share 成功 / 取消 / 异常，立即删除
    final f = File(tempPath);
    if (await f.exists()) {
      await f.delete();
    }
  }
}
```

额外保险：在 `WidgetsBindingObserver.didChangeAppLifecycleState` 中监听 `paused` 事件，强制删除任何遗留 `share_*.jpg` 临时文件（防止 app 被 kill 时残留）。

### Hero 共享元素
- `tag: 'photo-${entry.id}'` 沿用，与 photo_page 共享
- v2 photo-view 的图像 BoxFit.contain（不是 cover）→ Hero 起飞 / 落地动画过程中尺寸变化大 → 可能视觉撕裂
- 缓解：`flightShuttleBuilder` 自定义起飞 widget 平滑过渡 cover → contain

### Swipe-down 关闭
- 用 `Dismissible` 包 InteractiveViewer 可能与双指缩放冲突
- 推荐：`GestureDetector(onVerticalDragUpdate: ..., onVerticalDragEnd: ...)` + 仅在 InteractiveViewer scale = 1 时启用
- 拖动距离 ≥ 100px 触发关闭，否则弹回

### 解密性能
- LoadPhotoFull 在主 isolate 上执行 AES-256-GCM 解密 —— 大图（10MB+）可能阻塞 UI 100-300ms
- v1 已有 `compute(_resizeForEncryption, ...)` 在 photo_bloc 上传时使用
- v2 photo-view 解密如阻塞 ≥ 200ms 应迁 isolate（见 photo_repository_impl）—— 但本 PR 不动该层（保持 v1 行为）

---

## 4. 验收清单（Definition of Done）

实现 PR 必须满足：

- [ ] photo_view_page.dart 完整重写，AppBar 走 `HanaTopBar.transparent`
- [ ] 删除底部白色固定 panel（91-132）+ boxShadow + 24px 圆角
- [ ] 删除占位 220×220 灰盒（189-196）+ `Icons.photo_outlined` 72px 大图标（197-201）
- [ ] 删除中央 spinner 黑半透明圆容器（203-211）
- [ ] 删除 `Icons.broken_image_outlined` 错误图标（160）
- [ ] 删除"文件大小"显示（123-129）+ `_formatFileSize` 方法（286-294）
- [ ] 元数据改"HRT 第 N 天" mono inkSubdued 浮底单行（左对齐 32px）
- [ ] hrtStartDate 未设置时降级为日期 + 周次（无 HRT 第 N 天）
- [ ] 标题日期格式 `DateFormat.yMMMEEEEd(localeName)`
- [ ] 加载态走 `PhotoViewLoadingView`：半透明 thumbnail + 屏底 1px primary progress + 文字"解密中。"
- [ ] 错误态走 `PhotoViewErrorView`：headline + body + ghost 重试雪宣文字
- [ ] 删除二次确认走 `HanaDialog.confirmDestructive`（朱砂"删除"按钮）
- [ ] **加分享按钮 + `PhotoShareWarningSheet` 隐私警告**（**P0 红线**）
- [ ] 分享警告 body 必须双行：「图像将以未加密形式离开本机。\n接收方可以保存、转发、截屏。」
- [ ] 临时文件 share 完成 / 取消 / app 后台时立即删除（finally 块 + lifecycle 监听双保险）
- [ ] 加对比按钮 + `PhotoComparePickerSheet`（P2 占位 BottomSheet 显示选择器）
- [ ] 双指捏合缩放保留 `InteractiveViewer(maxScale: 4)`
- [ ] 加 swipe-down 关闭手势（仅 scale=1 时启用，与缩放不冲突）
- [ ] 全部 `HanaColors.*` → `HanaTokens.*(context)` + `HanaTokens.onPrimaryDark`
- [ ] 间距值 4 / 12 / 28 全部 token 化
- [ ] AppBar `centerTitle: false`
- [ ] ARB 三语全添加上述 key
- [ ] **拒绝**「保存到相册」按钮（明确不实施 — handoff 注释中强调）
- [ ] Semantics label 用"私人图像"中性词，不含"身体 / 私密 / 健康"暗示
- [ ] dark mode：黑底全屏永远（不随系统 mode 变），status bar icons 强制 light
- [ ] 触控目标 ≥ 44dp（工具栏 / 返回 / sheet / dialog 按钮）
- [ ] prefers-reduced-motion 跳过 Hero 共享元素 / Swipe-down / 加载进度条 indeterminate
- [ ] flutter test 全绿（v1 既有测试无需改 + 新增 SharePhotoTempFile 测试 case）
- [ ] dart analyze --fatal-infos 通过

---

## 5. 风险与回退

### 风险 1：临时文件清理失败导致明文遗留
- 场景：用户分享时 app 崩溃 / 系统强制 kill → tempfile 留在 `getTemporaryDirectory()` 直到系统清理（可能数天）
- 缓解：双保险 — finally 块 + `WidgetsBindingObserver.didChangeAppLifecycleState(paused)` 强制清理 share_*.jpg
- 加固：app 启动时 `cleanupOrphanedShareFiles()` 扫描临时目录删除所有 `share_*.jpg`（**强烈推荐 main.dart 启动钩子**）
- 回退：禁用分享功能直到清理机制 audit 通过

### 风险 2：HanaTopBar.transparent variant 不存在
- 当前 components/top-bar.md 仅有 defaultBar
- 缓解：本 PR 先扩 HanaTopBar 加 transparent variant；或临时用 `AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: HanaTokens.onPrimaryDark(context))` inline 实现
- 回退：本 PR 内嵌 inline `_TransparentTopBar` widget，PR 2 提取到 components

### 风险 3：Swipe-down 关闭与 InteractiveViewer 缩放冲突
- 双指缩放后向下 pan 可能误触关闭
- 缓解：仅在 `_transformationController.value.scale == 1.0` 时启用 swipe-down GestureDetector
- 回退：禁用 swipe-down，仅返回箭头关闭

### 风险 4：HRT 第 N 天派生失败（hrtStartDate 未设置）
- 新用户未设置 HRT 起始日时元数据降级
- 缓解：`PhotoViewMetadataBar` 内部条件渲染 — `hrtStartDate == null` 时仅显示日期 + 周次
- 回退：永远只显示日期 + 周次（不引入 HRT 第 N 天）

### 风险 5：分享警告被用户养成"无脑确认"习惯
- 多次分享后用户机械按"确认分享"失去警告价值
- 缓解：**v2 不加"不再提示"复选框**——每次都要主动确认是 v2 隐私契约（critique-v1 P0 红线写明）
- 加固：考虑首次分享时升起更长 dialog（"首次分享提示" + 教育性文案）—— P2 增强项

### 风险 6：「保存到相册」按钮被未来需求误添加
- 跨性别敏感性 P0 拒绝项 —— 但产品 / 设计可能在未来推动添加
- 缓解：handoff.md + spec.md + critique-v1.md 三处明确写明拒绝理由（与 iCloud / Google Photos 自动同步泄露）
- 加固：在 photo-view 文件顶部加注释 `// SECURITY: 不要添加"保存到相册"按钮 - 见 docs/design/screens/photo-view/spec.md §3 明确拒绝`

—— 完 ——
