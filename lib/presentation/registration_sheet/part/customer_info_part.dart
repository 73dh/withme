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
  final String? sex;
  final DateTime? birth;
  final void Function(String) onSexChanged;
  final void Function() onBirthInitPressed;
  final void Function(DateTime) onBirthSetPressed;
  final void Function(DateTime) onRegisteredDatePressed;

  // 🔽 소개자 관련 필드 추가
  final bool isRecommended;
  final TextEditingController recommendedController;
  final void Function(bool) onRecommendedChanged;

  const CustomerInfoPart({
    super.key,
    required this.isReadOnly,
    required this.nameController,
    required this.registeredDateController,
    required this.sex,
    this.birth,
    required this.onSexChanged,
    required this.birthController,
    required this.onBirthInitPressed,
    required this.onBirthSetPressed,
    required this.onRegisteredDatePressed,

    required this.isRecommended,
    required this.recommendedController,
    required this.onRecommendedChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Adjusted height as the recommended field is now inline
    return ItemContainer(
      height: 310, // Fixed height for a more consistent layout
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 이름 & 성별
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: NameField(
                    isReadOnly: isReadOnly,
                    nameController: nameController,
                  ),
                ),
                // width(10), // You had this commented out, keeping it that way
                SexSelector(
                  sex: sex,
                  isReadOnly: isReadOnly,
                  onChanged: isReadOnly ? null : (sex) => onSexChanged(sex),
                ),
              ],
            ),
            height(12),

            /// 생년월일 선택
            BirthSelector(
              birth: birth,
              isReadOnly: isReadOnly,
              onInitPressed: isReadOnly ? null : onBirthInitPressed,
              onSetPressed:
                  isReadOnly
                      ? null
                      : () async {
                        final date = await selectDate(
                          context,
                        ); // Assuming selectDate is available
                        if (date != null) {
                          onBirthSetPressed(date);
                        }
                      },
            ),
            height(12),

            /// 등록일 선택
            RegisteredDateSelector(
              isReadOnly: isReadOnly,
              registeredDate: DateFormat(
                'yy/MM/dd',
              ).parseStrict(registeredDateController.text),
              onPressed:
                  isReadOnly
                      ? null
                      : () async {
                        final date = await selectDate(
                          context,
                        ); // Assuming selectDate is available
                        if (date != null) {
                          onRegisteredDatePressed(date);
                        }
                      },
            ),
            height(12), // Add some spacing before the new row
            /// 소개 여부 & 소개자 이름 (New Layout)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Distribute space
              children: [
                const Text('소개 여부'),
                Switch(
                  value: isRecommended,
                  onChanged: isReadOnly ? null : onRecommendedChanged,
                ),
                // Spacer pushes the next widget to the right
                // If you want a fixed space, use width() instead of Spacer()
                const Spacer(),
                if (isRecommended) // Conditionally show the TextFormField
                  Expanded(
                    // Allow TextFormField to take available horizontal space
                    child: TextFormField(
                      controller: recommendedController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,

                        errorText:
                            isRecommended &&
                                    (recommendedController.text.trim().isEmpty)
                                ? '소개자 이름을 입력하세요'
                                : null,
                        errorStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                        // Style the error text
                        isDense: true,
                        // Make the input field more compact
                        contentPadding:
                            EdgeInsets
                                .zero, // Reduce internal padding if needed
                      ),
                      enabled: !isReadOnly,
                      onChanged: (value) {},
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
