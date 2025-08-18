import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';

import '../core_presentation_import.dart';

Future<void> showCycleEditDialog(
  BuildContext context, {
  required String title,
  required int initNumber, // 현재 주기를 인자로 받도록 변경
  required ValueChanged<int> onUpdate, // 업데이트 콜백 추가
}) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final controller = TextEditingController(text: initNumber.toString());

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 180,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface, // Theme 적용
                  border: Border.all(color: colorScheme.outline, width: 1.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목 + 입력
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
                          height(10),
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '(예: 60)',
                              hintText: '1 이상의 숫자를 입력하세요',
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
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
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
                            backgroundColor: colorScheme.onSurface.withValues(alpha:
                              0.12,
                            ),
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
                            final input = int.tryParse(controller.text.trim());
                            if (input != null && input > 0) {
                              onUpdate(input);
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                                showOverlaySnackBar(context, '설정이 저장되었습니다.');
                              }
                            } else {
                              showOverlaySnackBar(
                                context,
                                '올바른 숫자를 입력해주세요 (1 이상).',
                              );
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
