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
    return PartBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildNameField(),
                const Spacer(),
                _buildSexSelector(),
              ],
            ),
            height(10),
            _buildBirthSelector(context),
            height(10),
            _buildRegisteredDateSelector(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() =>
      NameField(isReadOnly: isReadOnly, nameController: nameController);

  Widget _buildSexSelector() => SexSelector(
    sex: sex,
    isReadOnly: isReadOnly,
    onChanged: isReadOnly ? null : (sex) => onSexChanged(sex!),
  );

  Widget _buildBirthSelector(BuildContext context) => BirthSelector(
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
  );

  Widget _buildRegisteredDateSelector(BuildContext context) => RegisteredDateSelector(
    isReadOnly: isReadOnly,
    registeredDate: DateFormat(
      'yy/MM/dd',
    ).parseStrict(registeredDateController.text),
    onPressed:isReadOnly?null:()async {
      final date = await selectDate(context);
      if (date != null) {
        onRegisteredDatePressed(date);
      }
    }
  );
}
