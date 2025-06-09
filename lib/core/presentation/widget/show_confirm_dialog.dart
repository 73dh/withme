import '../core_presentation_import.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String text,
  required Future<void> Function() onConfirm,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ConfirmDialog(text: text, onConfirm: onConfirm),
  );
}
