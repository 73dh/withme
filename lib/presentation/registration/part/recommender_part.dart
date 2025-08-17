import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                Text(
                  '소개자',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (!isReadOnly)
                  Text(
                    ' (선택)',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                const Spacer(),
                Switch.adaptive(
                  value: isRecommended,
                  activeColor: colorScheme.primary, // theme 기반 색상
                  onChanged: isReadOnly ? null : onChanged,
                ),
              ],
            ),

            /// 추천 여부가 true일 때 이름 출력 or 입력
            if (isRecommended)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: isReadOnly
                    ? Text(
                  recommendedController.text,
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                )
                    : CustomTextFormField(
                  controller: recommendedController,
                  hintText: '소개자 이름 입력',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant, // 힌트 색상
                  ),
                  onSaved: (text) =>
                  recommendedController.text = text.trim(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

//
// class RecommenderPart extends StatelessWidget {
//   final bool isReadOnly;
//   final bool isRecommended;
//   final TextEditingController recommendedController;
//   final void Function(bool) onChanged;
//
//   const RecommenderPart({
//     super.key,
//     required this.isReadOnly,
//     required this.isRecommended,
//     required this.onChanged,
//     required this.recommendedController,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // 높이 조건: 추천자 입력 여부에 따라 조절
//     final double height = isRecommended ? 150 : 90;
//
//     return ItemContainer(
//       height: height,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             /// 상단 소개자 텍스트 + 스위치
//             Row(
//               children: [
//                  Text('소개자', style: Theme.of(context).textTheme.headlineMedium),
//                 if (!isReadOnly)
//                    Text(' (선택)', style: Theme.of(context).textTheme.bodyMedium),
//                 const Spacer(),
//                 Switch.adaptive(
//                   value: isRecommended,
//                   activeColor: ColorStyles.activeSwitchColor,
//                   onChanged: isReadOnly ? null : onChanged,
//                 ),
//               ],
//             ),
//
//             /// 추천 여부가 true일 때 이름 출력 or 입력
//             if (isRecommended)
//               Padding(
//                 padding: const EdgeInsets.only(top: 6),
//                 child:
//                     isReadOnly
//                         ? Text(
//                           recommendedController.text,
//                           style: Theme.of(context).textTheme.headlineMedium,
//                         )
//                         : CustomTextFormField(
//                           controller: recommendedController,
//                           hintText: '소개자 이름 입력',
//                           onSaved:
//                               (text) =>
//                                   recommendedController.text = text.trim(),
//                         ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
