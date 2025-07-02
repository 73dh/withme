import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../core/domain/sort_status.dart';

class SmallFab extends StatefulWidget {
  final bool fabVisibleLocal;
  final bool fabExpanded;
  final void Function(void Function())? overlaySetState;
  final void Function(void Function())? overlaySetStateFold;
  final void Function()? onSortByName;
  final void Function()? onSortByBirth;
  final void Function()? onSortByInsuredDate;
  final void Function()? onSortByManage;
  final SortStatus? selectedSortStatus; // 정렬 상태 및 방향 정보

  const SmallFab({
    super.key,
    required this.fabVisibleLocal,
    required this.fabExpanded,
    this.overlaySetState,
    this.overlaySetStateFold,
    this.onSortByName,
    this.onSortByBirth,
    this.onSortByInsuredDate,
    this.onSortByManage,
    this.selectedSortStatus,
  });

  @override
  State<SmallFab> createState() => _SmallFabState();
}

class _SmallFabState extends State<SmallFab> with TickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  late final AnimationController _visibilityController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Expansion animation (fabExpanded)
    _expandController = AnimationController(
      vsync: this,
      duration: AppDurations.duration300,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    // Visibility animation (fabVisibleLocal)
    _visibilityController = AnimationController(
      vsync: this,
      duration: AppDurations.duration100,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeInOut,
    );

    if (widget.fabVisibleLocal) {
      _visibilityController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SmallFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate expand/collapse
    widget.fabExpanded
        ? _expandController.forward()
        : _expandController.reverse();

    // Animate show/hide
    if (widget.fabVisibleLocal) {
      _visibilityController.forward();
    } else {
      _visibilityController.reverse();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_expandAnimation),
                  child: _buildSortActions(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (!widget.fabExpanded)
              FloatingActionButton.small(
                key: const ValueKey('smallFab'),
                heroTag: 'smallFab',
                backgroundColor: ColorStyles.fabColor,
                onPressed: () => widget.overlaySetState?.call(() {}),
                child: const Icon(Icons.sort_outlined, color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortActions() {
    final status = widget.selectedSortStatus;
    final actions = <Map<String, dynamic>>[];

    if (widget.onSortByName != null) {
      actions.add({
        'label': '이름순',
        'onTap': widget.onSortByName,
        'type': SortType.name,
      });
    }
    if (widget.onSortByBirth != null) {
      actions.add({
        'label': '생일순',
        'onTap': widget.onSortByBirth,
        'type': SortType.birth,
      });
    }
    if (widget.onSortByInsuredDate != null) {
      actions.add({
        'label': '상령일순',
        'onTap': widget.onSortByInsuredDate,
        'type': SortType.insuredDate,
      });
    }
    if (widget.onSortByManage != null) {
      actions.add({
        'label': '관리순',
        'onTap': widget.onSortByManage,
        'type': SortType.manage,
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var action in actions)
          GestureDetector(
            onTap: action['onTap'] as void Function()?,
            child: _buildMiniAction(
              action['label'] as String,
              isSelected: status?.type == action['type'],
              isAscending:
                  status?.type == action['type'] ? status?.isAscending : null,
            ),
          ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'fabClose',
          backgroundColor: ColorStyles.fabColor,
          onPressed: () => widget.overlaySetStateFold?.call(() {}),
          child: const Icon(Icons.close, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildMiniAction(
    String label, {
    required bool isSelected,
    bool? isAscending,
  }) {
    IconData? icon;
    if (isSelected && isAscending != null) {
      icon = isAscending ? Icons.arrow_downward : Icons.arrow_upward;
    }

    return Container(
      width: 90,
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? ColorStyles.selectedFabColor : ColorStyles.fabColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black87 : Colors.black38,
              fontSize: 13,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: Colors.black54),
          ],
        ],
      ),
    );
  }
}
