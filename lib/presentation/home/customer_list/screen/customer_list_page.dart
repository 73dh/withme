import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/customer_item.dart';
import 'package:withme/core/presentation/mixin/filter_bar_animation_mixin.dart';
import 'package:withme/core/presentation/widget/size_transition_filter_bar.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/const/position.dart';

import '../../../../../core/di/setup.dart';
import '../../../../core/data/fire_base/user_session.dart';
import '../../../../core/domain/enum/history_content.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/fab/fab_oevelay_manager_mixin.dart';
import '../../../../core/presentation/widget/inactive_and_urgent_filter_bar.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../../../../domain/use_case/customer/apply_current_sort_use_case.dart';
import '../components/customer_list_app_bar.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage>
    with
        RouteAware,
        FabOverlayManagerMixin<CustomerListPage, CustomerListViewModel>,
        SingleTickerProviderStateMixin,
        FilterBarAnimationMixin {
  final RouteObserver<PageRoute> _routeObserver =
      getIt<RouteObserver<PageRoute>>();
  @override
  final CustomerListViewModel viewModel = getIt<CustomerListViewModel>();

  // // 필터바 접힘 상태
  // bool _filterBarExpanded = false;
  // late final AnimationController _controller;
  // late final Animation<double> _heightFactor;

  String _searchText = '';
  bool _showInactiveOnly = false;

  void _toggleFilterBar() => toggleFilterBarAnimation();

  // void _toggleFilterBar() {
  //   setState(() {
  //     _filterBarExpanded = !_filterBarExpanded;
  //     if (_filterBarExpanded) {
  //       _controller.forward();
  //     } else {
  //       _controller.reverse();
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    smallFabBottomPosition = FabPosition.secondFabBottomPosition;
    viewModel.fetchData(force: true);
    initFilterBarAnimation(vsync: this);
    // _controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 300),
    //   value: 0.0, // 접힌 상태로 시작 (0.0)
    // );
    // _heightFactor = CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.easeInOut,
    // );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) _routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Future<void> onMainFabPressedLogic(ProspectListViewModel viewModel) async {
    debugPrint('Main FAB pressed - no action on CustomerListPage');
  }

  @override
  void onSortActionLogic(Function() sortFn) {
    sortFn();
    callOverlaySetState();
  }

  @override
  Widget buildMainFab() => const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('customer-list-visibility'),
      onVisibilityChanged: handleVisibilityChange,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: viewModel,
          builder:
              (context, _) => StreamBuilder<List<CustomerModel>>(
                stream: viewModel.cachedCustomers,
                builder: (context, snapshot) {
                  final data = snapshot.data ?? [];
                  final filtered = _applyFilterAndSort(data);

                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: CustomerListAppBar(
                      count: filtered.length,
                      onSearch: (text) => setState(() => _searchText = text),
                      filterBarExpanded: filterBarExpanded,
                      onToggleFilterBar: _toggleFilterBar,
                    ),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizeTransitionFilterBar(
                          heightFactor: heightFactor,
                          child: InactiveAndUrgentFilterBar(
                            showInactiveOnly: _showInactiveOnly,
                            onInactiveToggle:
                                (val) =>
                                    setState(() => _showInactiveOnly = val),
                            inactiveCount: viewModel.inactiveCount,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: _CustomerListView(
                            customers: filtered,
                            onTap: (customer) async {
                              setFabCanBeShown(false);
                              await context.push(
                                RoutePath.customer,
                                extra: customer,
                              );
                              setFabCanBeShown(true);
                              await viewModel.fetchData(force: true);
                            },
                            viewModel: viewModel,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  List<CustomerModel> _applyFilterAndSort(List<CustomerModel> customers) {
    final managePeriodDays = getIt<UserSession>().managePeriodDays;
    final now = DateTime.now();
    var filtered = customers.where((e) => e.policies.isNotEmpty).toList();

    if (_searchText.isNotEmpty) {
      filtered =
          filtered.where((e) => e.name.contains(_searchText.trim())).toList();
    }

    if (_showInactiveOnly) {
      filtered =
          filtered.where((e) {
            final latest = e.histories
                .map((h) => h.contactDate)
                .fold<DateTime?>(
                  null,
                  (prev, date) =>
                      prev == null || date.isAfter(prev) ? date : prev,
                );
            return latest == null ||
                latest.add(Duration(days: managePeriodDays)).isBefore(now);
          }).toList();
    }

    return ApplyCurrentSortUseCase(
      isAscending: viewModel.sortStatus.isAscending,
      currentSortType: viewModel.sortStatus.type,
    ).call(filtered);
  }
}

class _CustomerListView extends StatelessWidget {
  final List<CustomerModel> customers;
  final void Function(CustomerModel) onTap;
  final CustomerListViewModel viewModel;

  const _CustomerListView({required this.customers, required this.onTap, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: GestureDetector(
            onTap: () => onTap(customer),
            child: CustomerItem(customer: customer,   onTap: (histories) async {
              final newHistory = await popupAddHistory(
                context,
                customer.histories,
                customer,
                HistoryContent.title.toString(),
              );

              if (newHistory != null) {
                final updatedHistories = [...customer.histories, newHistory];
                final updatedCustomer = customer.copyWith(histories: updatedHistories);
                viewModel.updateCustomerInList(updatedCustomer);
              }
              // await popupAddHistory(
              //   context,
              //   histories,
              //   customer,
              //   HistoryContent.title.toString(),
              // );

            },),
          ),
        );
      },
    );
  }
}
