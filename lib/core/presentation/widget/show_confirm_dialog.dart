import 'package:withme/core/presentation/components/common_confirm_dialog.dart';

import '../core_presentation_import.dart';

Future<bool?> showConfirmDialog(
    BuildContext context, {
      required String text,
      String? confirmButtonText,
      String? cancelButtonText,
      required Future<void> Function()? onConfirm,
    }) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // Still prevents tapping outside to dismiss
    builder: (context) => CommonConfirmDialog(
      text: text,
      confirmButtonText: confirmButtonText ?? '확인',
      cancelButtonText: cancelButtonText ?? '취소',
      onConfirm: onConfirm??()async{},
    ),
  );
}
