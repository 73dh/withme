import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/components/customer_item.dart';
import 'package:withme/core/presentation/mixin/filter_bar_animation_mixin.dart';
import 'package:withme/core/presentation/widget/size_transition_filter_bar.dart';
import 'package:withme/core/ui/const/fab_position.dart';
import 'package:withme/presentation/customer/screen/customer_screen.dart';

import '../../../../../core/di/setup.dart';
import '../../../../core/data/fire_base/user_session.dart';
import '../../../../core/domain/enum/history_content.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/fab/fab_overlay_manager_mixin.dart';
import '../../../../core/presentation/widget/inactive_and_urgent_filter_bar.dart';
import '../../../../core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import '../../../../domain/domain_import.dart';
import '../../../../domain/model/history_model.dart';
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

  String _searchText = '';
  bool _showInactiveOnly = false;
  bool _autoFilterHandled = false; // 최초 1회 자동 열림/닫힘 제어

  @override
  void initState() {
    super.initState();
    smallFabBottomPosition = FabPosition.bottomFabBottomHeight;
    initFilterBarAnimation(vsync: this);
    viewModel.fetchData(force: true);
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
    disposeFilterBarAnimation();
    super.dispose();
  }

  void _toggleFilterBar() => toggleFilterBarAnimation();

  @override
  Future<void> onMainFabPressedLogic(CustomerListViewModel viewModel) async {
    debugPrint('Main FAB pressed - no action for CustomerListPage');
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
    final colorScheme = Theme.of(context).colorScheme;

    return VisibilityDetector(
      key: const Key('customer-list-visibility'),
      onVisibilityChanged: handleVisibilityChange,
      child: SafeArea(
        child: StreamBuilder<List<CustomerModel>>(
          stream: viewModel.cachedCustomers,
          builder: (context, snapshot) {
            final customers = snapshot.data ?? [];

            // 최초 1회 자동 필터바 열림/닫힘
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_autoFilterHandled && mounted) {
                final hasFilterItems = viewModel.managePeriodCount > 0 || viewModel.todoCount > 0;
                setFilterBarExpanded(hasFilterItems);
                _autoFilterHandled = true;
              }
            });

            return Scaffold(
              backgroundColor: colorScheme.surface,
              appBar: CustomerListAppBar(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                count: customers.length,
                onSearch: (text) => setState(() => _searchText = text),
                filterBarExpanded: filterBarExpanded,
                onToggleFilterBar: _toggleFilterBar,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizeTransition(
                    sizeFactor: heightFactor,
                    axisAlignment: -1.0,
                    child: InactiveAndUrgentFilterBar(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurfaceVariant,
                      showInactiveOnly: _showInactiveOnly,
                      inactiveCount: viewModel.managePeriodCount,
                      showTodoOnly: viewModel.showTodoOnly,
                      todoCount: viewModel.todoCount,
                      onInactiveToggle: (val) {
                        setState(() => _showInactiveOnly = val);
                        viewModel.updateFilter(inactiveOnly: val);
                      },
                      onTodoToggle: (val) => viewModel.updateShowTodoOnly(val),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: _CustomerListView(
                      customers: customers
                          .where((e) => e.policies.isNotEmpty)
                          .where((e) => _searchText.isEmpty || e.name.contains(_searchText.trim()))
                          .toList(),
                      viewModel: viewModel,
                      setFabCanBeShown: setFabCanBeShown,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CustomerListView extends StatelessWidget {
  final List<CustomerModel> customers;
  final CustomerListViewModel viewModel;
  final void Function(bool) setFabCanBeShown;

  const _CustomerListView({
    required this.customers,
    required this.viewModel,
    required this.setFabCanBeShown,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () => _openCustomerSheet(context, customer),
            child: CustomerItem(
              customer: customer,
              onTap: (histories) => _addHistory(context, customer, histories),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCustomerSheet(BuildContext context, CustomerModel customer) async {
    setFabCanBeShown(false);

    await showBottomSheetWithDraggable(
      context: context,
      builder: (scrollController) => CustomerScreen(customer: customer),
      backgroundColor: Theme.of(context).colorScheme.surface,
      onClosed: () async {
        await viewModel.fetchData(force: true);
        await Future.delayed(const Duration(milliseconds: 200));
        setFabCanBeShown(true);
      },
    );
  }

  Future<void> _addHistory(BuildContext context, CustomerModel customer, List<HistoryModel> histories) async {
    setFabCanBeShown(false);

    final newHistory = await popupAddHistory(
      context: context,
      histories: histories,
      customer: customer,
      initContent: HistoryContent.title.toString(),
    );

    setFabCanBeShown(true);

    if (newHistory != null) {
      final updatedCustomer = customer.copyWith(
        histories: [...customer.histories, newHistory],
      );
      viewModel.updateCustomerInList(updatedCustomer);
    }
  }
}

//
// class CustomerListPage extends StatefulWidget {
//   const CustomerListPage({super.key});
//
//   @override
//   State<CustomerListPage> createState() => _CustomerListPageState();
// }
//
// class _CustomerListPageState extends State<CustomerListPage>
//     with
//         RouteAware,
//         FabOverlayManagerMixin<CustomerListPage, CustomerListViewModel>,
//         SingleTickerProviderStateMixin,
//         FilterBarAnimationMixin {
//   final RouteObserver<PageRoute> _routeObserver =
//       getIt<RouteObserver<PageRoute>>();
//   @override
//   final CustomerListViewModel viewModel = getIt<CustomerListViewModel>();
//
//   String _searchText = '';
//   bool _showInactiveOnly = false;
//
//   void _toggleFilterBar() => toggleFilterBarAnimation();
//
//   @override
//   void initState() {
//     super.initState();
//     smallFabBottomPosition = FabPosition.bottomFabBottomHeight;
//     viewModel.fetchData(force: true);
//     initFilterBarAnimation(vsync: this);
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final route = ModalRoute.of(context);
//     if (route is PageRoute) _routeObserver.subscribe(this, route);
//   }
//
//   @override
//   void dispose() {
//     _routeObserver.unsubscribe(this);
//     super.dispose();
//   }
//
//   @override
//   Future<void> onMainFabPressedLogic(CustomerListViewModel viewModel) async {
//     debugPrint('Main FAB pressed - no action on CustomerListPage');
//   }
//
//   @override
//   void onSortActionLogic(Function() sortFn) {
//     sortFn();
//     callOverlaySetState();
//   }
//
//   @override
//   Widget buildMainFab() => const SizedBox.shrink();
//
//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return VisibilityDetector(
//       key: const Key('customer-list-visibility'),
//       onVisibilityChanged: handleVisibilityChange,
//       child: SafeArea(
//         child: AnimatedBuilder(
//           animation: viewModel,
//           builder:
//               (context, _) => StreamBuilder<List<CustomerModel>>(
//                 stream: viewModel.cachedCustomers,
//                 builder: (context, snapshot) {
//                   final data = snapshot.data ?? [];
//                   var filtered =
//                       data.where((e) => e.policies.isNotEmpty).toList();
//
//                   if (_searchText.isNotEmpty) {
//                     filtered =
//                         filtered
//                             .where((e) => e.name.contains(_searchText.trim()))
//                             .toList();
//                   }
//
//                   if (_showInactiveOnly) {
//                     final managePeriodDays =
//                         getIt<UserSession>().managePeriodDays;
//                     final now = DateTime.now();
//                     filtered =
//                         filtered.where((e) {
//                           final latest = e.histories
//                               .map((h) => h.contactDate)
//                               .fold<DateTime?>(
//                                 null,
//                                 (prev, date) =>
//                                     prev == null || date.isAfter(prev)
//                                         ? date
//                                         : prev,
//                               );
//                           return latest == null ||
//                               latest
//                                   .add(Duration(days: managePeriodDays))
//                                   .isBefore(now);
//                         }).toList();
//                   }
//
//                   return Scaffold(
//                     backgroundColor: colorScheme.surface,
//                     appBar: CustomerListAppBar(
//                       backgroundColor: colorScheme.surface,
//                       // AppBar 색상
//                       foregroundColor: colorScheme.onSurface,
//                       // 텍스트/아이콘 색상
//                       count: filtered.length,
//                       onSearch: (text) => setState(() => _searchText = text),
//                       filterBarExpanded: filterBarExpanded,
//                       onToggleFilterBar: _toggleFilterBar,
//                     ),
//                     body: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizeTransitionFilterBar(
//                           heightFactor: heightFactor,
//                           child: InactiveAndUrgentFilterBar(
//                             backgroundColor: colorScheme.surfaceContainerHighest,
//                             iconColor: colorScheme.primary,
//                             textColor: colorScheme.onSurfaceVariant,
//                             showInactiveOnly: _showInactiveOnly,
//                             onInactiveToggle:
//                                 (val) =>
//                                     setState(() => _showInactiveOnly = val),
//                             inactiveCount: viewModel.managePeriodCount,
//                             showTodoOnly: viewModel.showTodoOnly,
//                             onTodoToggle:
//                                 (val) => viewModel.updateShowTodoOnly(val),
//                             todoCount: viewModel.todoCount,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Expanded(
//                           child: _CustomerListView(
//                             customers: filtered,
//                             onTap: (customer) async {
//                               setIsProcessActive(true);
//                               setFabCanBeShown(false);
//
//                               await showBottomSheetWithDraggable(
//                                 context: context,
//                                 builder:
//                                     (scrollController) =>
//                                         CustomerScreen(customer: customer),
//                                 backgroundColor:
//                                     Theme.of(
//                                       context,
//                                     ).colorScheme.surface, // 바텀시트 배경 적용
//                                 onClosed: () async {
//                                   setIsProcessActive(false);
//                                   await viewModel.fetchData(force: true);
//                                   await Future.delayed(
//                                     const Duration(milliseconds: 200),
//                                   );
//                                   if (!mounted) return;
//                                   setFabCanBeShown(true);
//                                 },
//                               );
//                             },
//                             viewModel: viewModel,
//                             setFabCanBeShown: setFabCanBeShown,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//         ),
//       ),
//     );
//   }
// }
//
// class _CustomerListView extends StatelessWidget {
//   final List<CustomerModel> customers;
//   final void Function(CustomerModel) onTap;
//   final CustomerListViewModel viewModel;
//   final void Function(bool) setFabCanBeShown; // FAB 제어 콜백
//
//   const _CustomerListView({
//     required this.customers,
//     required this.onTap,
//     required this.viewModel,
//     required this.setFabCanBeShown,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       itemCount: customers.length,
//       itemBuilder: (context, index) {
//         final customer = customers[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: GestureDetector(
//             onTap: () => onTap(customer),
//             child: CustomerItem(
//               customer: customer,
//               onTap: (histories) async {
//                 // FAB 숨기기
//                 setFabCanBeShown(false);
//
//                 final newHistory = await popupAddHistory(
//                   context: context,
//                   histories: customer.histories,
//                   customer: customer,
//                   initContent: HistoryContent.title.toString(),
//                 );
//
//                 // FAB 다시 표시
//                 setFabCanBeShown(true);
//
//                 if (newHistory != null) {
//                   final updatedHistories = [...customer.histories, newHistory];
//                   final updatedCustomer = customer.copyWith(
//                     histories: updatedHistories,
//                   );
//                   viewModel.updateCustomerInList(updatedCustomer);
//                 }
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
