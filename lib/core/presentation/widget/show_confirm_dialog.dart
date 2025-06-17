import 'package:withme/core/presentation/components/common_confirm_dialog.dart';

import '../core_presentation_import.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String text,
  required Future<void> Function() onConfirm,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => CommonConfirmDialog(text: text, onConfirm: onConfirm),
  );
}
