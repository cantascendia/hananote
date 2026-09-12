import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// HanaTopBar variants — see `docs/design/design-system/v2/components/top-bar.md`.
enum HanaTopBarVariant {
  /// 56dp title-on-left bar with optional leading + actions.
  defaultBar,

  /// 96dp hero variant — `display-xl` title + 96px+ right whitespace.
  large,

  /// Fully transparent — onboarding / lock screens. No background, no line.
  transparent,
}

/// HanaTopBar — replaces v1's BackdropFilter glass AppBar.
///
/// Solid `surfaceContainerHigh` fill, NO blur, NO shadow. While the attached
/// scroll offset is > 0 a 0.5px outline @ 30% appears below the bar; it
/// fades back out at the top. This is the only solid line v2 permits in
/// chrome.
///
/// Spec: `docs/design/design-system/v2/components/top-bar.md`.
///
/// Pass a [scrollController] from the page so its dispose lifecycle stays
/// owned by the caller — the bar registers a listener but never creates the
/// controller itself.
class HanaTopBar extends StatefulWidget implements PreferredSizeWidget {
  const HanaTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.variant = HanaTopBarVariant.defaultBar,
    this.scrollController,
    this.semanticLabel,
  });

  /// Title text. Always left-aligned (editorial asymmetry).
  final String title;

  /// Leading widget (typically a back button).
  final Widget? leading;

  /// Optional trailing actions.
  final List<Widget>? actions;

  /// Visual variant. See [HanaTopBarVariant].
  final HanaTopBarVariant variant;

  /// External scroll controller — REQUIRED to drive the scrolled-underline
  /// reveal. Caller owns the controller's lifecycle.
  final ScrollController? scrollController;

  /// Accessibility header label override.
  final String? semanticLabel;

  double get _height {
    switch (variant) {
      case HanaTopBarVariant.large:
        return 96;
      case HanaTopBarVariant.defaultBar:
      case HanaTopBarVariant.transparent:
        return kToolbarHeight; // 56
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(_height);

  @override
  State<HanaTopBar> createState() => _HanaTopBarState();
}

class _HanaTopBarState extends State<HanaTopBar> {
  bool _scrolled = false;
  ScrollController? _attached;

  @override
  void initState() {
    super.initState();
    _attach(widget.scrollController);
  }

  @override
  void didUpdateWidget(covariant HanaTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _detach();
      _attach(widget.scrollController);
    }
  }

  void _attach(ScrollController? c) {
    _attached = c;
    c?.addListener(_onScroll);
  }

  void _detach() {
    _attached?.removeListener(_onScroll);
    _attached = null;
  }

  void _onScroll() {
    final c = _attached;
    if (c == null || !c.hasClients) return;
    final scrolled = c.offset > 0;
    if (scrolled != _scrolled) {
      setState(() => _scrolled = scrolled);
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == HanaTopBarVariant.transparent) {
      return SizedBox(height: widget._height + MediaQuery.paddingOf(context).top);
    }

    final isLarge = widget.variant == HanaTopBarVariant.large;
    final titleStyle = (isLarge
            ? HanaTokens.typography.displayXl
            : HanaTokens.typography.title)
        .copyWith(color: HanaTokens.ink(context));

    return Semantics(
      header: true,
      label: widget.semanticLabel ?? widget.title,
      child: Material(
        type: MaterialType.canvas,
        color: HanaTokens.surfaceContainerHigh(context),
        elevation: 0,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: widget._height,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: HanaTokens.spacing.md,
                  ),
                  child: Row(
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        SizedBox(width: HanaTokens.spacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          widget.title,
                          style: titleStyle,
                          maxLines: isLarge ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isLarge && widget.actions != null)
                        ...widget.actions!,
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    opacity: _scrolled ? 1 : 0,
                    duration: HanaTokens.motion.instant,
                    curve: HanaTokens.motion.easeOut,
                    child: Container(
                      height: 0.5,
                      color: HanaTokens.outline(context).withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
