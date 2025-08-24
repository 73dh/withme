import 'package:withme/core/ui/const/size.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';

class PolicyHolderPart extends StatelessWidget {
  final String policyHolderName;
  final String policyHolderSex;
  final DateTime? policyHolderBirth;
  final void Function(DateTime?) onBirthPressed;
  final TextStyle? textStyle; // ✅ 추가

  const PolicyHolderPart({
    super.key,
    required this.policyHolderName,
    required this.policyHolderSex,
    this.policyHolderBirth,
    required this.onBirthPressed,
    this.textStyle, // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return IntrinsicWidth(
          child: Row(
            children: [
              /// 이름 표시
              Container(
                width: 120,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  policyHolderName,
                  style:
                      textStyle ??
                      theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
              width(12),

              /// 성별 라디오 (읽기 전용)
              ToggleButtons(
                isSelected: [policyHolderSex == '남', policyHolderSex == '여'],
                onPressed: (_) {},
                borderRadius: BorderRadius.circular(8),
                constraints: BoxConstraints(
                  minWidth: AppSizes.toggleMinWidth,
                  minHeight: 38,
                ),
                selectedColor: colorScheme.primary,
                fillColor: colorScheme.primary.withValues(alpha: 0.12),
                color: colorScheme.onSurfaceVariant,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Icon(Icons.male, size: 18),
                        SizedBox(width: 2),
                        Text('남'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Icon(Icons.female, size: 18),
                        SizedBox(width: 2),
                        Text('여'),
                      ],
                    ),
                  ),
                ],
              ),
              width(12),

              /// 생년월일 버튼
              SizedBox(
                width: 130,
                child: ElevatedButton.icon(
                  onPressed: () => onBirthPressed(policyHolderBirth),
                  icon: const Icon(Icons.cake_outlined, size: 18),
                  label: Text(
                    policyHolderBirth?.formattedBirth ?? '생년월일',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          policyHolderBirth == null
                              ? colorScheme.onPrimary
                              : colorScheme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    backgroundColor:
                        policyHolderBirth == null
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                    foregroundColor:
                        policyHolderBirth == null
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
