import 'package:flutter/material.dart';
import '../../../core/ui/const/size.dart';
import 'package:flutter/material.dart';
import '../../../core/ui/const/size.dart';
import '../../../core/ui/core_ui_import.dart';

class SexSelector extends StatelessWidget {
  final String? sex;
  final bool isReadOnly;
  final void Function(String)? onChanged;

  const SexSelector({
    super.key,
    required this.sex,
    required this.isReadOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildToggle(
          label: '남',
          icon: Icons.male,
          isSelected: sex == '남',
          onTap: () => onChanged?.call('남'),
        ),
        const SizedBox(width: 8),
        _buildToggle(
          label: '여',
          icon: Icons.female,
          isSelected: sex == '여',
          onTap: () => onChanged?.call('여'),
        ),
      ],
    );
  }

  Widget _buildToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final backgroundColor = isReadOnly
        ? (isSelected ? Colors.grey.shade300 : Colors.white)
        : (isSelected ? ColorStyles.unActiveButtonColor : Colors.white);

    final textColor = isReadOnly
        ? Colors.grey
        : (isSelected ? Colors.black87 : Colors.black45);

    return GestureDetector(
      onTap: isReadOnly ? null : onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: AppSizes.toggleMinWidth,
          minHeight: 38,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            Text(' $label', style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}
