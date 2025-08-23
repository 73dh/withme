import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/presentation/fab/animated_fab_container.dart';
import 'package:withme/core/presentation/fab/main_fab.dart';
import 'package:withme/core/presentation/fab/small_fab.dart';
import 'package:withme/core/ui/const/fab_position.dart';

import 'fab_view_model_interface.dart';

mixin FabOverlayManagerMixin<
  T extends StatefulWidget,
  VM extends FabViewModelInterface
>
    on State<T>
    implements RouteAware {
  OverlayEntry? _fabOverlayEntry;
  bool _fabExpanded = false;
  bool _fabVisibleInOverlay = false;
  bool _fabOverlayIsInserted = false;
  bool _fabCanBeShown = false;
  bool _isProcessActive = false;
  bool _isRouteTransitioning = false;
  bool _isBottomSheetOpen = false; // BottomSheet + Dialog 공용

  void Function(void Function())? _overlaySetState;
  double smallFabBottomPosition = FabPosition.topFabBottomHeight;

  VM get viewModel;

  void onSortActionLogic(Function() sortFn);

  Future<void> onMainFabPressedLogic(VM viewModel);

  bool get canShowFabOverlay =>
      _fabCanBeShown &&
      !_isProcessActive &&
      !_isRouteTransitioning &&
      !_isBottomSheetOpen &&
      mounted;

  void setOverlaySetState(void Function(void Function())? setter) =>
      _overlaySetState = setter;

  void callOverlaySetState() => _overlaySetState?.call(() {});

  void clearOverlaySetState() => _overlaySetState = null;

  void setIsProcessActive(bool active) {
    _isProcessActive = active;
    _updateFabOverlayVisibility();
  }

  void setFabCanBeShown(bool canShow) {
    if (_fabCanBeShown == canShow) return;
    _fabCanBeShown = canShow;
    _updateFabOverlayVisibility();
  }

  void setIsModalOpen(bool open) {
    _isBottomSheetOpen = open;
    _updateFabOverlayVisibility();
  }

  @protected
  Widget buildMainFab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MainFab(
      fabVisibleLocal: _fabVisibleInOverlay,
      backgroundColor: colorScheme.primary, // MainFab 배경
      foregroundColor: colorScheme.onPrimary, // 아이콘 색상
      onPressed: () async => await onMainFabPressedLogic(viewModel),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setFabCanBeShown(true);
    });
  }

  @override
  void dispose() {
    _removeFabOverlay();
    super.dispose();
  }

  @override
  void didPushNext() {
    _isRouteTransitioning = true;
    _removeFabOverlay();
  }

  @override
  void didPopNext() {
    _isRouteTransitioning = false;
    _fabCanBeShown = true;
    _updateFabOverlayVisibility();
    viewModel.fetchData(force: true);
  }

  void handleVisibilityChange(VisibilityInfo info) {
    if (_isProcessActive || _isRouteTransitioning) return;
    if (info.visibleFraction < 0.4 || _isBottomSheetOpen) {
      setFabCanBeShown(false);
    } else {
      setFabCanBeShown(true);
    }
  }

  void _updateFabOverlayVisibility() {
    if (canShowFabOverlay) {
      _insertFabOverlayIfAllowed();
    } else {
      _removeFabOverlay();
    }
  }

  void _insertFabOverlayIfAllowed() {
    final colorScheme = Theme.of(context).colorScheme;
    if (!canShowFabOverlay || _fabOverlayIsInserted) return;

    _removeFabOverlay();
    _fabExpanded = false;
    _fabVisibleInOverlay = false;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!canShowFabOverlay) return;
      final overlay = Navigator.of(context).overlay;
      if (overlay == null) return;

      OverlayEntry? localEntry;
      localEntry = OverlayEntry(
        builder: (overlayContext) {
          _overlaySetState = null;
          return StatefulBuilder(
            builder: (innerContext, setState) {
              _overlaySetState = (fn) {
                if (!mounted || localEntry != _fabOverlayEntry) return;
                setState(fn);
              };

              return Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_fabVisibleInOverlay,
                  child: Stack(
                    children: [
                      // SmallFab 내부 색상 적용 (AnimatedFabContainer 포함)
                      if (viewModel.hasSmallFab)
                        AnimatedFabContainer(
                          fabVisibleLocal: _fabVisibleInOverlay,
                          rightPosition: 16,
                          bottomPosition:
                              viewModel.hasMainFab
                                  ? FabPosition.topFabBottomHeight
                                  : FabPosition.bottomFabBottomHeight,
                          child: SmallFab(
                            fabExpanded: _fabExpanded,
                            fabVisibleLocal: _fabVisibleInOverlay,
                            overlaySetState: (_) => _toggleFabExpanded(),
                            onSortByName:
                                () => onSortActionLogic(viewModel.sortByName),
                            onSortByBirth:
                                () => onSortActionLogic(viewModel.sortByBirth),
                            onSortByInsuredDate:
                                () => onSortActionLogic(
                                  viewModel.sortByInsuranceAgeDate,
                                ),
                            onSortByManage:
                                () => onSortActionLogic(
                                  viewModel.sortByHistoryCount,
                                ),
                            selectedSortStatus: viewModel.sortStatus,
                            fabBackgroundColor: colorScheme.surface,
                            // SmallFab 기본 배경
                            fabForegroundColor: colorScheme.onSurface,
                            // SmallFab 아이콘 색
                            expandedBackgroundColor:
                                colorScheme.primaryContainer, // 확장 시 배경색
                          ),
                        ),
                      // ✅ MainFab 위치 (조건적으로 배치)
                      if (viewModel.hasMainFab)
                        AnimatedFabContainer(
                          fabVisibleLocal: _fabVisibleInOverlay,
                          rightPosition: 16,
                          bottomPosition: FabPosition.bottomFabBottomHeight,
                          child: buildMainFab(),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      _fabOverlayEntry = localEntry;
      overlay.insert(_fabOverlayEntry!);
      _fabOverlayIsInserted = true;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (canShowFabOverlay && _fabOverlayEntry == localEntry) {
          _overlaySetState?.call(() {
            _fabVisibleInOverlay = true;
            _fabExpanded = false;
          });
        }
      });
    });
  }

  void _removeFabOverlay() {
    if (_fabOverlayEntry != null) {
      _fabOverlayEntry!.remove();
      _fabOverlayEntry = null;
      _fabOverlayIsInserted = false;
      _fabExpanded = false;
      _fabVisibleInOverlay = false;
      _overlaySetState = null;
    }
  }

  void _toggleFabExpanded() {
    _overlaySetState?.call(() {
      _fabExpanded = !_fabExpanded;
    });
  }
}
