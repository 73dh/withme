import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
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
  void Function(void Function())? overlaySetState;

  @override
  void initState() {
    super.initState();
    viewModel.fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteObserver 등록
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _removeFabOverlay();
    super.dispose();
  }

  @override
  void didPopNext() {
    // 다른 화면에서 복귀 시 실행됨
    _fabCanShow = true;
    viewModel.fetchData(force: true); // <-- 이 줄 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertFabOverlayIfAllowed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('prospect-list-visibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction < 0.9) {
          _removeFabOverlayAndHide();
        } else {
          _fabCanShow = true;
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
                debugPrint('StreamBuilder rebuild - hasData: ${snapshot.hasData}, length: ${snapshot.data?.length}');

                if (snapshot.hasError) {
                  log(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  _insertFabOverlayIfAllowed(); // prospect 없어도 호출되도록
                  return const Center(child: Text('가망고객이 없습니다.'));
                }
                final prospectsOrigin = snapshot.data!;
                final filteredProspects =
                    prospectsOrigin
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
                await  viewModel.fetchData(force: true);
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
    if (_fabCanShow && mounted && !_fabOverlayInserted) {
      _insertFabOverlay();
    }
  }

  void _insertFabOverlay() {
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
                            if (context.mounted) {
                              final isLimited =
                                  await FreeLimitDialog.checkAndShow(
                                    context: context,
                                    viewModel: viewModel,
                                  );

                            print('isLimited: $isLimited');
                              if (isLimited) return;
                              overlaySetState?.call(() {
                                _fabExpanded = false;
                                _fabVisibleLocal = false;
                              });

                              if (context.mounted) {
                                final result = await context.push(
                                  RoutePath.registration,
                                );
                                print('result from registration: $result');
                                if (result == true) {
                                await  viewModel.fetchData(force: true);
                                }
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
    _fabOverlayEntry?.remove();
    _fabOverlayEntry = null;
    _fabOverlayInserted = false;
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
