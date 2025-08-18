import '../../../../core/presentation/core_presentation_import.dart';

class BuildMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool? isActivated;

  const BuildMenuItem({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.isActivated = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveColor =
        isActivated == true
            ? colorScheme
                .onSurface // 활성 상태 색상
            : colorScheme.onSurface.withValues(alpha: 0.4); // 비활성 상태 색상

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: effectiveColor),
          width(5),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(color: effectiveColor),
            ),
          ),
        ],
      ),
    );
  }
}
