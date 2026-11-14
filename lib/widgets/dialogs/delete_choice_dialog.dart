import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:material_ui/material_ui.dart';

enum DeleteChoice { moveToBin, deleteForever }

class DeleteChoiceDialog extends StatefulWidget {
  static const routeName = '/dialog/delete_choice';

  const DeleteChoiceDialog({super.key});

  @override
  State<DeleteChoiceDialog> createState() => _DeleteChoiceDialogState();
}

class _DeleteChoiceDialogState extends State<DeleteChoiceDialog> {
  DeleteChoice _choice = DeleteChoice.moveToBin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AvesDialog(
      title: l10n.deleteDialogTitle,
      scrollableContent: [
        RadioGroup<DeleteChoice>(
          groupValue: _choice,
          onChanged: (v) => setState(() => _choice = v!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioListTile<DeleteChoice>(
                value: DeleteChoice.moveToBin,
                title: Text(l10n.deleteDialogMoveToBinLabel),
              ),
              RadioListTile<DeleteChoice>(
                value: DeleteChoice.deleteForever,
                title: Text(l10n.deleteDialogDeleteForeverLabel),
              ),
            ],
          ),
        ),
      ],
      actions: [
        const CancelButton(),
        OkButton<DeleteChoice>(result: _choice),
      ],
    );
  }
}
