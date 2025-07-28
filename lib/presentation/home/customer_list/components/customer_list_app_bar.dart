import '../../../../core/presentation/components/blinking_toggle_icon.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class CustomerListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;
  final ValueChanged<String> onSearch;
  final bool filterBarExpanded;
  final VoidCallback onToggleFilterBar;


  const CustomerListAppBar({
    super.key,
    required this.count,
    required this.onSearch,
    required this.filterBarExpanded,
    required this.onToggleFilterBar,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          _buildIconStack(),
          const SizedBox(width: 10),
          Text('$count명', style: TextStyles.homeTopTextStyle),
          width(5),
          BlinkingToggleIcon(
            expanded: filterBarExpanded,
            onTap: onToggleFilterBar,
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

  Widget _buildIconStack() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(IconsPath.folderIcon, width: 45, color: ColorStyles.badgeColor.withOpacity(0.5)),
          Positioned(
            left: -12,
            top: -2,
            child: Image.asset(IconsPath.folderIcon, width: 35, color: ColorStyles.badgeColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
