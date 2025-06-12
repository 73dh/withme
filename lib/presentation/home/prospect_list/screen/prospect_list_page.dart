import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/presentation/home/prospect_list/components/fab_container.dart';
import 'package:withme/presentation/home/prospect_list/components/main_fab.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';
import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/router/router_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';

class ProspectListPage extends StatefulWidget {
  const ProspectListPage({super.key});

  @override
  State<ProspectListPage> createState() => _ProspectListPageState();
}

class _ProspectListPageState extends State<ProspectListPage> with RouteAware {
  final viewModel = getIt<ProspectListViewModel>();
  String? _searchText = '';
  PageRoute? _route;

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

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _route = route;
      getIt<RouteObserver<PageRoute>>().subscribe(this, _route!);
    }

    if (!_fabOverlayInserted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _insertFabOverlay();
      });
    }
  }

  @override
  void dispose() {
    getIt<RouteObserver<PageRoute>>().unsubscribe(this);
    _removeFabOverlay();
    super.dispose();
  }

  @override
  void didPopNext() {
    viewModel.fetchData();
    _insertFabOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<CustomerModel>>(
        stream: viewModel.cachedProspects,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const MyCircularIndicator();
          }

          final prospectsOrigin = snapshot.data!;
          final filteredProspects =
              prospectsOrigin
                  .where((e) => e.name.contains(_searchText ?? ''))
                  .toList();

          return Scaffold(
            appBar: _appBar(filteredProspects.length),
            body: _prospectList(filteredProspects),
          );
        },
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
              onTap: () {
                context.push(RoutePath.registration, extra: customer);
              },
              child: ProspectItem(
                customer: customer,
                onTap: (histories) async {
                  // 1. 팝업 뜨기 전 FAB 숨기기
                  _fabCanShow = false;
                  _removeFabOverlay();
                  setState(() {});

                  // 팝업 열기 전에 아주 잠깐 대기 (UI 안정화)
                  await Future.delayed(const Duration(milliseconds: 100));

                  if (!mounted) return;

                  // 2. 팝업 실행 및 결과 기다림
                  final result = await popupAddHistory(
                    context,
                    histories,
                    customer,
                    HistoryContent.title.toString(),
                  );

                  // 3. 팝업 종료 후 FAB 다시 보여주기 허용 및 삽입
                  if (!mounted) return;

                  if (result == true) {
                    _fabCanShow = true;
                    _insertFabOverlay();
                  } else {
                    // 팝업 취소됐으면 다시 허용만 하고 Overlay는 안 넣음
                    _fabCanShow = true;
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  /// ✅ FAB Overlay 삽입
  void _insertFabOverlay() {
    // 팝업이 떠 있는 동안 삽입 막기
    if (!_fabCanShow) return;

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
                      FabContainer(
                        fabVisibleLocal: _fabVisibleLocal,
                        rightPosition: 16,
                        bottomPosition: 132,
                        child: SmallFab(
                          fabExpanded: _fabExpanded,
                          fabVisibleLocal: _fabVisibleLocal,
                          overlaySetState: (_) => _toggleFabExpanded(),
                          overlaySetStateFold: (_) => _toggleFabExpanded(),
                        ),
                      ),
                      FabContainer(
                        fabVisibleLocal: _fabVisibleLocal,
                        rightPosition: 16,
                        bottomPosition: 66,
                        child: MainFab(
                          fabVisibleLocal: _fabVisibleLocal,
                          onPressed: () async {
                            overlaySetState?.call(() {
                              _fabExpanded = false;
                              _fabVisibleLocal = false;
                            });
                            if (context.mounted) {
                              await context.push(RoutePath.registration);
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

      // 딜레이는 충분히 주되, 팝업이 없을 때만 visible true
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || _fabOverlayEntry != localEntry || !_fabCanShow) return;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _fabOverlayEntry != localEntry || !_fabCanShow) return;
          overlaySetState?.call(() {
            _fabVisibleLocal = true;
            _fabExpanded = false;
          });
        });
      });
    });
  }
  void _removeFabOverlayAndHide() {
    _removeFabOverlay();
    _fabCanShow = false;
  }

  void _insertFabOverlayIfAllowed() {
    if (_fabCanShow && mounted) {
      _insertFabOverlay();
    }
  }

  /// ✅ FAB Overlay 제거
  void _removeFabOverlay() {
    _fabOverlayEntry?.remove();
    _fabOverlayEntry = null;
    _fabOverlayInserted = false;
  }

  void _toggleFabExpanded() {
    overlaySetState?.call(() {
      _fabExpanded = !_fabExpanded;
    });
  }
}
