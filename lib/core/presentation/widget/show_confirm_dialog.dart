import 'package:withme/core/presentation/components/common_confirm_dialog.dart';

import '../core_presentation_import.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  String? text,
  List<TextSpan>? textSpans,
  String? confirmButtonText,
  String? cancelButtonText,
  Future<void> Function()? onConfirm,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (dialogContext) => CommonConfirmDialog(
          text: text ?? '',
          textSpans: textSpans ?? [],
          confirmButtonText: confirmButtonText ?? '확인',
          cancelButtonText: cancelButtonText ?? '취소',
          onConfirm: () async {
            if (onConfirm != null) {
              await onConfirm();
            }
            // ✅ 다이얼로그만 닫힘
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop(true);
            }
          },
          backgroundColor: colorScheme.surface,
          confirmButtonColor: colorScheme.primary,
          cancelButtonColor: colorScheme.onSurface.withValues(alpha: 0.12),
          confirmTextColor: colorScheme.onPrimary,
          cancelTextColor: colorScheme.onSurface,
        ),
  );
}
