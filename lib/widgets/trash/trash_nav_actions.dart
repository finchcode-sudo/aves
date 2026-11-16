import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/trash/trash_controller.dart';
import 'package:aves/widgets/trash/trash_strings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// ReFra `TrashedNavActions`: the trash app bar always offers `Restore`,
/// and either `Delete` (while a selection is active) or `Empty`.
class TrashNavActions extends StatelessWidget {
  final CollectionLens collection;

  const TrashNavActions({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selection = context.watch<Selection<AvesEntry>>();
    final controller = context.read<TrashController>();

    final allMedia = collection.sortedEntries;
    if (allMedia.isEmpty) return const SizedBox.shrink();

    final selectedSet = selection.selectedItems;
    final selectedMedia = allMedia.where(selectedSet.contains).toList();
    // ReFra restores/deletes the selection when there is one, everything otherwise
    final targets = selectedMedia.isEmpty ? allMedia : selectedMedia;
    final color = theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => controller.open(TrashAction.restore, targets),
          child: Text(
            TrashStrings.restore,
            style: TextStyle(color: color),
          ),
        ),
        TextButton(
          onPressed: () => controller.open(TrashAction.delete, targets),
          child: Text(
            selection.isSelecting ? TrashStrings.delete : TrashStrings.empty,
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}