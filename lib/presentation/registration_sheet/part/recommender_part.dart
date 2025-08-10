import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';

class RecommenderPart extends StatelessWidget {
  final bool isReadOnly;
  final bool isRecommended;
  final TextEditingController recommendedController;
  final void Function(bool) onChanged;

  const RecommenderPart({
    super.key,
    required this.isReadOnly,
    required this.isRecommended,
    required this.onChanged,
    required this.recommendedController,
  });

  @override
  Widget build(BuildContext context) {
    // 높이 조건: 추천자 입력 여부에 따라 조절
    final double height = isRecommended ? 150 : 90;

    return ItemContainer(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 상단 소개자 텍스트 + 스위치
            Row(
              children: [
                const Text('소개자', style: TextStyles.normal14),
                if (!isReadOnly)
                  const Text(' (선택)', style: TextStyles.normal14),
                const Spacer(),
                Switch.adaptive(
                  value: isRecommended,
                  activeColor: ColorStyles.activeSwitchColor,
                  onChanged: isReadOnly ? null : onChanged,
                ),
              ],
            ),

            /// 추천 여부가 true일 때 이름 출력 or 입력
            if (isRecommended)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child:
                    isReadOnly
                        ? Text(
                          recommendedController.text,
                          style: TextStyles.bold14,
                        )
                        : CustomTextFormField(
                          controller: recommendedController,
                          hintText: '소개자 이름 입력',
                          onSaved:
                              (text) =>
                                  recommendedController.text = text.trim(),
                        ),
              ),
          ],
        ),
      ),
    );
  }
}
