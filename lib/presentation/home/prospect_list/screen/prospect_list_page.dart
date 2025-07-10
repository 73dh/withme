import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/router/router_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../../../../domain/use_case/customer/apply_current_sort_use_case.dart';
import '../components/main_fab.dart';

import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/router/router_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/main_fab.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/use_case/customer/apply_current_sort_use_case.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
import 'package:withme/presentation/home/prospect_list/components/main_fab.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/sort_status.dart';
import '../../../../core/router/router_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';
import 'package:withme/presentation/home/prospect_list/components/main_fab.dart';

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
  final RouteObserver<PageRoute> _routeObserver =
      getIt<RouteObserver<PageRoute>>();
  final viewModel = getIt<ProspectListViewModel>();

  String? _searchText = '';
  int? _selectedMonth = DateTime.now().month;

  OverlayEntry? _fabOverlayEntry;
  bool _fabExpanded = true;
  bool _fabVisibleLocal = false;
  bool _fabOverlayInserted = false;
  bool _fabCanShow = true;
  bool _visibilityBlocked = false;
  void Function(void Function())? overlaySetState;

  @override
  void initState() {
    super.initState();
    viewModel.fetchData(force: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fabCanShow = true;
      _insertFabOverlayIfAllowed();
      _selectedMonth = DateTime.now().month;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      _routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    _removeFabOverlay();
    super.dispose();
  }

  @override
  void didPushNext() {
    _fabCanShow = false;
    _removeFabOverlay();
  }

  @override
  void didPopNext() {
    _removeFabOverlay();
    _fabCanShow = true;
    viewModel.fetchData(force: true);
  }

  List<CustomerModel> _applyFilterAndSort(List<CustomerModel> customers) {
    var filtered = customers.where((e) => e.policies.isEmpty).toList();

    if (_searchText?.isNotEmpty ?? false) {
      filtered = filtered.where((e) => e.name.contains(_searchText!)).toList();
    }

    if (_selectedMonth != null) {
      filtered =
          filtered
              .where((e) => e.registeredDate.month == _selectedMonth)
              .toList();
    }

    return ApplyCurrentSortUseCase(
      isAscending: viewModel.sortStatus.isAscending,
      currentSortType: viewModel.sortStatus.type,
    ).call(filtered);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('prospect-list-visibility'),
      onVisibilityChanged: (info) {
        if (_visibilityBlocked) return;
        if (info.visibleFraction < 0.9) {
          _removeFabOverlayAndHide();
          _visibilityBlocked = true;
          Future.delayed(AppDurations.duration100, () {
            _visibilityBlocked = false;
          });
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
                final data = snapshot.data ?? [];
                final filteredProspects = _applyFilterAndSort(data);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_fabCanShow && !_fabOverlayInserted) {
                    _insertFabOverlay();
                  }
                });

                if (snapshot.hasError) {
                  log('StreamBuilder error: ${snapshot.error}');
                }

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: Text('Prospect ${filteredProspects.length}명'),
                    actions: [
                      AppBarSearchWidget(
                        onSubmitted: (text) {
                          setState(() {
                            _searchText = text;
                          });
                        },
                      ),
                    ],
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthChips(data),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: filteredProspects.length,
                          itemBuilder: (context, index) {
                            final customer = filteredProspects[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: ProspectItem(
                                userKey: UserSession.userId,
                                customer: customer,
                                onTap: (histories) async {
                                  _fabCanShow = false;
                                  _removeFabOverlay();

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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthChips(List<CustomerModel> customers) {
    final months =
        customers
            .where((e) => e.policies.isEmpty)
            .map((e) => e.registeredDate.month)
            .toSet()
            .toList()
          ..sort();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: months.length,
        itemBuilder: (_, index) {
          final month = months[index];
          final selected = _selectedMonth == month;
          return ChoiceChip(
            label: Text('$month월'),
            selected: selected,
            onSelected: (isSelected) {
              setState(() {
                // ✅ 같은 월 다시 누르면 해제
                if (_selectedMonth == month) {
                  _selectedMonth = null;
                } else {
                  _selectedMonth = month;
                }
              });
            },
          );
        },
      ),
    );
  }

  void _insertFabOverlayIfAllowed() {
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

                          // ✅ 조건 제거
                          onSortByName: () => _sort(viewModel.sortByName),
                          onSortByBirth: () => _sort(viewModel.sortByBirth),
                          onSortByInsuredDate:
                              () => _sort(viewModel.sortByInsuranceAgeDate),
                          onSortByManage:
                              () => _sort(viewModel.sortByHistoryCount),

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
    _fabOverlayEntry?.remove();
    _fabOverlayEntry = null;
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

  void _sort(Function() sortFn) {
    sortFn();
    overlaySetState?.call(() {});
  }
}
