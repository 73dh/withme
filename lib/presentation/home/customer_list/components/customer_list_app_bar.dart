import '../../../../core/presentation/components/blinking_toggle_icon.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../core/presentation/components/blinking_toggle_icon.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class CustomerListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;
  final ValueChanged<String> onSearch;
  final bool filterBarExpanded;
  final VoidCallback onToggleFilterBar;
  final Color? backgroundColor; // 추가
  final Color? foregroundColor; // 추가

  const CustomerListAppBar({
    super.key,
    required this.count,
    required this.onSearch,
    required this.filterBarExpanded,
    required this.onToggleFilterBar,
    this.backgroundColor, // 추가
    this.foregroundColor, // 추가
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bgColor = backgroundColor ?? colorScheme.surface;
    final fgColor = foregroundColor ?? colorScheme.onSurface;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      title: Row(
        children: [
          _buildIconStack(colorScheme, fgColor),
          const SizedBox(width: 10),
          Text(
            '$count명',
            style: textTheme.titleMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          width(5),
          BlinkingToggleIcon(
            expanded: filterBarExpanded,
            onTap: onToggleFilterBar,
            color: fgColor,
          ),
        ],
      ),
      actions: [
        AppBarSearchWidget(
          onSubmitted: onSearch,
        ),
      ],
    );
  }

  Widget _buildIconStack(ColorScheme colorScheme, Color fgColor) {
    final badgeColor = colorScheme.secondaryContainer.withOpacity(0.5);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            offset: const Offset(0, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            IconsPath.folderIcon,
            width: 45,
            color: badgeColor,
          ),
          Positioned(
            left: -12,
            top: -2,
            child: Image.asset(
              IconsPath.folderIcon,
              width: 35,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
