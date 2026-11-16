/// Port of ReFra `TrashActionPolicy.kt`.
///
/// ReFra mixes local and cloud items in one removal batch, so it needs a pure
/// classifier telling apart what may be trashed, what a provider can only
/// delete permanently, and what must never be touched.
///
/// Aves is local-only (no cloud provider), which means every item classifies as
/// [RemovalClass.trashable] — but the structure is kept identical to ReFra so
/// the trash pipeline makes the same decisions on the same inputs instead of
/// hard-coding "local = trashable" at the call site.

/// How one item inside a removal batch is handled.
///
/// * [trashable]   — can go through a recoverable trash path
///                   (locals via MediaStore, cloud items whose provider has a
///                   real bin).
/// * [deleteOnly]  — a cloud item whose provider has no recoverable trash: its
///                   `trashAsset` is a permanent delete, so under a TRASH action
///                   it is deleted permanently *and the dialog must warn about
///                   it*.
/// * [blocked]     — a cloud item on a read-only account: never mutated.
enum RemovalClass {
  trashable,
  deleteOnly,
  blocked,
}

/// Pure classifier — [isCloud] is a parameter (not read off the item) so the
/// full truth table is expressible without a cloud provider.
RemovalClass removalClass({
  required bool isCloud,
  required bool isReadOnlyCloud,
  required bool providerSupportsTrash,
}) {
  if (!isCloud) return RemovalClass.trashable;
  if (isReadOnlyCloud) return RemovalClass.blocked;
  if (providerSupportsTrash) return RemovalClass.trashable;
  return RemovalClass.deleteOnly;
}

class RemovalPlan<T> {
  final List<T> trashable;
  final List<T> deleteOnly;
  final List<T> blocked;

  const RemovalPlan({
    required this.trashable,
    required this.deleteOnly,
    required this.blocked,
  });

  /// Everything a DELETE action may remove.
  List<T> get targets => [...trashable, ...deleteOnly];
}

RemovalPlan<T> planRemoval<T>(
  Iterable<T> items, {
  required bool Function(T) isReadOnlyCloud,
  required bool Function(T) providerSupportsTrash,
  bool Function(T)? isCloud,
}) {
  bool isCloudOf(T item) => isCloud?.call(item) ?? false;

  final trashable = <T>[];
  final deleteOnly = <T>[];
  final blocked = <T>[];
  for (final item in items) {
    final cls = removalClass(
      isCloud: isCloudOf(item),
      isReadOnlyCloud: isReadOnlyCloud(item),
      providerSupportsTrash: providerSupportsTrash(item),
    );
    if (cls == RemovalClass.trashable) {
      trashable.add(item);
    } else if (cls == RemovalClass.deleteOnly) {
      deleteOnly.add(item);
    } else {
      blocked.add(item);
    }
  }
  return RemovalPlan(trashable: trashable, deleteOnly: deleteOnly, blocked: blocked);
}