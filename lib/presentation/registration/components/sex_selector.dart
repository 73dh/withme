import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/width_height.dart';

import '../../../core/ui/const/size.dart';

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
          context,
          label: '남',
          icon: Icons.male,
          isSelected: sex == '남',
          onTap: () => onChanged?.call('남'),
        ),
    width(8),
        _buildToggle(
          context,
          label: '여',
          icon: Icons.female,
          isSelected: sex == '여',
          onTap: () => onChanged?.call('여'),
        ),
      ],
    );
  }

  Widget _buildToggle(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final backgroundColor =
        isReadOnly
            ? (isSelected
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface)
            : (isSelected ? colorScheme.primaryContainer : colorScheme.surface);

    final borderColor =
        isSelected ? colorScheme.primary : colorScheme.outlineVariant;

    final textColor =
        isReadOnly
            ? colorScheme.onSurfaceVariant
            : (isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant);

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
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: textColor),
          width(4),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
