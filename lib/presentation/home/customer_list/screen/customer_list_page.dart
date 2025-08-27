// customer_list_page.dart
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/presentation/mixin/filter_bar_animation_mixin.dart';
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
  bool _showTodoOnly = false;
  bool _showInactiveOnly = false;
  bool _showUrgentOnly = false;

  @override
  void initState() {
    super.initState();
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
    final newValue = !viewModel.isFilterBarExpanded;
    setFilterBarExpanded(newValue, manual: true);
  }

  @override
  void setFilterBarExpanded(bool expanded, {bool manual = false}) {
    if (expanded) {
      filterBarController.forward();
    } else {
      filterBarController.reverse();
    }

    viewModel.setFilterBarExpanded(expanded, manual: manual);
  }

  @override
  Future<void> onMainFabPressedLogic(CustomerListViewModel viewModel) async {}

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

            // animation sync
            if (viewModel.isFilterBarExpanded) {
              filterBarController.forward();
            } else {
              filterBarController.reverse();
            }

            return Scaffold(
              backgroundColor: colorScheme.surface,
              appBar: CustomerListAppBar(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                count: customers.length,
                onSearch: (text) => setState(() => _searchText = text),
                viewModel: viewModel,
                onToggleFilterBar: _toggleFilterBar,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterBar(),
                  height(5),
                  Expanded(
                    child: _CustomerListView(
                      customers:
                          customers
                              .where(
                                (c) =>
                                    _searchText.isEmpty ||
                                    c.name.contains(_searchText.trim()),
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

  Widget _buildFilterBar() {
    return SizeTransition(
      sizeFactor: heightFactor,
      axisAlignment: -1.0,
      child: InactiveAndUrgentFilterBar(
        showInactiveOnly: _showInactiveOnly,
        showTodoOnly: _showTodoOnly,
        showUrgentOnly: _showUrgentOnly,
        inactiveCount: viewModel.managePeriodCount,
        todoCount: viewModel.todoCount,
        urgentCount: viewModel.insuranceAgeUrgentCount,
        onInactiveToggle: (val) {
          setState(() => _showInactiveOnly = val);
          viewModel.updateFilter(inactiveOnly: val);
          setFilterBarExpanded(true, manual: true);
        },
        onTodoToggle: (val) {
          setState(() => _showTodoOnly = val);
          viewModel.updateShowTodoOnly(val);
          setFilterBarExpanded(true, manual: true);
        },
        onUrgentToggle: (val) {
          setState(() => _showUrgentOnly = val);
          viewModel.updateFilter(insuranceAgeUrgentOnly: val);
          setFilterBarExpanded(true, manual: true);
        },
      ),
    );
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
