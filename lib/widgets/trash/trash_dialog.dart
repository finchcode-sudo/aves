import 'package:aves/model/entry/entry.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves/widgets/trash/trash_actions.dart';
import 'package:aves/widgets/trash/trash_controller.dart';
import 'package:aves/widgets/trash/trash_strings.dart';
import 'package:material_ui/material_ui.dart';

/// ReFra `TrashDialog`, rendered as an in-page bottom sheet.
///
/// ReFra drives a Material3 `ModalBottomSheet` through a hoisted
/// `AppBottomSheetState`. Aves has no bottom sheet infrastructure and the
/// dialog must stay inside the trash page provider subtree (it needs
/// `CollectionSource`, `Selection`, `Settings`), so the sheet is built directly
/// as a page-level overlay — same visuals, same states:
///
/// * title (`Moving to Trash` / `Deleting Permanently` / `Restoring from Trash`)
///   over a `N items` subtitle;
/// * a horizontal preview of 80x120 tiles, long press removes one from the
///   batch, tap hints how to remove;
/// * `Cancel` (tertiary container) and the main action button;
/// * once confirmed the title is swapped for `Deleting N items…` style progress
///   and the main button reads `Confirmed`.
class TrashDialog extends StatefulWidget {
  final TrashRequest request;
  final TrashController controller;
  final VoidCallback onCompleted;

  const TrashDialog({
    super.key,
    required this.request,
    required this.controller,
    required this.onCompleted,
  });

  @override
  State<TrashDialog> createState() => _TrashDialogState();
}

class _TrashDialogState extends State<TrashDialog> {
  late List<AvesEntry> _media;
  bool _confirmed = false;
  bool _running = false;
  int _resolvedItemCount = 0;

  @override
  void initState() {
    super.initState();
    _media = List.of(widget.request.entries);
  }

  TrashAction get _action => widget.request.action;

  String get _title {
    final t = TrashStrings.of(context);
    switch (_action) {
      case TrashAction.delete:
        return t.dialogDelete;
      case TrashAction.restore:
        return t.dialogFromTrash;
    }
  }

  String get _progressText {
    final t = TrashStrings.of(context);
    final count = _resolvedItemCount > 0 ? _resolvedItemCount : _media.length;
    switch (_action) {
      case TrashAction.delete:
        return t.deleting(count);
      case TrashAction.restore:
        return t.restoring(count);
    }
  }

  String get _mainButtonText {
    final t = TrashStrings.of(context);
    if (_confirmed) return t.confirmed;
    switch (_action) {
      case TrashAction.delete:
        return t.deletePermanently;
      case TrashAction.restore:
        return t.restore;
    }
  }

  void _cancel() {
    if (_running) return;
    widget.controller.close();
  }

  void _removeItem(AvesEntry entry) {
    if (_confirmed) return;
    setState(() {
      _media.remove(entry);
    });
    if (_media.isEmpty) {
      // ReFra closes the sheet and restores the full batch when the last
      // preview tile is dismissed
      widget.controller.close();
    }
  }

  Future<void> _confirm() async {
    if (_running) return;
    final entries = _media.toSet();
    if (entries.isEmpty) {
      widget.controller.close();
      return;
    }
    setState(() {
      _confirmed = true;
      _running = true;
      _resolvedItemCount = entries.length;
    });
    final completed = await TrashActions.run(
      context,
      action: _action,
      entries: entries,
    );
    if (!mounted) return;
    setState(() {
      _running = false;
      // keep the sheet open when the user aborted (e.g. denied a permission),
      // so that the batch is not silently lost
      _confirmed = completed;
    });
    if (completed) {
      widget.controller.close();
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * .85;

    return Stack(
      children: [
        // scrim
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _cancel,
            child: const ColoredBox(color: Colors.black54),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Material(
              color: colorScheme.surfaceContainerLow,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // drag handle
                      Center(
                        child: Container(
                          width: 32,
                          height: 4,
                          margin: const EdgeInsets.only(top: 22, bottom: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: .4),
                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _confirmed
                            ? Padding(
                                key: const ValueKey('trash-dialog-progress'),
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  _progressText,
                                  style: theme.textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Padding(
                                key: const ValueKey('trash-dialog-title'),
                                padding: const EdgeInsets.all(24),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _title,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\n${TrashStrings.of(context).items(_media.length)}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      ),
                      if (_media.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _media.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final entry = _media[index];
                              return _TrashPreviewTile(
                                key: ValueKey(entry.uri),
                                entry: entry,
                                enabled: !_confirmed,
                                onLongPress: () => _removeItem(entry),
                                onTap: () {
                                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                    SnackBar(
                                      content: Text(TrashStrings.of(context).longPressToRemove),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            if (!_confirmed) ...[
                              Expanded(
                                child: FilledButton(
                                  onPressed: _cancel,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colorScheme.tertiaryContainer,
                                    foregroundColor: colorScheme.onTertiaryContainer,
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  child: Text(TrashStrings.of(context).cancel),
                                ),
                              ),
                              const SizedBox(width: 24),
                            ],
                            Expanded(
                              child: FilledButton(
                                onPressed: _confirmed ? null : _confirm,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                child: Text(
                                  _mainButtonText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrashPreviewTile extends StatelessWidget {
  final AvesEntry entry;
  final bool enabled;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const _TrashPreviewTile({
    super.key,
    required this.entry,
    required this.enabled,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onLongPress: enabled ? onLongPress : null,
      onTap: enabled ? onTap : null,
      child: Container(
        width: 80,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(
            color: colorScheme.onSurfaceVariant,
            width: .5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ThumbnailImage(
          entry: entry,
          extent: 120,
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        ),
      ),
    );
  }
}