import 'package:flutter/material.dart'; // 필수 import 확인

import '../../const/duration.dart';
import '../../domain/enum/sort_status.dart';
import '../../domain/enum/sort_type.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class SmallFab extends StatefulWidget {
  final bool fabVisibleLocal;
  final bool fabExpanded;
  final void Function(void Function())? overlaySetState;
  final void Function()? onSortByName;
  final void Function()? onSortByBirth;
  final void Function()? onSortByInsuredDate;
  final void Function()? onSortByManage;
  final SortStatus? selectedSortStatus;

  // Theme 관련 옵션
  final Color? fabBackgroundColor;
  final Color? fabForegroundColor;
  final Color? expandedBackgroundColor;

  const SmallFab({
    super.key,
    required this.fabVisibleLocal,
    required this.fabExpanded,
    this.overlaySetState,
    this.onSortByName,
    this.onSortByBirth,
    this.onSortByInsuredDate,
    this.onSortByManage,
    this.selectedSortStatus,
    this.fabBackgroundColor,
    this.fabForegroundColor,
    this.expandedBackgroundColor,
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

    _expandController = AnimationController(
      vsync: this,
      duration: AppDurations.duration300,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

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

    if (widget.fabVisibleLocal) _visibilityController.forward();
    if (widget.fabExpanded) _expandController.forward();
  }

  @override
  void didUpdateWidget(covariant SmallFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.fabExpanded != oldWidget.fabExpanded) {
      widget.fabExpanded
          ? _expandController.forward()
          : _expandController.reverse();
    }

    if (widget.fabVisibleLocal != oldWidget.fabVisibleLocal) {
      widget.fabVisibleLocal
          ? _visibilityController.forward()
          : _visibilityController.reverse();
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final fabBgColor =
        widget.fabExpanded
            ? widget.expandedBackgroundColor ?? colorScheme.primaryContainer
            : widget.fabBackgroundColor ?? colorScheme.surface;
    final fabFgColor = widget.fabForegroundColor ?? colorScheme.onSurface;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 정렬 옵션 그룹
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_expandAnimation),
                  child: _buildSortActions(colorScheme, textTheme),
                ),
              ),
            ),
            if (widget.fabExpanded) height(4),
            // 메인 FAB 버튼
            FloatingActionButton.small(
              key: const ValueKey('mainSmallFab'),
              heroTag: 'mainSmallFab',
              backgroundColor: fabBgColor,
              foregroundColor: fabFgColor,
              onPressed: () => widget.overlaySetState?.call(() {}),
              child: AnimatedSwitcher(
                duration: AppDurations.duration300,
                transitionBuilder:
                    (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                child: Icon(
                  widget.fabExpanded
                      ? Icons.close
                      : Icons.sort_by_alpha_outlined,
                  key: ValueKey(widget.fabExpanded),
                  color: fabFgColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortActions(ColorScheme colorScheme, TextTheme textTheme) {
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
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
      ],
    );
  }

  Widget _buildMiniAction(
    String label, {
    required bool isSelected,
    bool? isAscending,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
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
        color:
            isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color:
                  isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          if (icon != null) ...[
          width(4),
            Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}
