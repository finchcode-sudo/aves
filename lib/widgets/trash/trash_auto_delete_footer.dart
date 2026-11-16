import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/trash/trash_controller.dart';
import 'package:aves/widgets/trash/trash_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// ReFra `AutoDeleteFooter`.
///
/// Sits above the grid (never inside it) and contains:
/// * `Restore all` / `Delete all permanently`, side by side, 16dp apart,
///   64dp tall, `extraLarge` rounded, `titleMedium` semibold — only while the
///   trash is not empty;
/// * an info card (`Info` icon + `Trash` title + retention summary) that is
///   always visible, exactly like ReFra's `SettingsItem(Preference(...))`.
class TrashAutoDeleteFooter extends StatelessWidget {
  final CollectionLens collection;

  const TrashAutoDeleteFooter({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = TrashStrings.of(context);
    // `CollectionGrid` is also used by the picker page, where no trash
    // controller is provided; degrade gracefully instead of crashing there.
    TrashController? controller;
    try {
      controller = context.read<TrashController>();
    } catch (_) {
      controller = null;
    }

    return AnimatedBuilder(
      animation: collection,
      builder: (context, child) {
        final media = collection.sortedEntries;
        return Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: media.isEmpty
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TrashButton(
                                label: t.restoreAll,
                                backgroundColor: theme.colorScheme.tertiaryContainer,
                                foregroundColor: theme.colorScheme.onTertiaryContainer,
                                onPressed: () => controller?.open(TrashAction.restore, media),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _TrashButton(
                                label: t.deleteAllPermanently,
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                onPressed: () => controller?.open(TrashAction.delete, media),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              _TrashInfoCard(
                title: t.pageTitle,
                summary: t.deletionWarning,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mirrors ReFra's `SetupButton`: `ComponentSize.ButtonHeight` (64dp),
/// `MaterialTheme.shapes.extraLarge` (28dp), `titleMedium` semibold, and no
/// line limit — long translations wrap instead of being clipped to `...`.
class _TrashButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const _TrashButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size.fromHeight(64),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TrashInfoCard extends StatelessWidget {
  final String title;
  final String summary;

  const _TrashInfoCard({
    required this.title,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}