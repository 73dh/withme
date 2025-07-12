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
  });

  @override
  Widget build(BuildContext context) {
    return ItemContainer(
      height: 258,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                // width(10),
                SexSelector(
                  sex: sex,
                  isReadOnly: isReadOnly,
                  onChanged:
                      isReadOnly ? null : (sex) => onSexChanged(sex),
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
                        final date = await selectDate(context);
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
                        final date = await selectDate(context);
                        if (date != null) {
                          onRegisteredDatePressed(date);
                        }
                      },
            ),
          ],
        ),
      ),
    );
  }
}
