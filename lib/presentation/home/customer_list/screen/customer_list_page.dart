import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/presentation/mixin/filter_bar_animation_mixin.dart';
import 'package:withme/core/ui/const/fab_position.dart';
import 'package:withme/domain/model/customer_model.dart';

import '../../../../../core/di/setup.dart';
import '../../../../core/domain/enum/history_content.dart';
import '../../../../core/presentation/components/customer_item.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/fab/fab_overlay_manager_mixin.dart';
import '../../../../core/presentation/widget/inactive_and_urgent_filter_bar.dart';
import '../../../../core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import '../../../../domain/domain_import.dart';
import '../../../../domain/model/history_model.dart';
import '../../../customer/screen/customer_screen.dart';
import '../components/customer_list_app_bar.dart';
import '../customer_list_view_model.dart';

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
  bool _autoFilterHandled = false;

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

  void _toggleFilterBar() {
    viewModel.toggleFilterBar();
    toggleFilterBarAnimation();
  }

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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _checkFilterBarAutoClose(); // 카운트 변화 감지 후 체크
            });

            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   if (!_autoFilterHandled && mounted) {
            //     final hasFilterItems =
            //         viewModel.managePeriodCount > 0 || viewModel.todoCount > 0;
            //     setFilterBarExpanded(hasFilterItems);
            //     _autoFilterHandled = true;
            //   }
            // });

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
                      backgroundColor: colorScheme.surface,
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurfaceVariant,
                      showInactiveOnly: viewModel.showInactiveOnly,
                      inactiveCount: viewModel.managePeriodCount,
                      showTodoOnly: viewModel.showTodoOnly,
                      todoCount: viewModel.todoCount,
                      showUrgentOnly: viewModel.showInsuranceAgeUrgentOnly,
                      urgentCount: viewModel.insuranceAgeUrgentCount,
                      onInactiveToggle:
                          (val) => viewModel.updateFilter(inactiveOnly: val),
                      onTodoToggle: (val) => viewModel.updateShowTodoOnly(val),
                      onUrgentToggle:
                          (val) => viewModel.updateFilter(
                            insuranceAgeUrgentOnly: val,
                          ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: _CustomerListView(
                      customers:
                          customers
                              .where((e) => e.policies.isNotEmpty)
                              .where(
                                (e) =>
                                    _searchText.isEmpty ||
                                    e.name.contains(_searchText.trim()),
                              )
                              .toList(),
                      viewModel: viewModel,
                      setFabCanBeShown: setFabCanBeShown,
                      setIsModalOpen: setIsModalOpen,
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

  void _checkFilterBarAutoClose() {
    final hasFilterItems =
        viewModel.managePeriodCount > 0 ||
            viewModel.todoCount > 0 ||
            viewModel.insuranceAgeUrgentCount > 0;

    if (!viewModel.isFilterBarToggledManually) {
      // 수동 토글 안 된 경우 → 자동 열기/닫기
      viewModel.setFilterBarExpanded(hasFilterItems);
    }

    // 수동 토글 되었더라도 모든 값 0이면 닫기 + 수동 플래그 초기화
    if (viewModel.isFilterBarToggledManually && !hasFilterItems) {
      viewModel.isFilterBarToggledManually = false; // ← 추가
      viewModel.setFilterBarExpanded(false);
    }
  }

}

class _CustomerListView extends StatelessWidget {
  final List<CustomerModel> customers;
  final CustomerListViewModel viewModel;
  final void Function(bool) setFabCanBeShown;
  final void Function(bool) setIsModalOpen;

  const _CustomerListView({
    required this.customers,
    required this.viewModel,
    required this.setFabCanBeShown,
    required this.setIsModalOpen,
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

  Future<void> _openCustomerSheet(
    BuildContext context,
    CustomerModel customer,
  ) async {
    setFabCanBeShown(false);
    setIsModalOpen(true);

    await showBottomSheetWithDraggable(
      context: context,
      builder: (_) => CustomerScreen(customer: customer),
      onClosed: () {
        viewModel.fetchData(force: true);
        setIsModalOpen(false);
        setFabCanBeShown(true);
      },
    );
  }

  Future<void> _addHistory(
    BuildContext context,
    CustomerModel customer,
    List<HistoryModel> histories,
  ) async {
    setFabCanBeShown(false);
    setIsModalOpen(true);

    final newHistory = await popupAddHistory(
      context: context,
      histories: histories,
      customer: customer,
      initContent: HistoryContent.title.toString(),
    );

    setIsModalOpen(false);
    setFabCanBeShown(true);

    if (newHistory != null) {
      final updatedCustomer = customer.copyWith(
        histories: [...customer.histories, newHistory],
      );
      viewModel.updateCustomerInList(updatedCustomer);
    }
  }
}
