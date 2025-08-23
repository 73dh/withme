import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../domain/domain_import.dart';

class ConfirmBoxPart extends StatelessWidget {
  final bool isRegistering;
  final CustomerModel? customerModel;
  final TextEditingController nameController;
  final TextEditingController recommendedController;
  final TextEditingController historyController;
  final TextEditingController birthController;
  final TextEditingController registeredDateController;
  final String? sex;
  final DateTime? birth;
  final void Function() onPressed;

  final Color? textColor;
  final Color? backgroundColor;

  const ConfirmBoxPart({
    super.key,
    required this.isRegistering,
    required this.customerModel,
    required this.nameController,
    required this.recommendedController,
    required this.historyController,
    required this.birthController,
    required this.registeredDateController,
    required this.onPressed,
    required this.sex,
    required this.birth,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;
    final effectiveBackground =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: effectiveBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                customerModel == null ? '신규등록 확인' : '수정내용 확인',
                style: textTheme.titleMedium?.copyWith(
                  color: effectiveTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              height(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    '등록자:',
                    '${nameController.text} ($sex)',
                    textTheme,
                    effectiveTextColor,
                  ),
                  _buildInfoRow(
                    '생년월일:',
                    birthController.text.isEmpty
                        ? '추후입력'
                        : birth?.formattedBirth ?? '',
                    textTheme,
                    effectiveTextColor,
                  ),
                  _buildInfoRow(
                    '소개자:',
                    recommendedController.text.isEmpty
                        ? '없음'
                        : recommendedController.text,
                    textTheme,
                    effectiveTextColor,
                  ),
                  _buildInfoRow(
                    '등록일:',
                    registeredDateController.text,
                    textTheme,
                    effectiveTextColor,
                  ),
                ],
              ),
              height(20),
              RenderFilledButton(
                text: customerModel == null ? '등록' : '수정',
                onPressed: onPressed,
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
              ),
              height(30),
            ],
          ),
        ),
        if (isRegistering)
          Positioned(
            left: 10,
            top: 10,
            child: Row(
              children: [
                Text(
                  '저장중',
                  style: textTheme.bodyMedium?.copyWith(
                    color: effectiveTextColor.withValues(alpha: 0.7),
                  ),
                ),
                width(5),
                const MyCircularIndicator(size: 10),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    TextTheme textTheme,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: textTheme.bodyMedium?.copyWith(
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
