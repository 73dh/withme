import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/fab/fab_overlay_manager_mixin.dart';
import 'package:withme/core/presentation/mixin/filter_bar_animation_mixin.dart';
import 'package:withme/core/presentation/widget/inactive_and_urgent_filter_bar.dart';
import 'package:withme/core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import 'package:withme/core/presentation/widget/size_transition_filter_bar.dart';
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
  bool _hasCheckedAgreement = false;
  bool _autoFilterHandled = false; // 👈 자동 제어는 최초 1회만 반영

  @override
  void initState() {
    super.initState();
    initFilterBarAnimation(vsync: this);
    _maybeShowAgreementPopup();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      _routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    disposeFilterBarAnimation();
    super.dispose();
  }

  Future<void> _maybeShowAgreementPopup() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_hasCheckedAgreement) return;
      _hasCheckedAgreement = true;

      final userSession = getIt<UserSession>();
      await userSession.loadAgreementCheckFromPrefs();

      if (userSession.isFirstLogin && mounted) {
        await _showAgreementDialog(userSession);
      }
    });
  }

  Future<void> _showAgreementDialog(UserSession userSession) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return showConfirmDialog(
      context,
      textSpans: [
        TextSpan(
          text: '= 현재 설정 =\n\n',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        _settingsText(
          '고객 관리주기',
          '${userSession.managePeriodDays}일',
          textTheme,
          colorScheme,
        ),
        _settingsText(
          '상령일 알림',
          '${userSession.urgentThresholdDays}일',
          textTheme,
          colorScheme,
        ),
        _settingsText(
          '목표 고객수',
          '${userSession.targetProspectCount}명',
          textTheme,
          colorScheme,
          highlight: true,
        ),
        TextSpan(text: '\n'),
        TextSpan(
          text: '[변경] DashBoard 우측상단 ⚙️',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
      onConfirm: () async {
        await userSession.markAgreementSeen();
        if (mounted) Navigator.of(context).maybePop();
      },
      cancelButtonText: '',
    );
  }

  TextSpan _settingsText(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    bool highlight = false,
  }) {
    return TextSpan(
      text: '$label: $value\n',
      style: textTheme.bodyLarge?.copyWith(
        color: highlight ? colorScheme.secondary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _toggleFilterBar() {
    final newValue = !viewModel.isFilterBarExpanded;
    setFilterBarExpanded(newValue);
  }

  @override
  void setFilterBarExpanded(bool expanded) {
    if (expanded) {
      filterBarController.forward();
    } else {
      filterBarController.reverse();
    }
    viewModel.setFilterBarExpanded(expanded); // 🔗 ViewModel과 동기화
  }

  @override
  void onSortActionLogic(Function() sortFn) {
    sortFn();
    callOverlaySetState();
  }

  @override
  Future<void> onMainFabPressedLogic(ProspectListViewModel viewModel) async {
    if (!mounted) return;
    final isLimited = await FreeLimitDialog.checkAndShow(
      context: context,
      viewModel: viewModel,
    );
    if (isLimited) return;

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

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: _buildAppBar(customers),
              body: Column(
                children: [
                  _buildFilterBar(),
                  const SizedBox(height: 5),
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
      filterBarExpanded: viewModel.isFilterBarExpanded,
      // 🔗 VM 상태 참조,
      onToggleFilterBar: _toggleFilterBar,
    );
  }

  Widget _buildFilterBar() {
    return StreamBuilder<List<CustomerModel>>(
      stream: viewModel.cachedProspects,
      builder: (context, snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final hasFilterItems =
              viewModel.todoCount > 0 || viewModel.managePeriodCount > 0;

          if (!_autoFilterHandled) {
            // 최초 진입 시 자동 열림/닫힘
            setFilterBarExpanded(hasFilterItems);
            _autoFilterHandled = true;
          } else {
            // 👇 수동 토글된 경우는 자동 닫기 로직 무시
            if (!viewModel.isFilterBarToggledManually) {
              if (!hasFilterItems && viewModel.isFilterBarExpanded) {
                viewModel.setFilterBarExpanded(false);
              }
            }
          }
        });

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
              viewModel.setFilterBarExpanded(
                true,
                manual: true,
              ); // 👈 수동 토글 시 강제 유지
            },
            onUrgentToggle: (val) {
              setState(() => _showUrgentOnly = val);
              viewModel.updateFilter(urgentOnly: val);
              viewModel.setFilterBarExpanded(true, manual: true); // 👈 닫히지 않게
            },
            onTodoToggle: (val) {
              setState(() => _showTodoOnly = val);
              viewModel.updateFilter(todoOnly: val);
              viewModel.setFilterBarExpanded(true, manual: true); // 👈 닫히지 않게
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
