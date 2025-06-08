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
    this.policyHolderBirth, required this.onBirthPressed,
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
              child: Text(policyHolderName, textAlign: TextAlign.center),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioMenuButton<String>(
                  value: '남',
                  groupValue: policyHolderSex,
                  onChanged: null,
                  child: const Text('남'),
                ),
                RadioMenuButton<String>(
                  value: '여',
                  groupValue: policyHolderSex,
                  onChanged: null,
                  child: const Text('여'),
                ),
              ],
            ),
            SizedBox(
              width: 130,
              child: RenderFilledButton(
                borderRadius: 10,
                backgroundColor:
                    policyHolderBirth == null
                        ? ColorStyles.activeButtonColor
                        : ColorStyles.unActiveButtonColor,
                foregroundColor:
                    Colors.black87 ,
                onPressed:()=>onBirthPressed(policyHolderBirth),
                text: policyHolderBirth?.formattedDate ?? '생년월일',
              ),
            ),
          ],
        );
      },
    );
  }
}
