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
import '../../../../core/presentation/components/temporary/text_theme_font_size_pop_up.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../registration_sheet/sheet/registration_bottom_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    _initPopup();
    initFilterBarAnimation(vsync: this);
  }

  void _initPopup() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_hasCheckedAgreement) return;
      _hasCheckedAgreement = true;

      final userSession = getIt<UserSession>();
      await userSession.loadAgreementCheckFromPrefs();

      final managePeriod = userSession.managePeriodDays;
      final urgentThreshold = userSession.urgentThresholdDays;
      final targetCount = userSession.targetProspectCount;

      if (userSession.isFirstLogin && mounted) {
        await showConfirmDialog(
          context,
          textSpans: [
            TextSpan(
              text: '= 현재 설정 =\n\n',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: '고객 관리주기: $managePeriod 일\n',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            TextSpan(
              text: '상령일 알림: $urgentThreshold 일\n',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: '목표 고객수: $targetCount 명\n\n',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            TextSpan(
              text: '[변경] DashBoard 우측상단 ⚙️',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
          onConfirm: () async {
            await userSession.markAgreementSeen();
            if (mounted) {
              Navigator.of(context).maybePop();
            }
          },
          cancelButtonText: '',
        );
      }
    });
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

  void _toggleFilterBar() => toggleFilterBarAnimation();

  @override
  void onSortActionLogic(Function() sortFn) {
    sortFn();
    callOverlaySetState();
  }

  /// ★ 필수 구현: FabOverlayManagerMixin 추상 메서드 구현 ★
  @override
  Future<void> onMainFabPressedLogic(ProspectListViewModel viewModel) async {
    if (!mounted) return;

    final isLimited = await FreeLimitDialog.checkAndShow(
      context: context,
      viewModel: viewModel,
    );
    if (isLimited) return;

    setIsProcessActive(true);
    setFabCanBeShown(false);

    await showBottomSheetWithDraggable(
      context: context,
      builder:
          (scrollController) => RegistrationBottomSheet(
            scrollController: scrollController,
            outerContext: context,
          ),
      onClosed: () async {
        setIsProcessActive(false);
        await viewModel.fetchData(force: true);

        if (!mounted) return;
        setFabCanBeShown(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return VisibilityDetector(
      key: const Key('prospect-list-visibility'),
      onVisibilityChanged: handleVisibilityChange,
      child: SafeArea(
        child: StreamBuilder<List<CustomerModel>>(
          stream: viewModel.cachedProspects,
          builder: (context, snapshot) {
            final filteredList = snapshot.data ?? [];

            return Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: ProspectListAppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                viewModel: viewModel,
                customers: filteredList,
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
                      showUrgentOnly: _showUrgentOnly,
                      onInactiveToggle: (val) {
                        setState(() => _showInactiveOnly = val);
                        viewModel.updateFilter(inactiveOnly: val);
                      },
                      onUrgentToggle: (val) {
                        setState(() => _showUrgentOnly = val);
                        viewModel.updateFilter(urgentOnly: val);
                      },
                      inactiveCount: viewModel.inactiveCount,
                      urgentCount: viewModel.urgentCount,
                      showTodoOnly: _showTodoOnly,
                      onTodoToggle: (val) {
                        setState(() => _showTodoOnly = val);
                        viewModel.updateFilter(todoOnly: val);
                      },
                      todoCount: viewModel.todoCount,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final customer = filteredList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () async {
                              setIsProcessActive(true);
                              setFabCanBeShown(false);

                              await showBottomSheetWithDraggable(
                                context: context,
                                builder:
                                    (scrollController) =>
                                        RegistrationBottomSheet(
                                          customer: customer,
                                          scrollController: scrollController,
                                          outerContext: context,
                                        ),
                                onClosed: () async {
                                  setIsProcessActive(false);
                                  await viewModel.fetchData(force: true);
                                  await Future.delayed(
                                    const Duration(milliseconds: 200),
                                  );
                                  if (!mounted) return;
                                  setFabCanBeShown(true);
                                },
                              );
                            },
                            child: ProspectItem(
                              userKey: UserSession.userId,
                              customer: customer,
                              onTap: (histories) async {
                                setFabCanBeShown(false);
                                await popupAddHistory(
                                  context: context,
                                  histories: histories,
                                  customer: customer,
                                  initContent: HistoryContent.title.toString(),
                                );
                                if (mounted) setFabCanBeShown(true);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) =>
                            TextThemeFontSizePopup(textTheme: textTheme),
                  );
                },
                child: const Text('FontSize 보기'),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
            );
          },
        ),
      ),
    );
  }
}
