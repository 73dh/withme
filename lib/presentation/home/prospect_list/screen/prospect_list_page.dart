import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/fab/fab_overlay_manager_mixin.dart';
import 'package:withme/core/presentation/mixin/filter_bar_animation_mixin.dart';
import 'package:withme/core/presentation/widget/inactive_and_urgent_filter_bar.dart';
import 'package:withme/core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/prospect_list/components/prospect_list_app_bar.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/todo/todo_view_model.dart';
import '../../../registration/screen/registration_screen.dart';

class ProspectListPage extends StatefulWidget {
  const ProspectListPage({super.key});

  @override
  State<ProspectListPage> createState() => _ProspectListPageState();
}

class _ProspectListPageState extends State<ProspectListPage>
    with
        RouteAware,
        FabOverlayManagerMixin<ProspectListPage, ProspectListViewModel>,
        SingleTickerProviderStateMixin,
        FilterBarAnimationMixin {
  final RouteObserver<PageRoute> _routeObserver =
      getIt<RouteObserver<PageRoute>>();
  @override
  final viewModel = getIt<ProspectListViewModel>();

  bool _showTodoOnly = false;
  bool _showInactiveOnly = false;
  bool _showUrgentOnly = false;
  bool _firstEnter = true;

  @override
  void initState() {
    super.initState();
    initFilterBarAnimation(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) _routeObserver.subscribe(this, modalRoute);
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    disposeFilterBarAnimation();
    super.dispose();
  }

  void _toggleFilterBar() {
    setFilterBarExpanded(!viewModel.isFilterBarExpanded, manual: true);
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
  void onSortActionLogic(Function() sortFn) {
    sortFn();
    callOverlaySetState();
  }

  @override
  Future<void> onMainFabPressedLogic(ProspectListViewModel viewModel) async {
    if (!mounted) return;
    await _openRegistrationSheet();
  }

  Future<void> _openRegistrationSheet({CustomerModel? customer}) async {
    setIsProcessActive(true);
    setFabCanBeShown(false);
    final todoViewModel = TodoViewModel(
      userKey: UserSession.userId,
      customerKey:
          customer?.customerKey ??
          'new_${DateTime.now().millisecondsSinceEpoch}',
    );
    await showBottomSheetWithDraggable(
      context: context,
      builder:
          (scrollController) => RegistrationScreen(
            customer: customer,
            scrollController: scrollController,
            todoViewModel: todoViewModel,
          ),
      onClosed: () async {
        setIsProcessActive(false);
        await viewModel.fetchData(force: true);
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 200));
        setFabCanBeShown(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return VisibilityDetector(
      key: const Key('prospect-list-visibility'),
      onVisibilityChanged: handleVisibilityChange,
      child: SafeArea(
        child: StreamBuilder<List<CustomerModel>>(
          stream: viewModel.cachedProspects,
          builder: (context, snapshot) {
            final customers = snapshot.data ?? [];

            // 최초 진입 시 자동 필터 적용
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              if (_firstEnter) {
                if (viewModel.shouldAutoExpandFilterBar()) {
                  setFilterBarExpanded(true);
                }
                _firstEnter = false;
                return;
              }

              // 이후 rebuild 시 AnimationController 동기화
              if (viewModel.isFilterBarExpanded) {
                filterBarController.forward();
              } else {
                filterBarController.reverse();
              }
            });

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: _buildAppBar(customers),
              body: Column(
                children: [
                  _buildFilterBar(),
                height(5),
                  Expanded(child: _buildProspectList(customers)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(List<CustomerModel> customers) {
    return ProspectListAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      viewModel: viewModel,
      customers: customers,
      onToggleFilterBar: _toggleFilterBar,
    );
  }

  Widget _buildFilterBar() {
    return StreamBuilder<List<CustomerModel>>(
      stream: viewModel.cachedProspects,
      builder: (context, snapshot) {
        return SizeTransition(
          sizeFactor: heightFactor,
          axisAlignment: -1.0,
          child: InactiveAndUrgentFilterBar(
            showInactiveOnly: _showInactiveOnly,
            showUrgentOnly: _showUrgentOnly,
            showTodoOnly: _showTodoOnly,
            inactiveCount: viewModel.managePeriodCount,
            urgentCount: viewModel.urgentCount,
            todoCount: viewModel.todoCount,
            onInactiveToggle: (val) {
              setState(() => _showInactiveOnly = val);
              viewModel.updateFilter(inactiveOnly: val);
              setFilterBarExpanded(true, manual: true);
            },
            onUrgentToggle: (val) {
              setState(() => _showUrgentOnly = val);
              viewModel.updateFilter(urgentOnly: val);
              setFilterBarExpanded(true, manual: true);
            },
            onTodoToggle: (val) {
              setState(() => _showTodoOnly = val);
              viewModel.updateFilter(todoOnly: val);
              setFilterBarExpanded(true, manual: true);
            },
          ),
        );
      },
    );
  }

  Widget _buildProspectList(List<CustomerModel> customers) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: GestureDetector(
            onTap: () => _openRegistrationSheet(customer: customer),
            child: ProspectItem(
              userKey: UserSession.userId,
              customer: customer,
              onTap: (histories) async {
                setFabCanBeShown(false);
                final newHistory = await popupAddHistory(
                  context: context,
                  histories: histories,
                  customer: customer,
                  initContent: HistoryContent.title.toString(),
                );
                if (newHistory != null) {
                  viewModel.addHistoryForCustomer(newHistory, customer);
                }
                if (mounted) setFabCanBeShown(true);
              },
            ),
          ),
        );
      },
    );
  }
}
