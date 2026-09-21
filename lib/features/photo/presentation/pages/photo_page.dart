import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/photo/domain/entities/photo_entry.dart';
import 'package:hananote/features/photo/presentation/blocs/photo_bloc.dart';
import 'package:hananote/features/photo/presentation/pages/photo_view_page.dart';
import 'package:intl/intl.dart';

/// Encrypted photo gallery grid page.
class PhotoPage extends StatefulWidget {
  /// Creates a [PhotoPage].
  const PhotoPage({super.key});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final Set<String> _requestedThumbnailIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<PhotoBloc, PhotoState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (entries, _) {
            final validIds = entries.map((entry) => entry.id).toSet();
            _requestedThumbnailIds.removeWhere((id) => !validIds.contains(id));
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: HanaColors.background,
        appBar: AppBar(
          title: Text(l10n.photoGallery),
          backgroundColor: HanaColors.surface,
          actions: [
            IconButton(
              tooltip: l10n.addPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              onPressed: () => _showPickerSheet(context),
            ),
          ],
        ),
        body: BlocBuilder<PhotoBloc, PhotoState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => _PhotoErrorState(
                message: message,
                retryLabel: l10n.retry,
                onRetry: () => context.read<PhotoBloc>().add(
                      const PhotoEvent.loadHistory(),
                    ),
              ),
              loaded: (entries, thumbnailCache) {
                if (entries.isEmpty) {
                  return _PhotoEmptyState(
                    title: l10n.photoEmptyTitle,
                    description: l10n.photoEmptyDescription,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final thumbnailBytes = thumbnailCache[entry.id];
                    _requestThumbnailIfNeeded(
                      context,
                      entry: entry,
                      thumbnailBytes: thumbnailBytes,
                    );

                    return _PhotoGridItem(
                      entry: entry,
                      thumbnailBytes: thumbnailBytes,
                      onTap: () => _openPhotoView(
                        context,
                        entry: entry,
                        thumbnailBytes: thumbnailBytes,
                      ),
                      onLongPress: () => _confirmDelete(context, entry),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _requestThumbnailIfNeeded(
    BuildContext context, {
    required PhotoEntry entry,
    required Uint8List? thumbnailBytes,
  }) {
    if (thumbnailBytes != null || !_requestedThumbnailIds.add(entry.id)) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<PhotoBloc>().add(PhotoEvent.loadThumbnail(entry));
    });
  }

  Future<void> _openPhotoView(
    BuildContext context, {
    required PhotoEntry entry,
    required Uint8List? thumbnailBytes,
  }) async {
    final deleted = await context.push<bool>(
      '/photo/view',
      extra: PhotoViewRouteExtra(
        entry: entry,
        initialThumbnail: thumbnailBytes,
      ),
    );

    if ((deleted ?? false) && context.mounted) {
      context.read<PhotoBloc>().add(const PhotoEvent.loadHistory());
    }
  }

  Future<void> _confirmDelete(BuildContext context, PhotoEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.photoDeleteTitle),
        content: Text(l10n.photoDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<PhotoBloc>().add(PhotoEvent.deletePhoto(entry));
    }
  }

  void _showPickerSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<PhotoBloc>();

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.of(context).pop();
                bloc.add(const PhotoEvent.capturePhoto());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoEmptyState extends StatelessWidget {
  const _PhotoEmptyState({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: HanaColors.primaryContainer.withAlpha(80),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                size: 56,
                color: HanaColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: HanaColors.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HanaColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoErrorState extends StatelessWidget {
  const _PhotoErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: HanaColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGridItem extends StatelessWidget {
  const _PhotoGridItem({
    required this.entry,
    required this.thumbnailBytes,
    required this.onTap,
    required this.onLongPress,
  });

  final PhotoEntry entry;
  final Uint8List? thumbnailBytes;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: HanaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnailBytes != null)
                  Hero(
                    tag: 'photo-${entry.id}',
                    child: Image.memory(
                      thumbnailBytes!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  )
                else
                  const _PhotoThumbnailPlaceholder(),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        DateFormat('yyyy.MM.dd').format(entry.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

class _PhotoThumbnailPlaceholder extends StatelessWidget {
  const _PhotoThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HanaColors.primaryContainer,
            HanaColors.surfaceContainerHigh,
          ],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
