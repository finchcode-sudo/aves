import 'package:aves/model/entry/entry.dart';
import 'package:aves/widgets/collection/entry_set_action_delegate.dart';
import 'package:aves/widgets/trash/trash_action_policy.dart';
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

    // ReFra `planRemoval`: an item blocked by a read-only provider must never be
    // mutated. Aves is local-only, so nothing is ever blocked, but the decision
    // goes through the same policy instead of being assumed at the call site.
    final plan = planRemoval<AvesEntry>(
      entries,
      isReadOnlyCloud: (_) => false,
      providerSupportsTrash: (_) => true,
    );

    switch (action) {
      case TrashAction.delete:
        final targets = plan.targets.toSet();
        if (targets.isEmpty) return false;
        return _delegate.doDelete(
          context: context,
          entries: targets,
          enableBin: false,
          confirmed: true,
        );
      case TrashAction.restore:
        return _delegate.doMove(
          context,
          moveType: MoveType.fromBin,
          entries: entries,
          confirmed: true,
        );
    }
  }
}