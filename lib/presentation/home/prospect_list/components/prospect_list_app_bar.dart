import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';

import '../../../../core/presentation/components/animation_pregress_bar.dart';
import '../../../../core/presentation/components/blinking_toggle_icon.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';

class ProspectListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ProspectListViewModel viewModel;
  final List<CustomerModel> customers;
  final bool filterBarExpanded;
  final VoidCallback onToggleFilterBar;
  final Color backgroundColor; // ← 추가

  const ProspectListAppBar({
    super.key,
    required this.viewModel,
    required this.customers,
    required this.filterBarExpanded,
    required this.onToggleFilterBar,
    required this.backgroundColor, // ← 추가
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      backgroundColor: backgroundColor,
      // Scaffold와 동일하게
      surfaceTintColor: Colors.transparent,
      // 오버레이 제거
      elevation: 2,
      title: Row(
        children: [
          width(5),
          _buildGenderIcons(colorScheme),
          width(4),
          Text(
            '${customers.length}명',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface, // 강조색

            ),
          ),
          width(5),
          BlinkingToggleIcon(
            expanded: filterBarExpanded,
            onTap: onToggleFilterBar,
          ),
          Expanded(child: _buildProgressBar(viewModel, colorScheme, textTheme)),
        ],
      ),
      actions: [
        AppBarSearchWidget(
          onSubmitted: (text) => viewModel.updateFilter(searchText: text),
        ),
      ],
    );
  }

  /// 아이콘 겹쳐진 부분 렌더링
  Widget _buildGenderIcons(ColorScheme colorScheme) {
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
            IconsPath.womanIcon,
            width: 40,
            color: colorScheme.secondary.withOpacity(0.7),
          ),
          Positioned(
            left: -13,
            top: 0,
            child: Image.asset(
              IconsPath.manIcon,
              width: 35,
              color: colorScheme.tertiary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 목표 대비 진행률 표시 바
  Widget _buildProgressBar(
    ProspectListViewModel viewModel,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final total = viewModel.totalProspectCount;
    final target = UserSession().targetProspectCount;
    final ratio = (total / target).clamp(0.0, 1.0);

    return Row(
      children: [
        AnimatedProgressBar(
          progress: ratio,
          height: 18,
          progressColor: colorScheme.primary.withValues(alpha: 0.5),
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        width(3),
        Text(
          '$target명',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

