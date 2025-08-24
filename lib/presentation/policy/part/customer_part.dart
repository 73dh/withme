import 'package:withme/presentation/policy/part/insured_holder_part.dart';
import 'package:withme/presentation/policy/part/policy_holder_part.dart';

import '../../../core/presentation/core_presentation_import.dart';

class CustomerPart extends StatelessWidget {
  final String policyHolderName;
  final String policyHolderSex;
  final DateTime? policyHolderBirth;
  final TextEditingController insuredNameController;
  final String insuredSex;
  final DateTime? insuredBirth;
  final void Function(DateTime?) onBirthPressed;
  final void Function(String) onManChanged;
  final void Function(String) onWomanChanged;
  final void Function(DateTime?) onBirthChanged;

  const CustomerPart({
    super.key,
    required this.policyHolderName,
    required this.policyHolderSex,
    this.policyHolderBirth,
    required this.onBirthPressed,
    required this.insuredNameController,
    required this.insuredSex,
    required this.onManChanged,
    required this.onWomanChanged,
    required this.onBirthChanged,
    this.insuredBirth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ItemContainer(
      height: 130,
      backgroundColor: colorScheme.surfaceContainerHighest, // 테마 기반 배경색
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PolicyHolderPart(
            policyHolderName: policyHolderName,
            policyHolderSex: policyHolderSex,
            policyHolderBirth: policyHolderBirth,
            onBirthPressed: (value) => onBirthPressed(value),
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          height(5),
          InsuredHolderPart(
            insuredNameController: insuredNameController,
            insuredSex: insuredSex,
            insuredBirth: insuredBirth,
            onManChanged: (value) => onManChanged(value),
            onWomanChanged: (value) => onWomanChanged(value),
            onBirthChanged: (value) => onBirthChanged(value),
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
