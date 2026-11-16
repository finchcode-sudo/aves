import 'package:aves/l10n/l10n.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

/// ReFra's trash copy, resolved through Aves' localization pipeline.
///
/// ReFra reads every label from `res/values/strings.xml` (+ `values-zh-rCN`,
/// `values-zh-rTW`, ...), so it follows the system language. The same 26
/// messages were copied verbatim into `lib/l10n/app_en.arb`, `app_zh.arb` and
/// `app_zh_Hant.arb` under the `trash*` prefix, which makes the trash screen
/// behave like the rest of Aves instead of being hardcoded English.
///
/// This class is a thin, typed facade over those generated getters so the
/// widgets keep reading like ReFra's Compose code.
class TrashStrings {
  final AppLocalizations _l10n;

  const TrashStrings(this._l10n);

  static TrashStrings of(BuildContext context) => TrashStrings(context.l10n);

  // page / navigation (ReFra `trash`)
  String get pageTitle => _l10n.trashPageTitle;

  // empty state (`trash_empty_state_title`, `empty_trash_cd`)
  String get emptyTitle => _l10n.trashEmptyStateTitle;

  String get emptyContentDescription => _l10n.trashEmptyStateContentDescription;

  // footer (`trash_restore_all`, `action_delete_all_permanently`,
  // `trash_deletion_warning`)
  String get restoreAll => _l10n.trashRestoreAll;

  String get deleteAllPermanently => _l10n.trashDeleteAllPermanently;

  String get deletionWarning => _l10n.trashDeletionWarning;

  // selection sheet (`trash_restore`, `action_delete`, `trash_empty`,
  // `select_all`, `clear_selection`, `selection_dialog_close_cd`)
  String get restore => _l10n.trashRestore;

  String get delete => _l10n.trashDelete;

  String get empty => _l10n.trashEmpty;

  String get selectAll => _l10n.trashSelectAll;

  String get clearSelection => _l10n.trashClearSelection;

  String get closeContentDescription => _l10n.trashSelectionCloseContentDescription;

  // dialog (`dialog_to_trash`, `dialog_delete`, `dialog_from_trash`)
  String get dialogToTrash => _l10n.trashDialogToTrash;

  String get dialogDelete => _l10n.trashDialogDelete;

  String get dialogFromTrash => _l10n.trashDialogFromTrash;

  // dialog progress (`s_items`, `trashing_items`, `deleting_items`,
  // `restoring_items`)
  String items(int count) => _l10n.trashItemsCount(count);

  String trashing(int count) => _l10n.trashTrashingItems(count);

  String deleting(int count) => _l10n.trashDeletingItems(count);

  String restoring(int count) => _l10n.trashRestoringItems(count);

  // dialog preview + buttons (`long_press_to_remove`, `action_move_to_trash`,
  // `action_delete_permanently`, `action_confirmed`, `action_cancel`)
  String get longPressToRemove => _l10n.trashLongPressToRemove;

  String get moveToTrash => _l10n.trashMoveToTrash;

  String get deletePermanently => _l10n.trashDeletePermanently;

  String get confirmed => _l10n.trashConfirmed;

  String get cancel => _l10n.trashCancel;

  // items that cannot go through the trash path (`trash_incompatible_*`)
  String get incompatibleTitle => _l10n.trashIncompatibleTitle;

  String get incompatibleSummary => _l10n.trashIncompatibleSummary;
}