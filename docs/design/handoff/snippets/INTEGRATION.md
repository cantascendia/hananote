# Phase 5 Starter — Integration Guide

> Generated 2026-04-29 alongside the 6 Dart snippets in this directory.
> Audience: Phase 5 implementation engineer (PR 1 author).
>
> The 6 `.dart` files in this folder are the v2 **starter kit**. They are
> intentionally outside `lib/` so a human can review them before they enter
> the codebase. Once accepted, copy them to `lib/` per the SOP below — that's
> PR 1 in the Phase 5 plan.

---

## 0. What's in this folder

| File | Lines | Destination |
|---|---|---|
| `hana_tokens.dart` | ~270 | `lib/app/theme/hana_tokens.dart` |
| `hana_press_scale.dart` | ~80 | `lib/core/widgets/hana_press_scale.dart` |
| `hana_card.dart` | ~95 | `lib/core/widgets/hana_card.dart` |
| `hana_button.dart` | ~155 | `lib/core/widgets/hana_button.dart` |
| `hana_top_bar.dart` | ~180 | `lib/core/widgets/hana_top_bar.dart` |
| `hana_celebration.dart` | ~180 | `lib/core/widgets/hana_celebration.dart` |

Total: ≈ 960 LOC. Every file is < 200 LOC except `hana_tokens.dart`
(token registry, expected). All files compile against Flutter 3.38.4 +
Dart 3.5+ with **no new dependencies** — only `flutter/material.dart` and
`flutter/services.dart`.

---

## 1. File migration SOP

```bash
# from repo root, on a fresh feature branch:
git checkout -b feat/v2-design-system-starter

# 1. tokens — sits next to hana_colors.dart (do NOT delete v1 yet)
cp docs/design/handoff/snippets/hana_tokens.dart lib/app/theme/hana_tokens.dart

# 2. atomic press wrapper first (other widgets depend on it)
cp docs/design/handoff/snippets/hana_press_scale.dart lib/core/widgets/hana_press_scale.dart

# 3. then card / button / top bar / celebration
cp docs/design/handoff/snippets/hana_card.dart lib/core/widgets/hana_card.dart
cp docs/design/handoff/snippets/hana_button.dart lib/core/widgets/hana_button.dart
cp docs/design/handoff/snippets/hana_top_bar.dart lib/core/widgets/hana_top_bar.dart
cp docs/design/handoff/snippets/hana_celebration.dart lib/core/widgets/hana_celebration.dart
```

After copying, fix the import lines: change every `import 'hana_*.dart';` to
the proper package import:

```dart
// in lib/core/widgets/hana_card.dart, etc.
import 'package:hananote/app/theme/hana_tokens.dart';
import 'package:hananote/core/widgets/hana_press_scale.dart';
```

(That single rewrite is the reason the snippets use bare relative imports —
it makes the files self-contained for review without leaking lib paths.)

Then:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos
flutter test
```

Expected: 0 analyzer warnings, all 323 baseline tests still pass (the new
widgets are not yet wired into screens, so behavior is unchanged).

---

## 2. pubspec.yaml — font registration

Add fonts to `pubspec.yaml` BEFORE running the app, otherwise Flutter falls
back to Roboto and the editorial vibe collapses on emulators.

```yaml
flutter:
  uses-material-design: true
  fonts:
    - family: Spectral
      fonts:
        - asset: assets/fonts/Spectral-Regular.ttf
        - asset: assets/fonts/Spectral-Medium.ttf
          weight: 500
        - asset: assets/fonts/Spectral-SemiBold.ttf
          weight: 600
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
    - family: Source Han Serif SC
      fonts:
        - asset: assets/fonts/SourceHanSerifSC-Regular.otf
        - asset: assets/fonts/SourceHanSerifSC-Medium.otf
          weight: 500
    - family: Source Han Sans SC
      fonts:
        - asset: assets/fonts/SourceHanSansSC-Regular.otf
        - asset: assets/fonts/SourceHanSansSC-Medium.otf
          weight: 500
    - family: Noto Serif JP
      fonts:
        - asset: assets/fonts/NotoSerifJP-Regular.otf
        - asset: assets/fonts/NotoSerifJP-Medium.otf
          weight: 500
    - family: Noto Sans JP
      fonts:
        - asset: assets/fonts/NotoSansJP-Regular.otf
        - asset: assets/fonts/NotoSansJP-Medium.otf
          weight: 500
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Light.ttf
          weight: 300
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
```

### Font sources (all SIL OFL / Apache 2.0)

| Family | Source |
|---|---|
| Spectral | https://fonts.google.com/specimen/Spectral (download → strip italic) |
| Inter | https://github.com/rsms/inter/releases (4.0+, hinted) |
| Source Han Serif SC | https://github.com/adobe-fonts/source-han-serif/tree/release/SubsetOTF/CN |
| Source Han Sans SC | https://github.com/adobe-fonts/source-han-sans/tree/release/SubsetOTF/CN |
| Noto Serif JP | https://fonts.google.com/noto/specimen/Noto+Serif+JP |
| Noto Sans JP | https://fonts.google.com/noto/specimen/Noto+Sans+JP |
| JetBrains Mono | https://github.com/JetBrains/JetBrainsMono/releases |

### CJK subsetting (APK size guard)

Source Han Serif SC + Sans SC full-set are ≈ 17 MB each. Subset to GB2312
(common 6,763 chars) before shipping:

```bash
# uses fonttools (pip install fonttools)
pyftsubset SourceHanSerifSC-Regular.otf \
  --unicodes-file=gb2312.txt \
  --output-file=SourceHanSerifSC-Regular-subset.otf \
  --no-hinting --desubroutinize --layout-features=''
```

Expect ~3 MB per weight, total ≈ 5–8 MB add to APK as DESIGN.md predicts.

### Web font-display: optional

For the web build, add to `web/index.html` `<head>`:

```html
<style>
  @font-face {
    font-family: 'Source Han Serif SC';
    src: url('assets/fonts/SourceHanSerifSC-Regular-subset.otf') format('opentype');
    font-display: optional; /* prevents FOIT and 1st-paint jank */
  }
  /* repeat per family */
</style>
```

This is the DESIGN.md §3 mandate — first paint uses system serif (Mac
STSong / Win 宋体), second paint swaps to Source Han Serif SC silently.

---

## 3. main.dart wiring

Replace the v1 `AppTheme.getTheme(...)` calls with the new factories:

```diff
- import 'package:hananote/app/theme/app_theme.dart';
+ import 'package:hananote/app/theme/hana_tokens.dart';

  MaterialApp.router(
-   theme: AppTheme.getTheme(AppThemeType.sakura),
-   darkTheme: AppTheme.getTheme(AppThemeType.sakura, brightness: Brightness.dark),
+   theme: HanaTokens.lightTheme(),
+   darkTheme: HanaTokens.darkTheme(),
    themeMode: ThemeMode.system,
    ...
  );
```

Keep `app_theme.dart` and `hana_colors.dart` in the tree for now — they will
be deleted in PR 4 (theme cleanup) after every screen has been migrated to
`HanaTokens`. **Do not delete them in PR 1.** The v1 → v2 migration touches
~14 features and has to land in stages.

---

## 4. v1 → v2 deprecation path for `hana_colors.dart`

The legacy `HanaColors` class will live alongside `HanaTokens` for the
duration of Phase 5. Mark it `@Deprecated` on PR 1 so the analyzer surfaces
every remaining call site without breaking the build:

```dart
// at the top of lib/app/theme/hana_colors.dart
@Deprecated('Use HanaTokens.<name>(context) — see lib/app/theme/hana_tokens.dart')
class HanaColors { ... }
```

Each subsequent PR (PR 2 = today_page, PR 3 = blood_test/journal, …) burns
the deprecated calls down. The class is deleted only when `dart analyze`
shows zero references and `git grep HanaColors` returns empty.

---

## 5. Test strategy

### Unit / widget tests added in PR 1 (target: +20 tests)

- `test/core/widgets/hana_card_test.dart`
  - renders `surfaceContainerLowest` background in light mode
  - renders dark equivalent in dark mode
  - `tappable` variant fires `onTap`
  - press scale animates to 0.98
  - has no `BoxShadow` in render tree (regression guard)
- `test/core/widgets/hana_button_test.dart`
  - all 4 variants render the spec'd colors
  - disabled state has 38% opacity and ignores taps
  - loading state shows `CircularProgressIndicator`, suppresses taps
  - 44dp minimum height in BoxConstraints
- `test/core/widgets/hana_top_bar_test.dart`
  - has `surfaceContainerHigh` background
  - has NO `BackdropFilter` in render tree (regression guard)
  - underline opacity = 0 when `scrollController.offset == 0`
  - underline opacity = 1 after scrolling
- `test/core/widgets/hana_celebration_test.dart`
  - opacity stays 0 during the first 400ms
  - peaks at 1.0 during hold window
  - returns to 0 by t=3400ms
  - second `show()` cancels the first (no overlapping entries)

### Visual regression (defer to PR 2+)

`golden_toolkit` snapshots for each component in light + dark — added when
the first screen is migrated, not in PR 1.

### Manual smoke (every PR in Phase 5)

1. `flutter run -d emulator-5554` → verify Today page background = #F4F1EA
2. Toggle system dark → verify background = #1C1A18
3. Trigger `HanaCelebration.show(context)` from a debug button → confirm
   silent 0.4s, fade-in, hold, fade-out
4. Long scroll on a list page → confirm 0.5px line under top bar fades in

---

## 6. PR 1 commit split (recommended)

Keep PR 1 reviewable by splitting it into 5 commits:

```
1. feat(theme): add HanaTokens v2 single-API token registry
   - lib/app/theme/hana_tokens.dart (new)
   - test/app/theme/hana_tokens_test.dart (new, smoke tests)

2. chore(theme): deprecate HanaColors with migration pointer
   - lib/app/theme/hana_colors.dart (one-line @Deprecated annotation)
   - lib/app/theme/app_theme.dart (one-line @Deprecated annotation)

3. feat(widgets): add HanaPressScale atomic press feedback
   - lib/core/widgets/hana_press_scale.dart (new)
   - test/core/widgets/hana_press_scale_test.dart (new)

4. feat(widgets): add HanaCard / HanaButton P0 components
   - lib/core/widgets/hana_card.dart (new)
   - lib/core/widgets/hana_button.dart (new)
   - tests for both

5. feat(widgets): add HanaTopBar + HanaCelebration replacing v1 chrome
   - lib/core/widgets/hana_top_bar.dart (new, replaces GlassAppBar usage)
   - lib/core/widgets/hana_celebration.dart (new)
   - lib/core/widgets/petal_celebration.dart (UNTOUCHED — deleted in PR 2)
   - tests for both
```

PR 1 does NOT migrate any feature pages. It only **adds** the v2 toolkit.
Page-by-page migration is PR 2 and beyond.

---

## 7. Known gotchas

- **`Color.withValues(alpha:)`** — used in the snippets instead of the
  deprecated `withOpacity`. Requires Flutter 3.27+; CI is on 3.38.4 so fine.
- **`HanaCelebration` and `Overlay.maybeOf`** — caller MUST pass a context
  that sits under a `MaterialApp` (or any `Overlay`). Passing a top-level
  app context before runApp completes will silently no-op.
- **`HanaTopBar.scrollController`** — the bar listens but does not own the
  controller. Pages that use it must hold the controller in state and
  dispose it themselves.
- **`HanaPressScale` ignores `null` onTap** — animation still runs because
  the gesture detector still fires; pass `enabled: false` if you want
  total inert behavior.
- **No `flutter_animate` / `confetti` / particle libs needed** — if you find
  yourself reaching for one, you've drifted from v2 spec.

---

## 8. Acceptance for PR 1

PR is ready to merge when:

- [ ] All 6 snippet files copied to `lib/` with imports rewritten
- [ ] `pubspec.yaml` font block lands with all 7 font families
- [ ] `flutter pub get` clean
- [ ] `dart analyze --fatal-infos` clean
- [ ] `flutter test` shows baseline 323 + ~20 new = ~343 passing
- [ ] `flutter build apk --debug` succeeds
- [ ] `flutter build web` succeeds
- [ ] `main.dart` references `HanaTokens.lightTheme()` / `darkTheme()`
- [ ] `HanaColors` and `AppTheme` carry `@Deprecated` annotations
- [ ] Manual smoke pass on Android emulator + Chrome (web)

When this checklist is green, PR 1 is the foundation. PR 2 begins the
feature-page migration with `today_page.dart` (highest visual impact).
