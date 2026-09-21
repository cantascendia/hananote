import 'package:flutter/material.dart';
import 'package:hananote/app/theme/hana_colors.dart';

/// Adds a privacy blur overlay when the app moves out of the foreground.
class AppBlurOverlay extends StatefulWidget {
  /// Creates an [AppBlurOverlay].
  const AppBlurOverlay({
    required this.child,
    this.enabled = true,
    super.key,
  });

  /// The app content shown beneath the privacy layer.
  final Widget child;

  /// Whether the privacy blur overlay should be active.
  final bool enabled;

  @override
  State<AppBlurOverlay> createState() => _AppBlurOverlayState();
}

class _AppBlurOverlayState extends State<AppBlurOverlay>
    with WidgetsBindingObserver {
  late bool _isOverlayVisible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isOverlayVisible = widget.enabled &&
        _shouldShowOverlay(WidgetsBinding.instance.lifecycleState);
  }

  @override
  void didUpdateWidget(covariant AppBlurOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled == widget.enabled) return;

    setState(() {
      _isOverlayVisible = widget.enabled &&
          _shouldShowOverlay(WidgetsBinding.instance.lifecycleState);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldShow = widget.enabled && _shouldShowOverlay(state);
    if (_isOverlayVisible == shouldShow) return;

    setState(() {
      _isOverlayVisible = shouldShow;
    });
  }

  bool _shouldShowOverlay(AppLifecycleState? state) {
    return switch (state) {
      AppLifecycleState.inactive ||
      AppLifecycleState.hidden ||
      AppLifecycleState.paused =>
        true,
      AppLifecycleState.resumed || AppLifecycleState.detached || null => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: _isOverlayVisible,
          child: widget.child,
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_isOverlayVisible,
            child: AnimatedOpacity(
              duration: Duration.zero,
              opacity: _isOverlayVisible ? 1 : 0,
              child: const ColoredBox(
                color: HanaColors.background,
                child: Center(
                  child: ExcludeSemantics(
                    child: Icon(
                      Icons.shield_moon_rounded,
                      size: 64,
                      color: HanaColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
