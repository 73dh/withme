import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/fab/fab_overlay_manager_mixin.dart';
import 'package:withme/core/presentation/mixin/filter_bar_animation_mixin.dart';
import 'package:withme/core/presentation/todo/common_todo_list.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';
import 'package:withme/core/presentation/widget/inactive_and_urgent_filter_bar.dart';
import 'package:withme/core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import 'package:withme/core/presentation/widget/size_transition_filter_bar.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/prospect_list/components/prospect_list_app_bar.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/theme/theme_controller.dart';
import '../../../registration_sheet/sheet/registration_bottom_sheet.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/fab/fab_overlay_manager_mixin.dart';
import 'package:withme/core/presentation/mixin/filter_bar_animation_mixin.dart';
import 'package:withme/core/presentation/todo/common_todo_list.dart';
import 'package:withme/core/presentation/todo/todo_view_model.dart';
import 'package:withme/core/presentation/widget/inactive_and_urgent_filter_bar.dart';
import 'package:withme/core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import 'package:withme/core/presentation/widget/size_transition_filter_bar.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/prospect_list/components/prospect_list_app_bar.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/theme/theme_controller.dart';
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
          text:
          '== 현재 설정 ==\n\n'
              '고객 관리주기: $managePeriod 일\n'
              '상령일 알림: $urgentThreshold 일\n'
              '목표 고객수: $targetCount 명\n'
              'DashBoard 설정⚙️ 에서 수정 가능합니다.',
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
      builder: (scrollController) => RegistrationBottomSheet(
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
              backgroundColor: colorScheme.surface, // 테마 기반 배경
              appBar: ProspectListAppBar(
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
                  height(5),
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
                                builder: (scrollController) =>
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
                                  initContent:
                                  HistoryContent.title.toString(),
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
              floatingActionButton: AnimatedBuilder(
                animation: themeController,
                builder: (context, _) {
                  final isLight =
                      themeController.flutterThemeMode == ThemeMode.light;

                  return FloatingActionButton(
                    onPressed: themeController.toggleTheme,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isLight ? Icons.dark_mode : Icons.light_mode,
                    ),
                  );
                },
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

//
// class ProspectListPage extends StatefulWidget {
//   const ProspectListPage({super.key});
//
//   @override
//   State<ProspectListPage> createState() => _ProspectListPageState();
// }
//
// class _ProspectListPageState extends State<ProspectListPage>
//     with
//         RouteAware,
//         FabOverlayManagerMixin<ProspectListPage, ProspectListViewModel>,
//         SingleTickerProviderStateMixin,
//         FilterBarAnimationMixin {
//   final RouteObserver<PageRoute> _routeObserver =
//       getIt<RouteObserver<PageRoute>>();
//
//   @override
//   final viewModel = getIt<ProspectListViewModel>();
//
//   bool _showTodoOnly = false;
//   bool _showInactiveOnly = false;
//   bool _showUrgentOnly = false;
//   bool _hasCheckedAgreement = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initPopup();
//     initFilterBarAnimation(vsync: this);
//   }
//
//   void _initPopup() {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (_hasCheckedAgreement) return;
//       _hasCheckedAgreement = true;
//
//       final userSession = getIt<UserSession>();
//       await userSession.loadAgreementCheckFromPrefs();
//
//       final managePeriod = userSession.managePeriodDays;
//       final urgentThreshold = userSession.urgentThresholdDays;
//       final targetCount = userSession.targetProspectCount;
//
//       if (userSession.isFirstLogin && mounted) {
//         await showConfirmDialog(
//           context,
//           text:
//               '현재 설정\n\n'
//               '고객 관리주기: $managePeriod일\n'
//               '상령일 알림: $urgentThreshold일\n'
//               '목표 고객수: $targetCount명\n\n'
//               '설정⚙️ 에서 수정 가능합니다.',
//           onConfirm: () async {
//             await userSession.markAgreementSeen();
//             if (mounted) {
//               Navigator.of(context).maybePop();
//             }
//           },
//           cancelButtonText: '',
//         );
//       }
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final modalRoute = ModalRoute.of(context);
//     if (modalRoute is PageRoute) {
//       _routeObserver.subscribe(this, modalRoute);
//     }
//   }
//
//   @override
//   void dispose() {
//     _routeObserver.unsubscribe(this);
//     disposeFilterBarAnimation();
//     super.dispose();
//   }
//
//   void _toggleFilterBar() => toggleFilterBarAnimation();
//
//   @override
//   void onSortActionLogic(Function() sortFn) {
//     sortFn();
//     callOverlaySetState();
//   }
//
//   /// ★ 필수 구현: FabOverlayManagerMixin 추상 메서드 구현 ★
//   @override
//   Future<void> onMainFabPressedLogic(ProspectListViewModel viewModel) async {
//     if (!mounted) return;
//
//     // 무료 사용량 제한 확인 및 다이얼로그 표시 예시 (필요시 수정)
//     final isLimited = await FreeLimitDialog.checkAndShow(
//       context: context,
//       viewModel: viewModel,
//     );
//     if (isLimited) return;
//
//     setIsProcessActive(true);
//     setFabCanBeShown(false);
//
//     await showBottomSheetWithDraggable(
//       context: context,
//       builder:
//           (scrollController) => RegistrationBottomSheet(
//             scrollController: scrollController,
//             // customerModel: null, // 새 등록이라면 필요시 전달
//             outerContext: context,
//           ),
//       onClosed: () async {
//         setIsProcessActive(false);
//         await viewModel.fetchData(force: true);
//
//         if (!mounted) return;
//         setFabCanBeShown(true);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return VisibilityDetector(
//       key: const Key('prospect-list-visibility'),
//       onVisibilityChanged: handleVisibilityChange,
//       child: SafeArea(
//         child: StreamBuilder<List<CustomerModel>>(
//           stream: viewModel.cachedProspects,
//           builder: (context, snapshot) {
//             final filteredList = snapshot.data ?? [];
//             return Scaffold(
//               resizeToAvoidBottomInset: true,
//               backgroundColor: Colors.transparent,
//               appBar: ProspectListAppBar(
//                 viewModel: viewModel,
//                 customers: filteredList,
//                 filterBarExpanded: filterBarExpanded,
//                 onToggleFilterBar: _toggleFilterBar,
//               ),
//               body: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizeTransitionFilterBar(
//                     heightFactor: heightFactor,
//                     child: InactiveAndUrgentFilterBar(
//                       showInactiveOnly: _showInactiveOnly,
//                       showUrgentOnly: _showUrgentOnly,
//                       onInactiveToggle: (val) {
//                         setState(() => _showInactiveOnly = val);
//                         viewModel.updateFilter(inactiveOnly: val);
//                       },
//                       onUrgentToggle: (val) {
//                         setState(() => _showUrgentOnly = val);
//                         viewModel.updateFilter(urgentOnly: val);
//                       },
//                       inactiveCount: viewModel.inactiveCount,
//                       urgentCount: viewModel.urgentCount,
//                       showTodoOnly: _showTodoOnly,
//                       onTodoToggle: (val) {
//                         setState(() => _showTodoOnly = val);
//                         viewModel.updateFilter(todoOnly: val);
//                       },
//                       todoCount: viewModel.todoCount,
//                     ),
//                   ),
//                   height(5),
//                   Expanded(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       itemCount: filteredList.length,
//                       itemBuilder: (context, index) {
//                         final customer = filteredList[index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: GestureDetector(
//                             onTap: () async {
//                               setIsProcessActive(true);  // 추가
//                               setFabCanBeShown(false);
//
//                               await showBottomSheetWithDraggable(
//                                 context: context,
//                                 builder:
//                                     (scrollController) =>
//                                         RegistrationBottomSheet(
//                                           customer: customer,
//                                           scrollController: scrollController,
//                                           outerContext: context,
//                                         ),
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
//                             child: ProspectItem(
//                               userKey: UserSession.userId,
//                               customer: customer,
//                               onTap: (histories) async {
//                                 setFabCanBeShown(false);
//                                 await popupAddHistory(
//                                   context: context,
//                                   histories: histories,
//                                   customer: customer,
//                                   initContent: HistoryContent.title.toString(),
//                                 );
//                                 if (mounted) setFabCanBeShown(true);
//                               },
//
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               floatingActionButton:                 AnimatedBuilder(
//                 animation: themeController,
//                 builder: (context, _) {
//                   final isLight = themeController.flutterThemeMode == ThemeMode.light;
//
//                   return IconButton.filledTonal(
//                     onPressed: themeController.toggleTheme,
//                     icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // 좌측 하단
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
