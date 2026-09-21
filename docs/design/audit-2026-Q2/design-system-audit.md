# HanaNote Design System Audit — 2026 Q2

**Status**: Pre-redesign inventory · v1.2.2 production codebase
**Stance**: Neutral (assume new design language may overturn 花笺/Sakura, product remains a health-record tool)
**Scope**: `lib/app/theme/*` + `DESIGN.md` + `lib/core/widgets/petal_celebration.dart`
**Phase 1 reviewers**: revisit this file in 4–6 weeks before re-auditing

---

## 1. Token Inventory

### 1.1 Color Tokens (Light)

Source: `lib/app/theme/hana_colors.dart:9-66`

| Name | Current value | Usage | In DESIGN.md? | Verdict | Reason |
|---|---|---|---|---|---|
| `background` | `#FFF8F1` (奶油白) | Scaffold bg | Yes (§2 Neutral) | Modify | Identity-tied to 花笺; keep slot, redefine value |
| `surface` | `#FFF8F1` | == background | Implied | Modify | Same hex as background defeats layering — fix in any redesign |
| `surfaceContainerLowest` → `Highest` | 5 ramp `#FFFFFF`→`#E8E1DA` | Card/list stacking | Yes (§2 Surface Hierarchy) | Keep (slots) | M3 5-tier ramp is sound primitive; values can shift |
| `primary` / `onPrimary` / `primaryContainer` / `onPrimaryContainer` | `#864E5A` / `#FFF` / `#FFB7C5` / `#7B4551` | Brand, CTA | Yes (§2 樱色) | Modify | Keep slot taxonomy; values are 花笺-specific |
| `secondary*` set | `#745475` / `#FCD3FB` … | Calm accents | Yes (§2 薰衣草) | Modify | Same — slot survives, value depends on new palette |
| `tertiary*` set | `#AC332A` / `#FFB9B0` … | Health warnings | Yes (§2 珊瑚) | Keep (slot) | Health app needs a dedicated warning channel |
| `error` / `errorContainer` | `#BA1A1A` / `#FFDAD6` | Errors | Implied (WCAG note) | Keep | Required for any UI |
| `onSurface` / `onSurfaceVariant` | `#1E1B17` / `#514345` | Text | Implied | Keep (slot) | Standard M3 |
| `outline` / `outlineVariant` | `#837375` / `#D6C2C4` | Borders | Yes (§4 Ghost Border, opacity 15%) | Modify | Slot OK; opacity rule never codified — see §3 |
| `inverseSurface` / `inverseOnSurface` / `inversePrimary` | dark trio | Snackbars, etc. | No | Keep | M3 standard, low cost |
| `surfaceTint` | `#864E5A` (= primary) | M3 elevation tint | No | Modify | Coupled to primary; revisit if new system drops M3 tinting |
| `surfaceBright` / `surfaceDim` / `surfaceVariant` | `#FFF8F1` / `#DFD9D1` / `#E8E1DA` | M3 extras | No | Drop (audit) | `surfaceBright == background`, `surfaceVariant == surfaceContainerHighest` — duplicates |
| `primaryFixed` / `primaryFixedDim` / `onPrimaryFixed` / `onPrimaryFixedVariant` | 4 tokens | M3 fixed accent | No | **Drop** | Zero references in `lib/` (Grep verified) — pure ceremony |
| `secondaryFixed*` (4 tokens) | — | M3 fixed | No | **Drop** | Zero references |
| `tertiaryFixed*` (4 tokens) | — | M3 fixed | No | **Drop** | Zero references |
| `statusGreen` | `#34D399` | Success states | No | Modify | Outlier — Tailwind emerald, not in palette family. Rename + re-tone or replace with a `success`/`onSuccess` slot pair |

### 1.2 Color Tokens (Dark)

Source: `lib/app/theme/hana_colors.dart:125-165`

| Name | Current value | Verdict | Reason |
|---|---|---|---|
| `background` / `surface` | `#1A1512` (warm dark, no pure black) | Keep (slot) | DESIGN.md §2 forbids pure `#000000` — principle worth keeping; value tied to 花笺 |
| `surfaceContainerLowest` → `Highest` | `#110E0C`→`#413833` 5 ramp | Keep (slot) | Properly distinct in dark (unlike light where lowest collapses to white) |
| `primary` / `onPrimary` / `primaryContainer` / `onPrimaryContainer` | `#FBB3C1` / `#5B1D2F` / `#76344A` / `#FFD9E0` | Modify | Slot OK; tied to Sakura |
| `outline` / `outlineVariant` | `#A08A8C` / `#514345` | Keep (slot) | Standard |
| `statusGreen` | `#34D399` | Modify | Same as light — outlier |
| Dark counterparts to all light slots | full mirror | Keep (slots) | Parity with light is correct |

### 1.3 Gradient Tokens

Source: `lib/app/theme/hana_gradients.dart:9-41`

| Name | Current | Usage (verified) | In DESIGN.md? | Verdict | Reason |
|---|---|---|---|---|---|
| `primaryGradient` | `#FFB7C5 → #FCD3FB`, no angle | Unused (Grep: 0 hits) | Yes (§2 Glass & Gradient, 135°) | **Drop** | Dead token; angle never implemented |
| `countdownGradient` / `countdownGradientDark` + `countdownOf(c)` | 135° pink→lavender | `countdown_card.dart` | Yes | Modify | Function reuse pattern is fine; values are Sakura-specific |
| `takeDoseButtonGradient` / `*Dark` + `takeDoseOf(c)` | pink→thistle | `upcoming_dose_card.dart` | Yes (CTA gradient rule) | Modify | Component-coupled name (`takeDose`) — should be a generic `ctaGradient` semantic if pattern survives |

### 1.4 Shadow Tokens

Source: `lib/app/theme/hana_shadows.dart:7-22`

| Name | Current | Usage (verified) | In DESIGN.md? | Verdict | Reason |
|---|---|---|---|---|---|
| `cardShadow` | blur 24, y+8, `#864E5A @ 4%` | **Only `simulator_page.dart`** | Yes (§4 Ambient Shadows: blur 24, opacity 4–8%) | **Drop** | Effectively dead; cards rely on tonal layering instead. Either re-adopt or delete |
| `navBarShadow` | blur 24, y-4, `#864E5A @ 6%` | Only simulator | Yes | **Drop** | Same — dock uses BackdropFilter not shadow |

### 1.5 Typography

Source: `lib/app/theme/app_theme.dart:67-86,151-170` + `DESIGN.md §3`

| Name | Current | In DESIGN.md? | Verdict | Reason |
|---|---|---|---|---|
| Headline family | `PlusJakartaSans` w800/bold | Yes | Modify | Font choice serves 花笺's "数码纸笺" mood |
| Body / label family | `BeVietnamPro` | Yes | Modify | CJK fallback strategy for Chinese/Japanese is undocumented in code — DESIGN.md mentions 苹方-简 only as comment |
| `display-md` / `headline-sm` / `body-lg` / `label-md` size scale | **Not defined in code** | Yes (§3) | — | Code only sets `fontFamily` + `fontWeight`; no size token ramp. Material defaults leak through. See §3 |
| Letter-spacing for `label-md` ("适当放宽") | Not implemented | Yes | — | Verbal-only |

### 1.6 Spacing / Radius / Motion

| Name | Current | In DESIGN.md? | Verdict | Reason |
|---|---|---|---|---|
| Spacing scale (`spacing.3` / `.4` / `.6`) | **No central tokens** — values inlined per widget | Yes (referenced in §5/§6) | — | DESIGN.md names a scale that doesn't exist in code |
| Card radius `16` | hardcoded `BorderRadius.circular(16)` in `app_theme.dart:97,181` | Yes (§5 "1rem = 16px") | Modify (centralize) | Right value, wrong location — needs a `HanaRadius.card` token |
| Stadium / `full` button radius | `StadiumBorder()` `app_theme.dart:102,186` | Yes (§5) | Keep (slot) | Standard |
| Card scale-down on press (0.98) | Not in theme — case-by-case | Yes (§5 Cards) | — | Behavior token missing |
| Animation duration / curve | `petal_celebration.dart:45` hardcodes `1200ms`; no curve token | No | Modify | No motion token system at all |

---

## 2. Naming Consistency Issues

1. **Two parallel APIs for the same concept.**
   - Static class constants — `HanaColors.primary`, `HanaColorsDark.primary`
   - Context-aware accessors — `HanaColors.primaryOf(context)`
   - Both are exported and used across `lib/`. Components have to choose, and choose differently. This is the largest naming smell. **Recommendation for new system: pick one — `Theme.of(context).colorScheme.primary` is the M3-idiomatic answer; static constants should be palette-only (raw hex), not theme-mode-aware.**

2. **`HanaColorsDark` is a peer class, not nested.** `hana_colors.dart:125` declares `abstract final class HanaColorsDark` at file root. Reads as a sibling, not a variant. Either make it `HanaColors.Dark` or eliminate it entirely in favor of context lookup.

3. **`Of(context)` coverage is incomplete.** 25 `*Of` accessors exist but `surfaceContainerLowOf` covers only some surface levels; `errorContainerOf`, `onErrorContainerOf`, `onSecondaryContainerOf`, `surfaceTintOf` are missing. Callers fall back to constants in inconsistent patterns.

4. **Argument naming.** `BuildContext c` (one-letter) in colors file vs. `BuildContext context` everywhere else in `lib/`. Trivial but visible in API.

5. **Gradient `Of` helpers ≠ Color `Of` helpers.** `HanaGradients.countdownOf(c)` returns `LinearGradient`, `HanaColors.primaryOf(c)` returns `Color`. Naming parallel is good; both should keep the convention.

6. **`statusGreen` breaks family.** Every other color is named by role (`primary`, `onSurface`); this one is named by literal hue. Either promote to semantic (`success`/`onSuccess`) or demote to a true palette swatch.

7. **`takeDoseButtonGradient`** mixes brand semantic (button) with feature (`takeDose`). A redesign should not inherit feature-coupled token names.

8. **`AppThemeType` enum lies.** `app_theme.dart:9-15` exposes 5 themes (sakura, lavender, sky, starryNight, cyberpunk) but `getTheme()` (line 24-33) returns Sakura for all of them. Either fulfill or collapse to `{light, dark}`.

---

## 3. DESIGN.md Promises Not Implemented in Code

Tokens / behaviors named in `DESIGN.md` but absent from `lib/app/theme/`:

| DESIGN.md ref | Promise | Code reality |
|---|---|---|
| §2 Glass & Gradient | "primary → primary-container 135° linear gradient" on CTA/cards | `primaryGradient` in `hana_gradients.dart:9` has no `begin`/`end` (defaults to L→R, not 135°) and is **unused**. `countdownGradient` is the only 135° one, and it uses container colors only |
| §2 Surface Hierarchy | 5-tier `surface-container` ramp from Lowest to Highest | Tokens exist (`hana_colors.dart:11-15`) but `surface == background == #FFF8F1` and `surfaceBright == surface` and `surfaceVariant == surfaceContainerHighest` — three duplicates collapse the ramp |
| §3 Typography | Named scale: `display-md`, `headline-sm`, `body-lg`, `label-md` | Code defines only `fontFamily` + `fontWeight`; no size ramp, no letter-spacing tokens |
| §4 Ambient Shadows | "Blur 24, Opacity 4–8%, color = themed `on-surface` sample" | `HanaShadows` uses `0x0A864E5A` (primary-derived, not on-surface), and is referenced only in simulator |
| §4 Glassmorphism | "surface @ 80% opacity + backdrop-blur(12px)" for top nav / dock | `BackdropFilter` is hand-rolled in 13 files (Grep verified); no `HanaBlur.dock` / `HanaBlur.navBar` token, blur radius varies per site |
| §4 Ghost Border | "outline-variant @ 15% opacity, never 100%" | No opacity rule encoded; `outlineVariant` is used at full opacity in multiple places |
| §5 Cards | "spacing.4 inner, spacing.6 outer" + "scale-down to 0.98 on tap" | No spacing token system; no scale-feedback wrapper |
| §5 Inputs | "底层色块 + 2px primary 呼吸线条 only on focus" | No `HanaInputDecoration` — each form rebuilds |
| §5 Med-Capsule | "Asymmetric ellipse using `tertiary-container`" | No reusable component (only `progress_ring.dart` exists) |
| §6 Don'ts | "No standard iOS dialogs — use bottom sheets with large radius" | No central `HanaBottomSheet` / dialog wrapper |

In short: **DESIGN.md describes a richer system than the code implements.** The code holds maybe 40% of the document's vocabulary; the rest lives only as prose.

---

## 4. `petal_celebration.dart` — Experiential Asset Analysis

File: `lib/core/widgets/petal_celebration.dart` (155 lines, only shared widget under `lib/core/widgets/`).
Single caller: `lib/features/medication/presentation/pages/today_page.dart:53` — fired on dose completion.

**API design**
- `PetalCelebration.show(context)` — static, fire-and-forget, self-cleans via `OverlayEntry`. Good shape; matches Flutter idioms (`SnackBar.show`, `showDialog`).
- No customization knobs (count, palette, duration, anchor). For a one-off delight moment this is fine; for a system pattern, it's underspecified.
- Uses `HanaColors.primaryContainer` / `secondaryContainer` directly — palette-coupled, not context-aware. Will look wrong in dark mode (no `*Of(context)` lookup).

**Animation craft**
- 10 petals, single 1200ms `AnimationController`, no easing curve (linear).
- Per-petal randomization (`_Petal` ctor, lines 82-103): position, size, fall speed, sinusoidal wobble (freq + amp), rotation + rotation speed, color binary. This is the asset — physics-tinged variability that reads as natural.
- Fade-out gated to last 40% of timeline (line 122) prevents pop-out.
- `CustomPaint` + `IgnorePointer` is the correct primitive for non-blocking effects.

**What's worth preserving**
- **The pattern**, not necessarily the petals. Health-tracking apps benefit from positive reinforcement on streak-defining actions (dose taken, measurement logged). The `Overlay` + `CustomPainter` + per-particle randomization recipe transfers to any new visual language.
- **Keep as case study, drop as code.** If the redesign moves away from 花笺, the petal shape and pink/lavender palette go with it. The animation skeleton (`_Petal` data class, painter loop, controller wiring) is generic enough to lift into a new `Confetti` / `MicroDelight` primitive.

**Verdict: Modify (extract pattern), Drop (current visual)**

---

## 5. Priority Ranking

### P0 — Blockers for redesign implementation

1. **Pick one color API.** Resolve the `HanaColors.primary` (constant) vs. `HanaColors.primaryOf(context)` (function) vs. `Theme.of(context).colorScheme.primary` (M3) split before any new screen is built. Anything else compounds the inconsistency.
2. **Decide M3 alignment.** Token slot names (`surfaceContainerLowest`, `onPrimaryContainer`, `outlineVariant`) come from Material 3. Either commit to M3 vocabulary or rename to a custom system. Mixing causes drift.
3. **Resolve duplicate surface tokens.** `surface == background == surfaceBright` and `surfaceVariant == surfaceContainerHighest` make the 5-tier ramp a 3-tier ramp in practice. Any redesign touching cards must fix this first.

### P1 — Must solve during redesign

4. **Codify motion tokens.** No durations, curves, or scale-feedback constants exist. Adding `HanaMotion.{fast,medium,slow}` + `HanaMotion.standardCurve` is cheap and unblocks consistent micro-interactions.
5. **Codify spacing + radius.** DESIGN.md names `spacing.3/4/6` and `radius.16/full`; code inlines numbers. A `HanaSpacing` / `HanaRadius` constants class is one-day work.
6. **Centralize blur/glass.** 13 files hand-roll `BackdropFilter`. Add `HanaBlur.dock` / `HanaBlur.navBar` (sigma + surface-opacity pair) to enforce DESIGN.md §4.
7. **Type ramp.** `app_theme.dart:67-86` only sets fontFamily/weight. Need explicit `fontSize` + `letterSpacing` per slot to honor DESIGN.md §3 and ensure CJK readability.
8. **Drop the dead M3 fixed tokens.** 12 `*Fixed*` constants have zero call sites — pure noise that bloats search results.
9. **Either revive or delete `HanaShadows`.** Currently dead except in the simulator screen. Pick one.
10. **Resolve `AppThemeType` enum lie.** Either implement multi-theme or collapse to `{light, dark}`.
11. **Reconcile `statusGreen`.** Outlier from the palette; promote to semantic `success` slot or remove.
12. **Document CJK font fallback strategy.** Code references `BeVietnamPro` but DESIGN.md mentions 苹方-简; no fallback chain is wired. v1.2.2 ships zh + ja locales — this is a real gap, not theory.

### P2 — Optimizations

13. **Standardize `Of(context)` coverage.** Either every theme-aware color has a `*Of` accessor or none do. Half-coverage is the worst state.
14. **Rename feature-coupled tokens.** `takeDoseButtonGradient` → `ctaGradient` if the gradient pattern survives.
15. **Gradient angle declarations.** `primaryGradient` (line 9) has no `begin`/`end` — inherits L→R default, not the 135° DESIGN.md asks for.
16. **Extract petal animation as reusable `MicroDelight` primitive** (see §4) before rewriting the visual layer; preserve the choreography even if the petals go.
17. **Argument-name consistency.** `BuildContext c` → `BuildContext context` in `hana_colors.dart`/`hana_gradients.dart`.

---

## 6. One-page Summary for Phase 1 Reviewer

- **Color slots:** mostly M3-shaped and worth keeping as taxonomy; values are 花笺-specific. ~12 `*Fixed*` tokens are dead.
- **Surfaces:** 5-tier ramp exists but partially collapsed by duplicate hex values — fix before redesigning cards.
- **Gradients:** 3 defined, only 2 used; `primaryGradient` is dead.
- **Shadows:** 2 defined, both effectively dead — DESIGN.md asks for tonal layering, code mostly delivers.
- **Type / spacing / radius / motion:** named in DESIGN.md, **not codified** in `lib/app/theme/`. Largest gap.
- **APIs:** static constants + `*Of(context)` accessors + Material `Theme.of` all coexist. Pick one.
- **petal_celebration.dart:** the only `core/widgets/` shared piece; animation choreography is reusable, visual is identity-locked.
- **DESIGN.md vs. code parity:** ~40%. Document is richer than implementation.

— end —
