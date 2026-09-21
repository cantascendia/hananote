// ignore_for_file: lines_longer_than_80_chars
// Release prep note: This internal page exposes app-only widgets, so full
// dartdoc coverage is deferred to the documentation pass.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';
import 'package:hananote/features/journal/presentation/bloc/record_bloc.dart';
import 'package:hananote/features/journal/presentation/bloc/record_state.dart';
import 'package:intl/intl.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        final todayStr = DateFormat.MMMd(localeTag).format(DateTime.now());

        if (state is RecordInitial || state is RecordLoading) {
          return const Scaffold(
            backgroundColor: HanaColors.background,
            body: Center(
              child: CircularProgressIndicator(color: HanaColors.primary),
            ),
          );
        }

        if (state case RecordError(:final message)) {
          return Scaffold(
            backgroundColor: HanaColors.background,
            body: Center(
              child: Text(
                message,
                style: const TextStyle(color: HanaColors.onSurfaceVariant),
              ),
            ),
          );
        }

        var moodTag = l10n.recordDiaryEmpty;
        var photoTag = l10n.recordPhotoEmpty;
        var measureTag = l10n.recordMeasureEmpty;

        state.mapOrNull(
          loaded: (loadedState) {
            if (loadedState.journalStreak > 0) {
              moodTag = l10n.recordStreak(loadedState.journalStreak);
            }
            if (loadedState.lastPhotoDate != null) {
              final dateStr =
                  DateFormat.MMMd(localeTag).format(loadedState.lastPhotoDate!);
              photoTag = l10n.recordLastPhoto(dateStr);
            }
            if (loadedState.lastMeasurementSummary != null) {
              measureTag = loadedState.lastMeasurementSummary!;
            }
          },
        );

        return Scaffold(
          backgroundColor: HanaColors.backgroundOf(context),
          extendBodyBehindAppBar: true,
          appBar: HoyoAppBar(
            title: l10n.recordTitle,
            subtitle: todayStr,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: topPadding),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    l10n.recordGreeting,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w800,
                          color: HanaColors.primary,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                _StitchRecordCard(
                  icon: Icons.camera_alt,
                  title: l10n.recordPhoto,
                  subtitle: l10n.recordPhotoSub,
                  tag: photoTag,
                  accentColor: HanaColors.primaryContainer,
                  bgShapeColor: HanaColors.primaryContainer.withAlpha(26),
                  tagBgColor: HanaColors.primaryContainer.withAlpha(77),
                  tagTextColor: HanaColors.primary,
                  bgIcon: Icons.photo_library,
                  bgIconRotation: 12 * 3.14159 / 180,
                  bgShapeAlignment: Alignment.topRight,
                  onTap: () => context.push('/photo'),
                ),
                const SizedBox(height: 24),
                _StitchRecordCard(
                  icon: Icons.straighten,
                  title: l10n.recordMeasurement,
                  subtitle: l10n.recordMeasurementSub,
                  tag: measureTag,
                  accentColor: HanaColors.secondary,
                  bgShapeColor: HanaColors.secondaryContainer.withAlpha(51),
                  tagBgColor: HanaColors.secondaryContainer.withAlpha(128),
                  tagTextColor: HanaColors.secondary,
                  bgIcon: Icons.monitor_weight_outlined,
                  bgIconRotation: -12 * 3.14159 / 180,
                  bgShapeAlignment: Alignment.bottomLeft,
                  onTap: () => context.push('/measurement'),
                ),
                const SizedBox(height: 24),
                _StitchRecordCard(
                  icon: Icons.menu_book,
                  title: l10n.recordDiary,
                  subtitle: l10n.recordDiarySub,
                  tag: moodTag,
                  accentColor: HanaColors.primary,
                  bgShapeColor: HanaColors.secondaryContainer.withAlpha(26),
                  tagBgColor: HanaColors.surfaceContainerHigh,
                  tagTextColor: HanaColors.onSurfaceVariant,
                  iconContainerColor: HanaColors.surfaceContainerHigh,
                  bgIcon: Icons.auto_stories,
                  bgIconRotation: 6 * 3.14159 / 180,
                  bgShapeAlignment: Alignment.center,
                  onTap: () => context.push('/journal/edit'),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Icon(
                        Icons.spa,
                        size: 64,
                        color: HanaColors.primary.withAlpha(77),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: HanaColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    l10n.recordFooter,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: HanaColors.primary.withAlpha(153),
                          letterSpacing: 2,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StitchRecordCard extends StatefulWidget {
  const _StitchRecordCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.accentColor,
    required this.bgShapeColor,
    required this.tagBgColor,
    required this.tagTextColor,
    required this.bgIcon,
    required this.bgIconRotation,
    required this.bgShapeAlignment,
    this.iconContainerColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color accentColor;
  final Color bgShapeColor;
  final Color tagBgColor;
  final Color tagTextColor;
  final Color? iconContainerColor;
  final IconData bgIcon;
  final double bgIconRotation;
  final Alignment bgShapeAlignment;
  final VoidCallback? onTap;

  @override
  State<_StitchRecordCard> createState() => _StitchRecordCardState();
}

class _StitchRecordCardState extends State<_StitchRecordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanDown(DragDownDetails details) => _controller.forward();
  void _onPanCancel() => _controller.reverse();
  void _onPanEnd(DragEndDetails details) => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      onPanDown: _onPanDown,
      onPanCancel: _onPanCancel,
      onPanEnd: _onPanEnd,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HanaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.bgShapeColor),
              boxShadow: [
                BoxShadow(
                  color: widget.bgShapeColor,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: widget.bgShapeAlignment,
                    child: Transform.translate(
                      offset: widget.bgShapeAlignment == Alignment.topRight
                          ? const Offset(32, -32)
                          : widget.bgShapeAlignment == Alignment.bottomLeft
                              ? const Offset(-32, 32)
                              : Offset.zero,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          width: widget.bgShapeAlignment == Alignment.center
                              ? 192
                              : 128,
                          height: widget.bgShapeAlignment == Alignment.center
                              ? 192
                              : 128,
                          decoration: BoxDecoration(
                            color: widget.bgShapeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.iconContainerColor ??
                            widget.accentColor.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: HanaColors.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: HanaColors.onSurfaceVariant
                                          .withAlpha((255 * 0.7).round()),
                                    ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.tagBgColor,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              widget.tag,
                              style: TextStyle(
                                color: widget.tagTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isHovered
                          ? 0
                          : widget.bgIconRotation / (2 * 3.14159),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: Icon(
                        widget.bgIcon,
                        size: 64,
                        color: widget.tagTextColor.withAlpha(51),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
