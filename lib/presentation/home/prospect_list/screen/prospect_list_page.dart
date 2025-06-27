import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
import 'package:withme/core/presentation/components/animated_text.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';
import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/domain/enum/membership_status.dart';
import '../../../../core/presentation/components/free_limit_dialog.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/router/router_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/main_fab.dart';

// 생략된 import는 그대로 유지

class ProspectListPage extends StatefulWidget {
  const ProspectListPage({super.key});

  @override
  State<ProspectListPage> createState() => _ProspectListPageState();
}

class _ProspectListPageState extends State<ProspectListPage> with RouteAware {
  final RouteObserver<PageRoute> routeObserver =
      getIt<RouteObserver<PageRoute>>();
  final viewModel = getIt<ProspectListViewModel>();
  String? _searchText = '';

  OverlayEntry? _fabOverlayEntry;
  bool _fabExpanded = true;
  bool _fabVisibleLocal = false;
  bool _fabOverlayInserted = false;
  bool _fabCanShow = true;
  bool _visibilityBlocked = false; // VisibilityDetector 중복 실행 방지용
  void Function(void Function())? overlaySetState;

  @override
  void initState() {
    super.initState();
    viewModel.fetchData(force: true);
    // 최초 진입 시 무조건 FAB 삽입 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fabCanShow = true;
      _insertFabOverlayIfAllowed();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _removeFabOverlay(); // clean up overlay
    super.dispose();
  }

  @override
  void didPushNext() {
    debugPrint('➡️ didPushNext - FAB 제거 호출됨');
    _fabCanShow = false;
    _removeFabOverlay();
  }

  @override
  void didPopNext() {
    debugPrint('⬅️ didPopNext - FAB 재삽입 호출됨');
    _removeFabOverlay();
    _fabCanShow = true;
    viewModel.fetchData(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('prospect-list-visibility'),
      onVisibilityChanged: (info) {
        if (_visibilityBlocked) return;
        if (info.visibleFraction < 0.9) {
          debugPrint('[VisibilityDetector] 숨겨짐 감지, FAB 제거');
          _removeFabOverlayAndHide();
          _visibilityBlocked = true;
          // 잠시 딜레이 후 재진입 가능하도록 해제
          Future.delayed(const Duration(milliseconds: 500), () {
            _visibilityBlocked = false;
          });
        } else {
          debugPrint('[VisibilityDetector] 다시 보여짐 감지, FAB 삽입 시도');

          if (!_fabCanShow) return; // 👈 추가
          _insertFabOverlayIfAllowed();
        }
      },
      child: SafeArea(
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            return StreamBuilder<List<CustomerModel>>(
              stream: viewModel.cachedProspects,
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_fabCanShow && !_fabOverlayInserted) {
                    _insertFabOverlay();
                  }
                });

                if (snapshot.hasError) {
                  log('StreamBuilder error: ${snapshot.error}');
                }

                if (data.isEmpty) {
                  return const Center(child: AnimatedText(text: '고객정보 없음'));
                }

                final filteredProspects =
                    data
                        .where((e) => e.name.contains(_searchText ?? ''))
                        .toList();

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: _appBar(filteredProspects.length),
                  body: _prospectList(filteredProspects),
                );
              },
            );
          },
        ),
      ),
    );
  }

  AppBar _appBar(int count) {
    return AppBar(
      title: Text('Prospect $count명'),
      actions: [
        AppBarSearchWidget(
          onSubmitted: (text) {
            setState(() {
              _searchText = text;
            });
          },
        ),
      ],
    );
  }

  Widget _prospectList(List<CustomerModel> prospects) {
    print('prospects length: ${prospects.length}');
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(prospects.length, (index) {
          final customer = prospects[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: () async {
                _removeFabOverlayAndHide();
                final result = await context.push(
                  RoutePath.registration,
                  extra: customer,
                );
                if (result == true) {
                  await viewModel.fetchData(force: true);
                  _fabCanShow = true;
                  _insertFabOverlayIfAllowed();
                }
              },
              child: ProspectItem(
                userKey: UserSession.userId,
                customer: customer,
                onTap: (histories) async {
                  _fabCanShow = false;
                  _removeFabOverlay();
                  setState(() {});

                  final result = await popupAddHistory(
                    context,
                    histories,
                    customer,
                    HistoryContent.title.toString(),
                  );

                  if (!mounted) return;
                  _fabCanShow = true;
                  if (result == true) {
                    _insertFabOverlayIfAllowed();
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  void _insertFabOverlayIfAllowed() {
    debugPrint(
      '[FAB] insert check: mounted=$mounted, inserted=$_fabOverlayInserted, canShow=$_fabCanShow',
    );
    if (!_fabCanShow || _fabOverlayInserted || !mounted) return;
    _insertFabOverlay();
  }

  void _insertFabOverlay() {
    if (_fabOverlayInserted) return;
    _removeFabOverlay();
    _fabExpanded = false;
    _fabVisibleLocal = false;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final overlay = Navigator.of(context).overlay;
      if (overlay == null) return;

      OverlayEntry? localEntry;
      localEntry = OverlayEntry(
        builder: (context) {
          overlaySetState = null;
          return StatefulBuilder(
            builder: (context, setState) {
              overlaySetState = (fn) {
                if (!mounted || localEntry != _fabOverlayEntry) return;
                setState(fn);
              };

              return Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_fabVisibleLocal,
                  child: Stack(
                    children: [
                      AnimatedFabContainer(
                        fabVisibleLocal: _fabVisibleLocal,
                        rightPosition: 16,
                        bottomPosition: 132,
                        child: SmallFab(
                          fabExpanded: _fabExpanded,
                          fabVisibleLocal: _fabVisibleLocal,
                          overlaySetState: (_) => _toggleFabExpanded(),
                          overlaySetStateFold: (_) => _toggleFabExpanded(),
                          onSortByName: () {
                            viewModel.sortByName();
                            overlaySetState?.call(() {});
                          },
                          onSortByBirth: () {
                            viewModel.sortByBirth();
                            overlaySetState?.call(() {});
                          },
                          onSortByInsuredDate: () {
                            viewModel.sortByInsuranceAgeDate();
                            overlaySetState?.call(() {});
                          },
                          onSortByManage: () {
                            viewModel.sortByHistoryCount();
                            overlaySetState?.call(() {});
                          },
                          selectedSortStatus: viewModel.sortStatus,
                        ),
                      ),
                      AnimatedFabContainer(
                        fabVisibleLocal: _fabVisibleLocal,
                        rightPosition: 16,
                        bottomPosition: 66,
                        child: MainFab(
                          fabVisibleLocal: _fabVisibleLocal,
                          onPressed: () async {
                            if (!mounted) return;
                            final isLimited =
                                await FreeLimitDialog.checkAndShow(
                                  context: context,
                                  viewModel: viewModel,
                                );

                            if (isLimited) return;

                            overlaySetState?.call(() {
                              _fabExpanded = false;
                              _fabVisibleLocal = false;
                            });

                            _removeFabOverlay();
                            if (context.mounted) {
                              final result = await context.push(
                                RoutePath.registration,
                              );

                              if (result == true) {
                                _fabCanShow = true;
                                print('test result**************: $result');
                                await viewModel.fetchData(force: true);
                              }
                            }
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
      _fabOverlayInserted = true;

      Future.delayed(AppDurations.duration100, () {
        if (!mounted || _fabOverlayEntry != localEntry || !_fabCanShow) return;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _fabOverlayEntry != localEntry || !_fabCanShow)
            return;
          overlaySetState?.call(() {
            _fabVisibleLocal = true;
            _fabExpanded = false;
          });
        });
      });
    });
  }

  void _removeFabOverlay() {
    debugPrint('[FAB] 제거 시작');
    if (_fabOverlayEntry != null) {
      _fabOverlayEntry!.remove();
      _fabOverlayEntry = null;

      debugPrint('[FAB] 제거 완료');
    } else {
      debugPrint('[FAB] 제거 시도했으나 _fabOverlayEntry null');
    }
    _fabOverlayInserted = false;
    _fabExpanded = false;
    _fabVisibleLocal = false;
    overlaySetState = null;
  }

  void _removeFabOverlayAndHide() {
    _removeFabOverlay();
    _fabCanShow = false;
  }

  void _toggleFabExpanded() {
    overlaySetState?.call(() {
      _fabExpanded = !_fabExpanded;
    });
  }
}
