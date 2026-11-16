import 'package:aves/model/entry/entry.dart';
import 'package:flutter/foundation.dart';

/// The removal actions ReFra offers from the trash screen.
///
/// `Trash` is intentionally absent: the trash screen can only permanently
/// delete or restore. Moving to the trash happens on the collection screen.
enum TrashAction {
  delete,
  restore,
}

/// One pending confirmation, mirroring ReFra's `TrashDialog(appBottomSheetState, data, action)`.
@immutable
class TrashRequest {
  final TrashAction action;
  final List<AvesEntry> entries;

  const TrashRequest({
    required this.action,
    required this.entries,
  });

  TrashRequest copyWith({List<AvesEntry>? entries}) => TrashRequest(
    action: action,
    entries: entries ?? this.entries,
  );
}

/// Holds the pending trash confirmation so that any part of the trash screen
/// (footer buttons, floating selection sheet) can open the same dialog, and the
/// dialog itself survives collection rebuilds.
class TrashController extends ChangeNotifier {
  TrashRequest? _request;

  TrashRequest? get request => _request;

  void open(TrashAction action, Iterable<AvesEntry> entries) {
    if (entries.isEmpty) return;
    _request = TrashRequest(action: action, entries: entries.toList());
    notifyListeners();
  }

  void close() {
    if (_request == null) return;
    _request = null;
    notifyListeners();
  }
}
