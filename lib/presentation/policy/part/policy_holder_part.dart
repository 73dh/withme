import 'package:withme/core/ui/const/size.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';

class PolicyHolderPart extends StatelessWidget {
  final String policyHolderName;
  final String policyHolderSex;
  final DateTime? policyHolderBirth;
  final void Function(DateTime?) onBirthPressed;

  const PolicyHolderPart({
    super.key,
    required this.policyHolderName,
    required this.policyHolderSex,
    this.policyHolderBirth,
    required this.onBirthPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  policyHolderName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              width(12),

              /// 성별 라디오
              ToggleButtons(
                isSelected: [policyHolderSex == '남', policyHolderSex == '여'],

                onPressed: (sex) {},
                // 읽기 전용
                borderRadius: BorderRadius.circular(8),
                constraints: BoxConstraints(
                  minWidth: AppSizes.toggleMinWidth,
                  minHeight: 38,
                ),

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
                    policyHolderBirth?.formattedDate ?? '생년월일',
                    style: TextStyles.normal12,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    backgroundColor:
                        policyHolderBirth == null
                            ? ColorStyles.activeButtonColor
                            : ColorStyles.unActiveButtonColor,
                    foregroundColor: Colors.black87,
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
