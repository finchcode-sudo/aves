import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/trash/trash_controller.dart';
import 'package:aves/widgets/trash/trash_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// ReFra `TrashSelectionSheet`.
///
/// A floating card anchored to the bottom-end corner of the screen while a
/// selection is active:
/// * top row: a `Close` pill showing the selected count, and `Select all`;
/// * bottom card: `Restore` and `Delete`, 32dp icons over their labels,
///   inside an elevated extra-large rounded surface.
class TrashSelectionSheet extends StatelessWidget {
  final CollectionLens collection;

  const TrashSelectionSheet({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selection = context.watch<Selection<AvesEntry>>();
    final controller = context.read<TrashController>();

    final allMedia = collection.sortedEntries;
    final selectedSet = selection.selectedItems;
    // keep the collection order, like ReFra's `media.selectedMedia(selectedSet)`
    final selectedMedia = allMedia.where(selectedSet.contains).toList();
    final allSelected = allMedia.isNotEmpty && selection.isSelected(allMedia);

    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(
          left: 32,
          right: 32,
          bottom: 16 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                _SelectionPill(
                  count: selectedMedia.length,
                  onPressed: () {
                    // `browse` both ends the selection and clears it
                    selection.browse();
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (allSelected) {
                          selection.clearSelection();
                        } else {
                          selection.addToSelection(allMedia);
                        }
                      },
                      child: Text(
                        allSelected ? TrashStrings.selectNone : TrashStrings.selectAll,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: theme.colorScheme.surfaceContainerHigh,
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SelectionBarItem(
                    icon: Icons.restore_from_trash,
                    title: TrashStrings.restore,
                    onPressed: () => controller.open(TrashAction.restore, selectedMedia),
                  ),
                  _SelectionBarItem(
                    icon: Icons.delete_outline,
                    title: TrashStrings.delete,
                    onPressed: () => controller.open(TrashAction.delete, selectedMedia),
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

class _SelectionPill extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _SelectionPill({
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 2,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close,
                size: 20,
                color: color,
                semanticLabel: TrashStrings.closeContentDescription,
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionBarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const _SelectionBarItem({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32,
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}