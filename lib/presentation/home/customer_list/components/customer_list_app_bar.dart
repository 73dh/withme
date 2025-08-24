import 'package:withme/core/di/di_setup_import.dart';

import '../../../../core/presentation/components/blinking_toggle_icon.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class CustomerListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int count;
  final ValueChanged<String> onSearch;
  final CustomerListViewModel viewModel;
  final VoidCallback onToggleFilterBar;
  final Color? backgroundColor; // 추가
  final Color? foregroundColor; // 추가

  const CustomerListAppBar({
    super.key,
    required this.count,
    required this.onSearch,
    required this.viewModel,
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

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      title: Row(
        children: [
          _buildIconStack(colorScheme),
          width(5),
          Text(
            '$count명',
            style: textTheme.titleMedium?.copyWith(color: colorScheme.primary,fontWeight: FontWeight.bold),
          ),
          width(5),
          AnimatedBuilder(
            animation: viewModel,
            builder: (BuildContext context, Widget? child) {
              return BlinkingToggleIcon(
                expanded: viewModel.isFilterBarExpanded,
                onTap: onToggleFilterBar,
              );
            },
          ),
        ],
      ),
      actions: [AppBarSearchWidget(onSubmitted: onSearch)],
    );
  }

  Widget _buildIconStack(ColorScheme colorScheme) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          IconsPath.folderIcon,
          width: 45,
          color: colorScheme.secondary.withValues(alpha: 0.7),
        ),
        Positioned(
          left: -12,
          top: -2,
          child: Image.asset(
            IconsPath.folderIcon,
            width: 35,
            color: colorScheme.tertiary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
