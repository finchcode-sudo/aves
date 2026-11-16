import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/trash/trash_controller.dart';
import 'package:aves/widgets/trash/trash_dialog.dart';
import 'package:aves/widgets/trash/trash_selection_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Hosts the two overlapping surfaces of the ReFra trash screen:
/// the floating selection sheet (bottom-end) and the confirmation bottom sheet.
///
/// Both live above the whole page so the scrim dims the app bar too, exactly
/// like ReFra's `ModalBottomSheet`.
class TrashOverlay extends StatelessWidget {
  final CollectionLens collection;

  const TrashOverlay({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TrashController>();
    final selecting = context.select<Selection<AvesEntry>, bool>((v) => v.isSelecting);
    final request = controller.request;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            reverseDuration: const Duration(milliseconds: 160),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
            child: selecting
                ? TrashSelectionSheet(
                    key: const ValueKey('trash-selection-sheet'),
                    collection: collection,
                  )
                : const SizedBox.shrink(key: ValueKey('trash-selection-sheet-empty')),
          ),
        ),
        if (request != null)
          Positioned.fill(
            child: TrashDialog(
              request: request,
              controller: controller,
              onCompleted: () {
                // ReFra: `selector.clearSelection()` on RESULT_OK
                context.read<Selection<AvesEntry>>().browse();
              },
            ),
          ),
      ],
    );
  }
}