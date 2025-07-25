import 'dart:async';
import 'dart:developer';

import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/prospect_list/components/fab_oevelay_manager_mixin.dart';
import 'package:withme/presentation/home/prospect_list/components/inactive_and_urgent_filter_bar.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../domain/use_case/customer/apply_current_sort_use_case.dart';
import '../../../registration_sheet/sheet/registration_bottom_sheet.dart';

class ProspectListPage extends StatefulWidget {
  const ProspectListPage({super.key});

  @override
  State<ProspectListPage> createState() => _ProspectListPageState();
}

class _ProspectListPageState extends State<ProspectListPage>
    with RouteAware, FabOverlayManagerMixin<ProspectListPage> {
  final RouteObserver<PageRoute> _routeObserver =
      getIt<RouteObserver<PageRoute>>();
  @override
  final viewModel = getIt<ProspectListViewModel>();

  final String _searchText = '';
  bool _showInactiveOnly = false; // 관리일 경과 필터
  bool _showUrgentOnly = false; // 상령일 필터


  @override
  void initState() {
    super.initState();
    viewModel.fetchData(force: true);
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
    super.dispose();
  }

  List<CustomerModel> _applyFilterAndSort(List<CustomerModel> customers) {
    var filtered = customers.where((e) => e.policies.isEmpty).toList();

    if (_searchText.isNotEmpty) {
      filtered = filtered.where((e) => e.name.contains(_searchText)).toList();
    }

    if (_showInactiveOnly) {
      final today = DateTime.now();
      final managePeriodDays = getIt<UserSession>().managePeriodDays;

      filtered =
          filtered.where((e) {
            final latestHistoryDate = e.histories
                .map((h) => h.contactDate)
                .fold<DateTime?>(null, (prev, date) {
                  if (prev == null) return date;
                  return date.isAfter(prev) ? date : prev;
                });

            if (latestHistoryDate == null) return true;
            return latestHistoryDate
                .add(Duration(days: managePeriodDays))
                .isBefore(today);
          }).toList();
    }

    return ApplyCurrentSortUseCase(
      isAscending: viewModel.sortStatus.isAscending,
      currentSortType: viewModel.sortStatus.type,
    ).call(filtered);
  }

  @override
  Future<void> onMainFabPressedLogic() async {
    if (!mounted) return;

    final isLimited = await FreeLimitDialog.checkAndShow(
      context: context,
      viewModel: viewModel,
    );
    if (isLimited) return;

    setIsProcessActive(true);

    if (!context.mounted) return;

    final safeContext = context;
    final result = await showBottomSheetWithDraggable(
      context: safeContext,
      builder:
          (scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: RegistrationBottomSheet(scrollController: scrollController),
          ),
    ).then((_) {
      setFabCanBeShown(true);
    });

    setIsProcessActive(false);

    if (!mounted) return;

    if (result == true) {
      await viewModel.fetchData(force: true);
    }
  }

  @override
  void onSortActionLogic(Function() sortFn) {
    sortFn();
    callOverlaySetState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('prospect-list-visibility'),
      onVisibilityChanged: handleVisibilityChange,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            return StreamBuilder<List<CustomerModel>>(
              stream: viewModel.cachedProspects,
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                final filteredProspects = _applyFilterAndSort(data);

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
                          viewModel.updateFilter(searchText: text);
                        },
                      ),
                    ],
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InactiveAndUrgentFilterBar(
                        showInactiveOnly: _showInactiveOnly,
                        showUrgentOnly: _showUrgentOnly,
                        onInactiveToggle: (val) {
                          setState(() => _showInactiveOnly = val);
                          getIt<ProspectListViewModel>().updateFilter(
                            inactiveOnly: val,
                          );
                        },
                        onUrgentToggle: (val) {
                          setState(() => _showUrgentOnly = val);
                          getIt<ProspectListViewModel>().updateFilter(
                            urgentOnly: val,
                          );
                        },
                      ),

                      const SizedBox(height: 5),

                      // ▶ 리스트 뷰
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
                              child: GestureDetector(
                                onTap: () async {
                                  setFabCanBeShown(false);

                                 await showBottomSheetWithDraggable(
                                    context: context,
                                    child: RegistrationBottomSheet(
                                      customerModel: customer,
                                      outerContext: context,
                                      isSuccess: (bool result) {
                                        print('등록 결과: $result');
                                        // 성공 여부에 따라 추가 처리 가능
                                      },
                                    ),
                                  ).then((_) {

                                    // ✅ RegistrationBottomSheet 완전히 닫힌 뒤 FAB 복원
                                    setFabCanBeShown(true);
                                  });
                                  if (!mounted) return;
                                  await viewModel.fetchData(force: true);
                                },
                                child: ProspectItem(
                                  userKey: UserSession.userId,
                                  customer: customer,
                                  onTap: (histories) async {
                                    setFabCanBeShown(false);
                                    await popupAddHistory(
                                      context,
                                      histories,
                                      customer,
                                      HistoryContent.title.toString(),
                                    );

                                    if (!mounted) return;
                                    setFabCanBeShown(true);
                                  },
                                ),
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
}
