import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/fab/animated_fab_container.dart';
import 'package:withme/core/presentation/fab/main_fab.dart';
import 'package:withme/core/presentation/fab/small_fab.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/const/position.dart';

import '../../../presentation/registration_sheet/sheet/registration_bottom_sheet.dart';
import '../../di/setup.dart';
import '../../domain/sort_status.dart';
import '../components/free_limit_dialog.dart';
import '../widget/show_bottom_sheet_with_draggable.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';

abstract class FabViewModelInterface {
  void fetchData({bool force});

  void sortByName();

  void sortByBirth();

  void sortByInsuranceAgeDate();

  void sortByHistoryCount();

  SortStatus get sortStatus;
}

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
  bool _fabCanBeShown = true;
  bool _isProcessActive = false;
  bool _isRouteTransitioning = false; // 추가: 화면전환 중 상태
  void Function(void Function())? _overlaySetState;
  double smallFabBottomPosition = FabPosition.firstFabBottomPosition;

  VM get viewModel;

  void onSortActionLogic(Function() sortFn);

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
        await onMainFabPressedLogic(getIt<ProspectListViewModel>());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fabCanBeShown = true;
      _insertFabOverlayIfAllowed();
    });
  }

  @override
  void dispose() {
    _removeFabOverlay();
    super.dispose();
  }

  @override
  void didPushNext() {
    // 화면 전환 시작
    _isRouteTransitioning = true;
    // _fabCanBeShown = false;
    _removeFabOverlay();
  }

  // @override
  // void didPopNext() {
  //   // 화면 복귀 시작
  //   _isRouteTransitioning = true;
  //   _removeFabOverlay();
  //
  //   // 다음 프레임에 화면 전환 완료 처리
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!mounted) return;
  //     _isRouteTransitioning = false;
  //
  //     if (!_isProcessActive) {
  //       _fabCanBeShown = true;
  //       _insertFabOverlayIfAllowed();
  //     }
  //
  //     viewModel.fetchData(force: true);
  //   });
  // }
  @override
  void didPopNext() {
    _isRouteTransitioning = false;
    _fabCanBeShown = true;
    _insertFabOverlayIfAllowed(); // ✅ 즉시 재삽입 시도

    // 📌 데이터 갱신은 overlay 로직과 분리
    viewModel.fetchData(force: true);
  }

  // void setFabCanBeShown(bool canShow) {
  //   if (_fabCanBeShown == canShow) return;
  //
  //   _fabCanBeShown = canShow;
  //   callOverlaySetState();
  //
  //   if (_fabCanBeShown) {
  //     _insertFabOverlayIfAllowed();
  //   } else {
  //     _removeFabOverlay();
  //   }
  // }
  void setFabCanBeShown(bool canShow) {
    if (_fabCanBeShown == canShow) return;

    _fabCanBeShown = canShow;
    callOverlaySetState();

    if (_fabCanBeShown) {
      Future.microtask(_insertFabOverlayIfAllowed); // 📌 타이밍 명확히
    } else {
      _removeFabOverlay();
    }
  }

  void setIsProcessActive(bool active) {
    _isProcessActive = active;
    if (active) {
      _removeFabOverlay();
    } else if (!_isRouteTransitioning) {
      // 화면 전환 중 아닐 때만 삽입
      _insertFabOverlayIfAllowed();
    }
  }

  // void handleVisibilityChange(VisibilityInfo info) {
  //   if (_isProcessActive) return;
  //   if (info.visibleFraction < 0.9) {
  //     setFabCanBeShown(false);
  //   }
  // }
  void handleVisibilityChange(VisibilityInfo info) {
    if (_isProcessActive || _isRouteTransitioning) return;

    if (info.visibleFraction > 0.6) {
      setFabCanBeShown(true);
    } else {
      setFabCanBeShown(false);
    }
  }

  Future<void> onMainFabPressedLogic(ProspectListViewModel viewModel) async {
    if (!mounted) return;

    final isLimited = await FreeLimitDialog.checkAndShow(
      context: context,
      viewModel: viewModel,
    );
    if (isLimited) return;

    setIsProcessActive(true);
    setFabCanBeShown(false);

    if (!context.mounted) return;

    await showBottomSheetWithDraggable(
      context: context,
      builder:
          (scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: RegistrationBottomSheet(scrollController: scrollController),
          ),
      onClosed: () async {
        debugPrint('[FabOverlayManagerMixin] BottomSheet closed');
        setIsProcessActive(false);
        await viewModel.fetchData(force: true);

        // ✅ FAB는 반드시 bottomSheet 애니메이션 종료 후 등장하도록 약간 지연
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          setFabCanBeShown(true);
        });
      },
    );
  }

  void _insertFabOverlayIfAllowed() {
    // if (!_fabCanBeShown ||
    //     _fabOverlayIsInserted ||
    //     !mounted ||
    //     _isProcessActive ||
    //     _isRouteTransitioning)
    //   return;
    if (!_fabCanBeShown || _fabOverlayIsInserted || !mounted || _isRouteTransitioning)
      return;

    _removeFabOverlay();

    _fabExpanded = false;
    _fabVisibleInOverlay = false;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
                        bottomPosition: FabPosition.secondFabBottomPosition,
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
        if (!mounted || _fabOverlayEntry != localEntry || !_fabCanBeShown)
          return;
        _overlaySetState?.call(() {
          _fabVisibleInOverlay = true;
          _fabExpanded = false;
        });
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
