import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/presentation/components/customer_item.dart';
import '../../../../../core/di/setup.dart';
import '../../../../core/presentation/components/animated_text.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../../prospect_list/components/animated_fab_container.dart';
import '../../prospect_list/components/small_fab.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> with RouteAware {
  // final RouteObserver<PageRoute> _routeObserver =
  //     getIt<RouteObserver<PageRoute>>();

  final viewModel = getIt<CustomerListViewModel>();
  String _searchText = '';

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
    viewModel.fetchOnce();

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
    final routeObserver = getIt<RouteObserver<PageRoute>>();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    getIt<RouteObserver<PageRoute>>().unsubscribe(this);
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
    debugPrint('✅ didPopNext: 고객 등록 후 돌아옴 - 강제 새로고침');
    _removeFabOverlay();
    _fabCanShow = true;
    viewModel.refresh(); // 중요
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('customer-list-visibility'),
      onVisibilityChanged: (info) {
        if (_visibilityBlocked) return;
        if (info.visibleFraction < 0.9) {
          debugPrint('[VisibilityDetector] 숨겨짐 감지, FAB 제거');
          _removeFabOverlayAndHide();
          _visibilityBlocked = true;
          // 잠시 딜레이 후 재진입 가능하도록 해제
          Future.delayed(AppDurations.duration100, () {
            _visibilityBlocked = false;
          });
        } else {
          debugPrint('[VisibilityDetector] 다시 보여짐 감지, FAB 삽입 시도');
          _fabCanShow = true; // 👈 여기 추가!
          _insertFabOverlayIfAllowed();
        }
      },

      child: SafeArea(
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            return StreamBuilder(
              stream: viewModel.cachedCustomers,
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

                List<CustomerModel> originalCustomers = snapshot.data!;
                List<CustomerModel> customers =
                    originalCustomers
                        .where((e) => e.name.contains(_searchText.trim()))
                        .toList();
                return Scaffold(
                  appBar: _appBar(customers),
                  body: _customerList(customers),
                );
              },
            );
          },
        ),
      ),
    );
  }

  SingleChildScrollView _customerList(List<CustomerModel> customers) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      _removeFabOverlayAndHide();
                      if (context.mounted) {
                        await context.push(
                          RoutePath.customer,
                          extra: customers[index],
                        );
                      }
                      _fabCanShow = true;
                      _insertFabOverlayIfAllowed();
                    },
                    child: CustomerItem(customer: customers[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(List<CustomerModel> customers) {
    return AppBar(
      title: Text('Customer ${customers.length}명'),
      actions: [
        AppBarSearchWidget(
          onSubmitted: (text) {
            setState(() => _searchText = text);
          },
        ),
      ],
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
                        bottomPosition: 70,
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

                          selectedSortStatus: viewModel.sortStatus,
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
