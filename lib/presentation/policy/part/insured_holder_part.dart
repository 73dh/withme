import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';

class InsuredHolderPart extends StatelessWidget {
  final TextEditingController insuredNameController;
  final String? insuredSex;
  final DateTime? insuredBirth;
  final void Function(String) onInsuredNameChanged;
  final void Function(String) onManChanged;
  final void Function(String) onWomanChanged;
  final void Function(DateTime?) onBirthChanged;

  const InsuredHolderPart({
    super.key,
    required this.insuredNameController,
    required this.insuredSex,
    this.insuredBirth,
    required this.onInsuredNameChanged,
    required this.onManChanged,
    required this.onWomanChanged,
    required this.onBirthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.25,
              child: CustomTextFormField(
                controller: insuredNameController,
                hintText: '피보험자',
                autoFocus: true,
                textAlign: TextAlign.center,
                validator: (value) => value.isEmpty ? '이름 입력' : null,
                onChanged: (value) => onInsuredNameChanged(value),
                onSaved: (value) => insuredNameController.text = value,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioMenuButton<String>(
                  value: '남',
                  groupValue: insuredSex,
                  onChanged: (insuredSex)=> onManChanged(insuredSex!),
                  child: const Text('남'),
                ),
                RadioMenuButton<String>(
                  value: '여',
                  groupValue: insuredSex,
                  onChanged: (insuredSex) => onWomanChanged(insuredSex!),
                  child: const Text('여'),
                ),
              ],
            ),
            SizedBox(
              width: 130,
              child: RenderFilledButton(
                borderRadius: 10,
                backgroundColor:
                    insuredBirth != null
                        ? ColorStyles.unActiveButtonColor
                        : ColorStyles.activeButtonColor,
                foregroundColor:
                    Colors.black87 ,
                onPressed: () => onBirthChanged(insuredBirth),
                text: insuredBirth?.formattedDate ?? '생년월일',
              ),
            ),
          ],
        );
      },
    );
  }
}
