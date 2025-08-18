import 'package:withme/core/ui/const/size.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';

class InsuredHolderPart extends StatelessWidget {
  final TextEditingController insuredNameController;
  final String? insuredSex;
  final DateTime? insuredBirth;

  final void Function(String) onManChanged;
  final void Function(String) onWomanChanged;
  final void Function(DateTime?) onBirthChanged;
  final TextStyle? textStyle; // ✅ 추가

  const InsuredHolderPart({
    super.key,
    required this.insuredNameController,
    required this.insuredSex,
    this.insuredBirth,
    required this.onManChanged,
    required this.onWomanChanged,
    required this.onBirthChanged,
    this.textStyle, // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 이름 입력
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: insuredNameController,
                    textAlign: TextAlign.center,
                    style:
                        textStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                    decoration: InputDecoration(
                      hintText: '피보험자',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    // onChanged: onInsuredNameChanged,
                  ),
                ),
                width(12),

                /// 성별 선택
                ToggleButtons(
                  isSelected: [insuredSex == '남', insuredSex == '여'],
                  constraints: BoxConstraints(
                    minWidth: AppSizes.toggleMinWidth,
                    minHeight: 38,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  onPressed: (index) {
                    if (index == 0) {
                      onManChanged('남');
                    } else {
                      onWomanChanged('여');
                    }
                  },
                  selectedColor: colorScheme.primary,
                  fillColor: colorScheme.primary.withValues(alpha: 0.12),
                  color: colorScheme.onSurfaceVariant,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [Icon(Icons.male, size: 18), Text(' 남')],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [Icon(Icons.female, size: 18), Text(' 여')],
                      ),
                    ),
                  ],
                ),
                width(12),

                /// 생년월일 버튼
                SizedBox(
                  width: 130,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      backgroundColor:
                          insuredBirth != null
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.primary,
                      foregroundColor:
                          insuredBirth != null
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => onBirthChanged(insuredBirth),
                    icon: const Icon(Icons.cake_outlined, size: 18),
                    label: Text(
                      insuredBirth?.formattedBirth ?? '생년월일',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            insuredBirth != null
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
