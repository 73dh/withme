import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
import 'package:withme/presentation/home/prospect_list/components/main_fab.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';

import '../prospect_list_view_model.dart';

mixin FabOverlayManagerMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  OverlayEntry? _fabOverlayEntry;
  bool _fabExpanded = false;
  bool _fabVisibleInOverlay = false;
  bool _fabOverlayIsInserted = false;
  bool _fabCanBeShown = true;
  bool _isProcessActive = false;
  void Function(void Function())? _overlaySetState;

  ProspectListViewModel get viewModel;

  Future<void> onMainFabPressedLogic();
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

  // --- 믹스인 라이프사이클 메서드 ---
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

  // --- RouteAware 콜백 (믹스인에서 처리) ---
  @override
  void didPushNext() {
    _fabCanBeShown = false;
    _removeFabOverlay();
  }

  @override
  void didPopNext() {
    _removeFabOverlay();
    _fabCanBeShown = true;
    viewModel.fetchData(force: true);
    _insertFabOverlayIfAllowed();
  }

  // --- 메인 페이지에서 FAB를 제어하기 위한 공개 메서드 ---

  void setFabCanBeShown(bool canShow) {
    _fabCanBeShown = canShow;
    if (!canShow) {
      _removeFabOverlay();
    } else {
      _insertFabOverlayIfAllowed();
    }
  }

  /// 모달 시트 표시와 같은 긴 작업이 진행 중임을 믹스인에 알립니다.
  /// 이 플래그가 [true]이면 FAB를 숨기고, [false]가 되면 다시 표시를 시도합니다.
  void setIsProcessActive(bool active) {
    _isProcessActive = active;
    if (active) {
      _removeFabOverlay();
    } else {
      _insertFabOverlayIfAllowed();
    }
  }

  /// [VisibilityDetector]를 통해 위젯의 가시성 변경을 처리합니다.
  /// 페이지가 가려지면 FAB를 숨기고, 다시 보이면 표시합니다.
  void handleVisibilityChange(VisibilityInfo info) {
    if (_isProcessActive) return;

    if (info.visibleFraction < 0.9) {
      setFabCanBeShown(false);
    } else {
      setFabCanBeShown(true);
    }
  }

  // --- FAB 오버레이 관리를 위한 내부 메서드 ---

  /// 모든 조건이 충족될 경우에만 FAB 오버레이 삽입을 시도합니다.
  void _insertFabOverlayIfAllowed() {
    if (!_fabCanBeShown ||
        _fabOverlayIsInserted ||
        !mounted ||
        _isProcessActive) {
      return;
    }
    _insertFabOverlay();
  }

  /// 실제로 FAB 오버레이를 [Navigator]의 오버레이에 삽입합니다.
  void _insertFabOverlay() {
    if (_fabOverlayIsInserted) return;
    _removeFabOverlay();

    // 새로운 삽입을 위해 FAB의 내부 상태를 초기화합니다.
    _fabExpanded = false;
    _fabVisibleInOverlay = false;

    // 위젯 트리가 완전히 빌드된 후 오버레이 작업을 수행하도록 스케줄링합니다.
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
                        bottomPosition: 132,
                        child: SmallFab(
                          fabExpanded: _fabExpanded,
                          fabVisibleLocal: _fabVisibleInOverlay,
                          overlaySetState: (_) => _toggleFabExpanded(),
                          // overlaySetStateFold: (_) => _toggleFabExpanded(),
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
                      // MainFab (새 고객 추가)
                      AnimatedFabContainer(
                        fabVisibleLocal: _fabVisibleInOverlay,
                        rightPosition: 16,
                        bottomPosition: 66,
                        child: MainFab(
                          fabVisibleLocal: _fabVisibleInOverlay,

                          onPressed: () async {
                            await onMainFabPressedLogic();
                          },
                        ),
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

      // FAB가 화면에 부드럽게 나타나도록 애니메이션 지연을 줍니다.
      Future.delayed(AppDurations.duration100, () {
        if (!mounted || _fabOverlayEntry != localEntry || !_fabCanBeShown)
          return; // 유효성 재검사
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _fabOverlayEntry != localEntry || !_fabCanBeShown)
            return; // 유효성 재검사
          _overlaySetState?.call(() {
            _fabVisibleInOverlay = true;
            _fabExpanded = false;
          });
        });
      });
    });
  }

  /// FAB 오버레이를 화면에서 제거합니다.
  void _removeFabOverlay() {
    _fabOverlayEntry?.remove();
    _fabOverlayEntry = null;
    _fabOverlayIsInserted = false;
    _fabExpanded = false;
    _fabVisibleInOverlay = false;
    _overlaySetState = null;
  }

  /// 서브 FAB의 확장/축소 상태를 토글합니다.
  void _toggleFabExpanded() {
    _overlaySetState?.call(() {
      _fabExpanded = !_fabExpanded;
    });
  }
}
