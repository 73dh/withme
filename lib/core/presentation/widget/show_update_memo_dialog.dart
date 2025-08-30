import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';

import '../core_presentation_import.dart';

Future<String?> showUpdateMemoDialog(
    BuildContext context, {
      required String title,
      String? initMemo, // 초기 메모 값
    }) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final controller = TextEditingController(text: initMemo ?? "");

  return await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 280,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.outline, width: 1.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    height(12),
                    // 메모 입력 필드
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      minLines: 2,
                      decoration: InputDecoration(
                        labelText: '메모',
                        hintText: '메모를 입력하세요',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        labelStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        hintStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      autofocus: true,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    height(20),
                    // 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 취소 버튼
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
                            foregroundColor: colorScheme.onSurface,
                            minimumSize: const Size(80, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('취소', style: textTheme.bodyMedium),
                        ),
                        width(10),
                        // 저장 버튼
                        FilledButton(
                          onPressed: () {
                            final input = controller.text.trim();
                            if (input.isNotEmpty) {
                              Navigator.of(dialogContext).pop(input);
                              showOverlaySnackBar(context, '메모가 저장되었습니다.');
                            } else {
                              showOverlaySnackBar(context, '메모를 입력해주세요.');
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            minimumSize: const Size(80, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '저장',
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
        ),
      );
    },
  );
}
