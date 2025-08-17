import '../core_presentation_import.dart';

Future<bool?> showInquiryConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  bool? isShowButton = true,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return showDialog<bool?>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outline, width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 제목 + 내용
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        height(15),
                        Text(
                          content,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isShowButton == true) height(20),
                  if (isShowButton == true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 취소 버튼
                        FilledButton(
                          onPressed:
                              () => Navigator.of(dialogContext).pop(false),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.onSurface.withOpacity(
                              0.12,
                            ),
                            minimumSize: const Size(80, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        width(10),
                        // 확인 버튼
                        FilledButton(
                          onPressed:
                              () => Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            minimumSize: const Size(80, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '확인',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  height(10),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
