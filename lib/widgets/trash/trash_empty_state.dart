import 'package:aves/widgets/trash/trash_strings.dart';
import 'package:material_ui/material_ui.dart';

/// ReFra `EmptyTrash`: a 128dp outlined delete icon tinted with the primary
/// colour, 16dp above a `titleLarge` label, inset 64dp from the top.
class TrashEmptyState extends StatelessWidget {
  final String? title;

  const TrashEmptyState({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = TrashStrings.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 128,
            semanticLabel: t.emptyContentDescription,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            title ?? t.emptyTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}