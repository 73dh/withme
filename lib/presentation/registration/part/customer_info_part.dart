import 'package:intl/intl.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../components/birth_selector.dart';
import '../components/name_field.dart';
import '../components/registered_date_selector.dart';
import '../components/sex_selector.dart';

class CustomerInfoPart extends StatelessWidget {
  final bool isReadOnly;
  final TextEditingController nameController;
  final TextEditingController registeredDateController;
  final TextEditingController birthController;
  final TextEditingController memoController;
  final String? sex;
  final DateTime? birth;
  final void Function(String) onSexChanged;
  final void Function() onBirthInitPressed;
  final void Function(DateTime) onBirthSetPressed;
  final void Function(DateTime) onRegisteredDatePressed;

  final bool isRecommended;
  final TextEditingController recommendedController;
  final void Function(bool) onRecommendedChanged;

  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;

  const CustomerInfoPart({
    super.key,
    required this.isReadOnly,
    required this.nameController,
    required this.registeredDateController,
    required this.birthController,
    required this.memoController,
    required this.sex,
    required this.birth,
    required this.onSexChanged,
    required this.onBirthInitPressed,
    required this.onBirthSetPressed,
    required this.onRegisteredDatePressed,
    required this.isRecommended,
    required this.recommendedController,
    required this.onRecommendedChanged,
    this.backgroundColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveTitleStyle =
        titleTextStyle ??
        textTheme.titleMedium?.copyWith(color: colorScheme.onSurface);
    final effectiveSubtitleStyle =
        subtitleTextStyle ??
        textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withAlpha(180),
        );

    return ItemContainer(
      height: 352,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 + 성별
            Row(
              children: [
                Expanded(
                  child: NameField(
                    isReadOnly: isReadOnly,
                    nameController: nameController,
                    textStyle: effectiveTitleStyle,
                  ),
                ),
                width(20),
                SexSelector(
                  sex: sex,
                  isReadOnly: isReadOnly,
                  onChanged: isReadOnly ? null : (val) => onSexChanged(val),
                ),
              ],
            ),
            height(8),
            // 생년월일
            BirthSelector(
              birth: birth,
              isReadOnly: isReadOnly,
              onInitPressed: isReadOnly ? null : onBirthInitPressed,
              onSetPressed: isReadOnly ? null : onBirthSetPressed,
              textStyle: effectiveSubtitleStyle,
            ),
            height(8),
            // 등록일
            RegisteredDateSelector(
              isReadOnly: isReadOnly,
              registeredDate: DateFormat(
                'yy/MM/dd',
              ).parseStrict(registeredDateController.text),
              onPressed:
                  isReadOnly
                      ? null
                      : () async {
                        final selectedDate = await selectDate(context);
                        if (selectedDate != null) {
                          onRegisteredDatePressed(selectedDate);
                        }
                      },
            ),
            height(8),
            // 메모
            TextFormField(
              controller: memoController,
              enabled: !isReadOnly,
              style: effectiveSubtitleStyle,
              decoration: InputDecoration(
                labelText: '메모', // ← 라벨 제목 추가
                filled: true,
                fillColor:
                    isReadOnly
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color:isReadOnly
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.surface,),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // ✅ radius 유지
                  borderSide: BorderSide.none,            // ✅ 테두리 선 제거
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
              ),
            ),
            height(8),
            // 소개 여부 + 소개자
            Row(
              children: [
                Text('소개 여부', style: effectiveTitleStyle),
                width(8),
                Switch(
                  value: isRecommended,
                  onChanged: isReadOnly ? null : onRecommendedChanged,
                  activeColor: colorScheme.primary,
                ),
                width(20),
                if (isRecommended)
                  Expanded(
                    child: TextFormField(
                      controller: recommendedController,
                      enabled: !isReadOnly,
                      style: effectiveSubtitleStyle,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            isReadOnly
                                ? colorScheme.surfaceContainerHighest
                                : colorScheme.surface,
                        hintText: '홍길동',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant, // 회색 계열
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),

                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // ✅ radius 유지
                          borderSide: BorderSide.none,            // ✅ 테두리 선 제거
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
