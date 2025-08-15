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
  bool _isBottomSheetOpen = false;

  void Function(void Function())? _overlaySetState;
  double smallFabBottomPosition = FabPosition.topFabBottomHeight;

  /// ViewModel을 State 클래스에서 주입
  VM get viewModel;

  /// 정렬 로직
  void onSortActionLogic(Function() sortFn);

  /// FAB 메인 버튼 클릭 시 로직
  Future<void> onMainFabPressedLogic(VM viewModel);

  bool get canShowFabOverlay =>
      _fabCanBeShown &&
      !_isProcessActive &&
      !_isRouteTransitioning &&
      !_isBottomSheetOpen &&
      mounted;

  void setOverlaySetState(void Function(void Function())? setter) {
    _overlaySetState = setter;
  }

  void callOverlaySetState() {
    _overlaySetState?.call(() {});
  }

  void clearOverlaySetState() {
    _overlaySetState = null;
  }

  @protected
  Widget buildMainFab() {
    return MainFab(
      fabVisibleLocal: _fabVisibleInOverlay,
      onPressed: () async {
        await onMainFabPressedLogic(viewModel);
      },
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

  void setFabCanBeShown(bool canShow) {
    if (_fabCanBeShown == canShow) return;
    _fabCanBeShown = canShow;
    _updateFabOverlayVisibility();
  }

  void setIsProcessActive(bool active) {
    _isProcessActive = active;
    _updateFabOverlayVisibility();
  }

  void _updateFabOverlayVisibility() {
    if (canShowFabOverlay) {
      _insertFabOverlayIfAllowed();
    } else {
      _removeFabOverlay();
    }
  }

  void handleVisibilityChange(VisibilityInfo info) {
    if (_isProcessActive || _isRouteTransitioning) return;
    if (info.visibleFraction < 0.4 || _isBottomSheetOpen) {
      setFabCanBeShown(false);
    } else {
      setFabCanBeShown(true);
    }
  }

  void _insertFabOverlayIfAllowed() {
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
                      AnimatedFabContainer(
                        fabVisibleLocal: _fabVisibleInOverlay,
                        rightPosition: 16,
                        bottomPosition: smallFabBottomPosition,
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
                        ),
                      ),
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
