import 'package:aves/model/entry/entry.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/trash/trash_controller.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';

/// Bridges ReFra's trash actions to Aves' existing mutation pipeline.
///
/// ReFra calls `MediaHandler.deleteMedia(...)` / `MediaHandler.trashMedia(...)`.
/// Aves already has the equivalent, battle-tested operations on
/// [EntrySetActionDelegate]:
/// * permanent delete -> `doDelete(enableBin: false, confirmed: true)`
/// * restore          -> `doMove(moveType: MoveType.fromBin, confirmed: true)`
///
/// Both already handle permissions, name conflicts, error feedback, monitoring
/// pause/resume and collection refresh, so we delegate rather than re-implement.
class TrashActions {
  const TrashActions._();

  static final EntrySetActionDelegate _delegate = EntrySetActionDelegate();

  /// Runs [action] on [entries] and returns whether it completed
  /// (with or without per-item failures), like ReFra's `MediaMutationResult`.
  static Future<bool> run(
    BuildContext context, {
    required TrashAction action,
    required Set<AvesEntry> entries,
  }) async {
    if (entries.isEmpty) return false;

    switch (action) {
      case TrashAction.delete:
        return _delegate.doDelete(
          context: context,
          entries: entries,
          enableBin: false,
          confirmed: true,
        );
      case TrashAction.restore:
        return _delegate.doMove(
          context: context,
          moveType: MoveType.fromBin,
          entries: entries,
          confirmed: true,
        );
    }
  }
}