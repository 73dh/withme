import 'package:withme/core/presentation/components/common_confirm_dialog.dart';

import '../core_presentation_import.dart';

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
    barrierDismissible: false, // 바깥 클릭 시 닫히지 않음
    builder: (context) => CommonConfirmDialog(
      text: text,
      confirmButtonText: confirmButtonText ?? '확인',
      cancelButtonText: cancelButtonText ?? '취소',
      onConfirm: onConfirm ?? () async {},
    ),
  );
}

