# Photo 屏（网格）v2 — Flutter Handoff Spec

> 配对 spec：docs/design/screens/photo/spec.md
> 屏幕：lib/features/photo/presentation/pages/photo_page.dart
> 受 CLAUDE.md 约束：保留 PhotoBloc/state 不动，仅改 UI；ARB 走 `lib/core/l10n/`
> Pilot Wave: 阶段 3.1.b（设计 → 工程交接）
> 跨性别敏感性 P0 红线：删除 `Icons.lock_person_outlined`

---

## 1. 现有 PhotoBloc 兼容性

`PhotoBloc` / `PhotoEvent`（freezed union）/ `PhotoState`（freezed union）**契约不动**——v2 重画 UI + 加月份章节派生 + 隐私状态栏依赖 entry count，状态机扩展不破。

**仍在用的事件**（`blocs/photo_event.dart`）：
- `PhotoEvent.loadHistory()` — 初次进入 / 重试 / 下拉刷新
- `PhotoEvent.capturePhoto()` — 相机拍摄
- `PhotoEvent.pickFromGallery()` — 从图库选择
- `PhotoEvent.deletePhoto(entry)` — 删除单张
- `PhotoEvent.loadThumbnail(entry)` — 按需加载缩略图

**新 UI 派生逻辑**（仅 presentation 层，**不改 bloc**）：
- `groupedByMonth: Map<YearMonth, List<PhotoEntry>>` — 按 `(year, month)` 分组，渲染章节断点
- `firstEntryDate: DateTime?` — entries 中最早一条日期，渲染 hero 副行 "始于 {date}"
- `totalCount: int` — entries.length，渲染 hero 副行 "{count} 张" + 隐私状态栏 "图像本地加密 · N 张"
- `responsiveCrossAxisCount(width: double): int` — `< 768 ? 3 : width < 1024 ? 4 : 5`

> **不动 bloc**：现有测试 mock 无需改动；UseCase 不需扩展；仅 photo_page.dart 内部派生。P2 加 filter（按月份 / 按 tag）时再扩 bloc。

---

## 2. 文件改动清单

### 主文件（重写）
- `lib/features/photo/presentation/pages/photo_page.dart` — **完整重写**
  - 保留：BlocListener / BlocBuilder switch 模式、`_requestThumbnailIfNeeded` 缩略图按需加载逻辑、`_openPhotoView` 跳转、`_confirmDelete` 删除二次确认（但走 HanaDialog.confirmDestructive）
  - 删除：`AppBar` Material（47-57）、`_PhotoEmptyState` 锁形 icon（210-262）、`_PhotoErrorState` 标准 Material（264-299）、`_PhotoGridItem` boxShadow + 黑色日期 pill + 20 圆角（301-383）、`_PhotoThumbnailPlaceholder` LinearGradient（385-410）、`_showPickerSheet` Material `showModalBottomSheet` + Material `ListTile` + camera_alt / photo_library icon（177-207）
  - 新结构：`Scaffold(body: Stack(children: [CustomScrollView + 月份章节 + 网格, sticky CTA + 隐私状态栏 fixed bottom]))`，Topbar 用 `HanaTopBar.defaultBar`

### 新增（presentation 层）
- `lib/features/photo/presentation/widgets/hana_photo_tile.dart` — **新组件**
  ```dart
  /// 1:1 正方形缩略图 tile，无 shadow / 无圆角装饰 pill / 无渐变。
  class HanaPhotoTile extends StatelessWidget {
    const HanaPhotoTile({
      required this.entry,
      required this.thumbnailBytes,
      required this.onTap,
      required this.onLongPress,
      super.key,
    });
    final PhotoEntry entry;
    final Uint8List? thumbnailBytes;
    final VoidCallback onTap;
    final VoidCallback onLongPress;
    // surfaceContainerLowest + r-card=4 + Hero(tag: 'photo-${entry.id}') +
    // press scale 0.98 (motion-quick) +
    // placeholder: surfaceContainerLow 实色 + 1px linear progress 顶 8% 高
  }
  ```
- `lib/features/photo/presentation/widgets/photo_picker_sheet.dart` — **新组件**：拍摄/导入选择器内容
  ```dart
  /// HanaBottomSheet.actionSheet 内容 — 拍摄 / 从图库选择 文字主导
  class PhotoPickerSheet extends StatelessWidget {
    // HanaListItem.action × 2 + HanaButton.ghost "关闭"
    // 无 leading icon（或极简文字标记 ┃）
  }
  ```
- `lib/features/photo/presentation/widgets/photo_long_press_sheet.dart` — **新组件**：长按操作面板
  ```dart
  /// 长按缩略图触发 — 查看 / 对比 (P2 disabled) / 删除 (destructive)
  class PhotoLongPressSheet extends StatelessWidget {
    // 顶部 label "4 月 28 日　周二" primary
    // HanaListItem × 3
  }
  ```
- `lib/features/photo/presentation/widgets/photo_privacy_status_bar.dart` — **新组件**：底部隐私状态栏
  ```dart
  /// "图像本地加密 · {count} 张" mono inkSecondary 居中底部
  class PhotoPrivacyStatusBar extends StatelessWidget {
    final int count;
    // mono 12 / inkSecondary / 居中 / 仅一行 / Semantics 完整朗读
    // count == 0 时显示"图像本地加密"（无数字）
  }
  ```

### 共享组件复用（PR 1 已建 / timeline PR 已建）
- `HanaTopBar.defaultBar` — 替换 Material AppBar
- `HanaSectionHeader` — 月份章节断点（timeline PR 已建）
- `HanaButton.primary` / `HanaButton.secondary` / `HanaButton.ghost` — sticky CTA / 空态 / sheet 关闭
- `HanaEmptyState.page` — 空态（**no icon variant**）
- `HanaErrorState` — 错误态
- `HanaLoadingView.block` — 加载态
- `HanaBottomSheet.actionSheet` — 拍摄/导入选择 + 长按操作
- `HanaDialog.confirmDestructive` — 删除二次确认
- `HanaPressScale` — 缩略图按下

### 删除（v1 残留）
- `_PhotoEmptyState` / `_PhotoErrorState` / `_PhotoGridItem` / `_PhotoThumbnailPlaceholder` 四个私有 class（photo_page.dart 内）
- `_showPickerSheet` 方法体（177-207）—— 替换为 `HanaBottomSheet.show(...)` 调用 `PhotoPickerSheet`
- `_confirmDelete` 内部 `showDialog<bool>` + `AlertDialog`（154-170）—— 替换为 `HanaDialog.confirmDestructive(...)`

### ARB 改动（`lib/core/l10n/arb/app_{en,zh,ja}.arb`）

| Key 新增 / 改动 | zh | ja | en |
|----------------|----|----|----|
| `photo.heroTitle` (替换 `photoGallery`) | 图册。 | 画像庫。 | The Album. |
| `photo.heroSubtitle` | "{count} 张　始于 {date}" | "{count} 件　{date}より" | "{count} entries since {date}" |
| `photo.sectionMonth` | "{year} · {month} 月" | "{year} · {month}月" | "{month} {year}" |
| `photo.recordNew` | 记一张。 | 一枚を記録。 | Capture one. |
| `photo.emptyTitle` (替换 `photoEmptyTitle`) | 图册空白。 | 画像庫は空。 | The album is empty. |
| `photo.emptyMessage` (替换 `photoEmptyDescription`) | 记下第一张，对比由此开始。 | 一枚目を記し、対比を始めましょう。 | Capture your first to begin comparing. |
| `photo.privacyStatus` | "图像本地加密 · {count} 张" | "画像はローカルで暗号化 · {count} 件" | "Locally encrypted · {count} entries" |
| `photo.privacyStatusEmpty` | "图像本地加密" | "画像はローカルで暗号化" | "Locally encrypted" |
| `photo.pickerTitle` | 记一张。 | 一枚を記録。 | Capture one. |
| `photo.pickerCamera` | 拍摄 | 撮影 | Take photo |
| `photo.pickerCameraDesc` | 用相机记录此刻 | カメラで今を記録 | Use camera to capture now |
| `photo.pickerGallery` | 从图库选择 | ライブラリから選択 | Choose from library |
| `photo.pickerGalleryDesc` | 导入已有图片 | 既存の画像を取り込む | Import an existing image |
| `photo.longPressView` | 查看 | 表示 | View |
| `photo.longPressCompare` | 对比 | 対比 | Compare |
| `photo.longPressDelete` | 删除 | 削除 | Delete |
| `photo.errorRetry` | 载入失败。请下拉刷新。 | 読込失敗。引いて更新。 | Failed. Pull to refresh. |
| `photo.loading` | 读取中。 | 読込中。 | Loading. |
| `photo.deleteTitle` (沿用 `photoDeleteTitle` + 调性对齐) | 删除这张。 | この一枚を削除。 | Delete this entry. |
| `photo.deleteBody` (沿用 `photoDeleteMessage` + 调性对齐) | 删除后无法找回。 | 削除後は復元できません。 | Cannot be recovered. |
| `photo.permissionReason` (新增 / 系统弹窗 reason) | 拍摄一张图像加入图册。 | 画像を一枚撮影して画像庫に追加。 | Capture an image to add to the album. |
| `close` | 关闭 | 閉じる | Close |

> **关键 i18n 约束**：
> - 隐私状态栏文案是**含蓄确认**——不说"私密 / 安全 / 受保护"，只说"本地加密"事实陈述
> - 拍摄/导入选项**不说"身体照片 / 私密照片"**——跨性别敏感性
> - 系统相机权限 reason 串走 `photo.permissionReason` 中性陈述
> - `photoEmptyTitle` / `photoEmptyDescription` 旧 key 在改文案后**保留**避免破坏现有引用，但 photo 屏切换到新 key

### 删除文件
（无 — 仅 photo_page.dart 内部 widget 重写）

---

## 3. 性能与约束

### 缩略图加载
- 沿用 v1 `_requestThumbnailIfNeeded` 按需加载逻辑（postFrameCallback 派发 `LoadThumbnail`）
- v2 网格列数变多（3-5 列）→ 首屏可见缩略图数从 v1 ~6-8 增加到 ~9-15 → bloc 派发频率增加
- 解决方案：保留 `_requestedThumbnailIds` 去重 Set（v1 已有），不需新机制
- 底部 sticky 状态栏更新 N 不影响网格 rebuild —— `Selector` / `BlocSelector` 仅订阅 `state.entries.length`

### Hero 共享元素
- `tag: 'photo-${entry.id}'` 沿用，与 photo_view_page 共享
- 跨章节滚动后跳转 photo-view 可能出现起始位置错位 → 需 `flightShuttleBuilder` 自定义起飞动画或 `transitionOnUserGestures: true`

### 响应式
```dart
int crossAxisCount(double width) {
  if (width < 768) return 3;
  if (width < 1024) return 4;
  return 5;
}
```
配合 `LayoutBuilder` + `SliverGrid.delegateWithMaxCrossAxisExtent` 避免抖动（max width per cell ≈ 240）。

### 章节分组性能
- `groupedByMonth` 在 `BlocBuilder` 内 memoize（用 `useMemoized` 或 cubit-side derive）—— 100 张照片 grouping O(N) 单次 ≤ 5ms 可接受

---

## 4. 验收清单（Definition of Done）

实现 PR 必须满足：

- [ ] photo_page.dart 完整重写，AppBar 走 `HanaTopBar.defaultBar`
- [ ] 删除 `Icons.lock_person_outlined`（critique-v1 P0 红线 / 跨性别敏感性最高优先级）
- [ ] 删除 `Icons.add_a_photo_outlined` / `Icons.camera_alt` / `Icons.photo_library` / `Icons.error_outline`
- [ ] Hero「图册。」display-xl 左对齐 32px + 副行 body-sm "{count} 张　始于 {date}" mono 数字
- [ ] 月份章节断点 `HanaSectionHeader`「{year} · {month} 月」按月分组
- [ ] 网格 mobile 3 / tablet 4 / web 5 列，正方 1:1 比例
- [ ] 缩略图卡 r-card=4 / 无 boxShadow / 无渐变 placeholder（改 surfaceContainerLow 实色）
- [ ] 删除右下角黑色日期 pill —— 缩略图本身无任何叠加文字
- [ ] 底部 sticky CTA `HanaButton.primary`「记一张。」+ 下方 mono 状态栏「图像本地加密 · {N} 张」
- [ ] 拍摄/导入走 `HanaBottomSheet.actionSheet` + `HanaListItem`（无 leading icon）
- [ ] 长按走 `HanaBottomSheet.actionSheet` 显示日期 label + 查看/对比/删除
- [ ] 删除二次确认走 `HanaDialog.confirmDestructive`（朱砂"删除"按钮）
- [ ] 空态走 `HanaEmptyState.page` **no icon variant**「图册空白。」+「记下第一张，对比由此开始。」+ secondary "记一张"
- [ ] 错误态走 `HanaErrorState`「载入失败。请下拉刷新。」
- [ ] 加载态走 `HanaLoadingView.block`「读取中。」（无 spinner）
- [ ] 全部 `HanaColors.*` → `HanaTokens.*(context)` 单轨 API
- [ ] 屏边 padding 32 / 网格 spacing 16 / 章节间 64 / 顶部 hero 64
- [ ] `DateFormat` 走 `localeName`（hero 副行 + 章节标记 + 长按 sheet 日期）
- [ ] ARB 三语全添加上述 key
- [ ] 系统相机权限 reason 串改中性"拍摄一张图像加入图册。"
- [ ] dark mode 全部 token 化对比度 ≥ AA
- [ ] 触控目标 ≥ 44dp（缩略图最小 110px @ mobile 3 列）
- [ ] Semantics 完整朗读，**不**包含"私密 / 身体 / 健康"等暗示词
- [ ] prefers-reduced-motion 跳过入场 fadeIn / Hero 共享元素
- [ ] flutter test 全绿（v1 既有 PhotoBloc 测试无需改）
- [ ] dart analyze --fatal-infos 通过

---

## 5. 风险与回退

### 风险 1：网格列数响应式抖动
- 边界宽度（768 / 1024）刚好穿过时，breakpoint 跳变会导致网格列数闪烁
- 缓解：用 `SliverGrid.delegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 240)` 替代固定列数 → 列数随宽度连续过渡
- 回退：固定 mobile 3 列即可（tablet/web 加宽容忍单元变大）

### 风险 2：Hero 共享元素跨章节滚动错位
- 章节标记 sticky 切换后，缩略图在网格中的位置已变 → 跳转 photo-view 时 Hero 起飞位置错
- 缓解：`flightShuttleBuilder` 自定义起飞 widget；或 photo-view 接收时用 `transitionOnUserGestures: true`
- 回退：disabled Hero 共享元素，直接 `motion-standard` fadeThrough 跳屏

### 风险 3：1:1 强制裁切横构图照片
- HRT 用户上传的照片可能是横构图全身照
- 缓解：`BoxFit.cover` 中心裁切 → 缩略图聚焦躯干部分（合理）；photo-view 全屏时 `BoxFit.contain` 保留完整构图
- 回退：网格 aspectRatio 改 0.78（更高瘦）保留 v1 比例

### 风险 4：底部 sticky CTA + 状态栏遮挡末行缩略图
- iPhone SE 等小屏设备网格末行可能被遮
- 缓解：`CustomScrollView` 底部加 `SliverToBoxAdapter(SizedBox(height: 120))` 留出空间
- 回退：CTA 改非 sticky（滚到底才出现）

### 风险 5：跨性别敏感性词汇审查
- ARB 文案需走 zh/ja native speaker review，确认"图册" / "记一张" 不含暗示
- 缓解：DESIGN.md ux-copy-v2 已有 reviewer pool；新增 key 走 PR review
- 回退：保守用 "{count} 项 / Items" 等极简词汇

—— 完 ——
