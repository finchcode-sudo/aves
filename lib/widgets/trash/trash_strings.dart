/// Text resources for the trash experience.
///
/// Every entry below mirrors ReFra's `app/src/main/res/values/strings.xml`
/// one to one — same wording, same punctuation, same capitalisation — so both
/// apps read identically.
///
/// Why not `lib/l10n/app_en.arb`? The generated localization (`lib/l10ngen`)
/// is git ignored and produced by `flutter gen-l10n` at build time. Adding ARB
/// keys without regenerating would break `context.l10n.<newKey>` references,
/// so the ReFra parity strings are kept in one place instead.
class TrashStrings {
  const TrashStrings._();

  // page / navigation
  static const String pageTitle = 'Trash';

  // empty state
  static const String emptyTitle = 'Trash is empty';
  static const String emptyContentDescription = 'Trash is empty';

  // footer
  static const String restoreAll = 'Restore all';
  static const String deleteAllPermanently = 'Delete all permanently';
  static const String deletionWarning = 'Photos and videos you delete will be removed after 30 days.';

  // selection sheet
  static const String restore = 'Restore';
  static const String delete = 'Delete';
  static const String selectAll = 'Select all';
  static const String selectNone = 'Deselect all';
  static const String closeContentDescription = 'Close';

  // app bar actions (ReFra `TrashedNavActions`)
  // TODO: `delete` is shared with the selection sheet on purpose: ReFra shows
  // `action_delete` while a selection is active and `trash_empty` otherwise.
  static const String empty = 'Empty';

  // dialog titles
  static const String dialogToTrash = 'Moving to Trash';
  static const String dialogDelete = 'Deleting Permanently';
  static const String dialogFromTrash = 'Restoring from Trash';

  // dialog progress
  static String items(int count) => '$count items';

  static String trashing(int count) => 'Trashing $count items..';

  static String deleting(int count) => 'Deleting $count items…';

  static String restoring(int count) => 'Restoring $count items..';

  // dialog preview
  static const String longPressToRemove = 'Long press to remove';

  // dialog buttons
  static const String moveToTrash = 'Move to Trash';
  static const String deletePermanently = 'Delete permanently';
  static const String confirmed = 'Confirmed';
  static const String cancel = 'Cancel';

  // untrashable warning (items that cannot go through a recoverable trash path)
  static const String untrashableTitle = 'Some items cannot be trashed!';
  static const String untrashableSummary = 'Such items will be deleted permanently instead.';
}