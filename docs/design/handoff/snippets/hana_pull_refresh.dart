import 'package:flutter/material.dart';

import 'hana_tokens.dart';

/// HanaPullRefresh — v2 下拉刷新（替代 Material `RefreshIndicator`）。
///
/// 顶部 1px 黛蓝细进度线 + 一行 mono "刷新中。"。圆环是 Material 痕迹，
/// 进度线是杂志报刊感。
///
/// Spec: `docs/design/design-system/v2/components/pull-refresh.md`.
///
/// 用法：
/// ```dart
/// HanaPullRefresh(
///   onRefresh: () => bloc.add(const RefreshTodaySummary()),
///   child: ListView(...),
/// );
/// ```
///
/// Widget test hint:
/// ```dart
/// testWidgets('HanaPullRefresh fills 1px primary line on overscroll',
///   (tester) async { ... });
/// testWidgets('HanaPullRefresh awaits onRefresh future before dismissing',
///   (tester) async { ... });
/// ```
class HanaPullRefresh extends StatefulWidget {
  const HanaPullRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.triggerDistance = 80,
    this.refreshingLabel = '刷新中。',
    this.semanticLabel,
  });

  /// 刷新回调。完成后进度线自动 fade out。
  final Future<void> Function() onRefresh;

  /// 滚动 child（通常是 `ListView` / `CustomScrollView`）。
  final Widget child;

  /// 触发距离 — 拉动超过该距离松手则触发刷新。默认 80dp。
  final double triggerDistance;

  /// "刷新中。" 文案（来自 ARB）。
  final String refreshingLabel;

  /// 屏幕阅读器标签覆盖。
  final String? semanticLabel;

  @override
  State<HanaPullRefresh> createState() => _HanaPullRefreshState();
}

enum _PullState { idle, pulling, refreshing }

class _HanaPullRefreshState extends State<HanaPullRefresh> {
  _PullState _state = _PullState.idle;
  double _drag = 0;

  bool _onNotification(ScrollNotification n) {
    if (_state == _PullState.refreshing) return false;

    if (n is OverscrollNotification && n.overscroll < 0) {
      setState(() {
        _state = _PullState.pulling;
        _drag = (_drag - n.overscroll).clamp(0, widget.triggerDistance * 1.5);
      });
    } else if (n is ScrollUpdateNotification) {
      if (n.metrics.pixels <= 0 && n.scrollDelta != null && n.scrollDelta! < 0) {
        setState(() {
          _state = _PullState.pulling;
          _drag = (_drag - n.scrollDelta!)
              .clamp(0, widget.triggerDistance * 1.5);
        });
      }
    } else if (n is ScrollEndNotification) {
      if (_state == _PullState.pulling && _drag >= widget.triggerDistance) {
        _trigger();
      } else if (_state == _PullState.pulling) {
        setState(() {
          _state = _PullState.idle;
          _drag = 0;
        });
      }
    }
    return false;
  }

  Future<void> _trigger() async {
    setState(() {
      _state = _PullState.refreshing;
      _drag = widget.triggerDistance;
    });
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _state = _PullState.idle;
          _drag = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_drag / widget.triggerDistance).clamp(0.0, 1.0);
    final showLine = _state != _PullState.idle;
    final showLabel = _state == _PullState.refreshing;

    return Semantics(
      label: showLabel
          ? (widget.semanticLabel ?? widget.refreshingLabel)
          : null,
      liveRegion: showLabel,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: Stack(
          children: [
            widget.child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: showLine ? 1.0 : 0.0,
                duration: HanaTokens.motion.standard,
                curve: HanaTokens.motion.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 1,
                      child: _state == _PullState.refreshing
                          ? LinearProgressIndicator(
                              minHeight: 1,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                HanaTokens.primary(context),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (ctx, c) => Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    width: c.maxWidth * progress,
                                    height: 1,
                                    child: Container(
                                      color: HanaTokens.primary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    if (showLabel)
                      Padding(
                        padding: EdgeInsets.only(
                          top: HanaTokens.spacing.xs,
                          left: HanaTokens.spacing.lg,
                        ),
                        child: Text(
                          widget.refreshingLabel,
                          style: HanaTokens.typography.mono.copyWith(
                            color: HanaTokens.inkSecondary(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
