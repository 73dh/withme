import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/presentation/widget/show_agreement_dialog.dart';
import 'package:withme/core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/core/presentation/fab/fab_oevelay_manager_mixin.dart';
import 'package:withme/core/presentation/widget/inactive_and_urgent_filter_bar.dart';
import 'package:withme/presentation/home/home_grand_import.dart';
import 'package:withme/presentation/home/prospect_list/components/prospect_list_app_bar.dart';

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
    with
        RouteAware,
        FabOverlayManagerMixin<ProspectListPage, ProspectListViewModel> {
  final RouteObserver<PageRoute> _routeObserver =
      getIt<RouteObserver<PageRoute>>();

  @override
  final viewModel = getIt<ProspectListViewModel>();

  bool _showInactiveOnly = false;
  bool _showUrgentOnly = false;
  bool? _lastIsSuccess;
  bool _hasCheckedAgreement = false; // ✅ 여기에 추가

  @override
  void initState() {
    super.initState();

    viewModel.fetchData(force: true);
    _initPopup();
  }

  void _initPopup() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_hasCheckedAgreement) return;
      _hasCheckedAgreement = true;

      final userSession = getIt<UserSession>();
      await userSession.loadAgreementCheckFromPrefs();

      // SharedPreferences에서 3가지 값 로드 (UserSession 내부 메서드가 이미 구현되어 있으니 바로 getter 사용)
      final managePeriod = userSession.managePeriodDays;
      final urgentThreshold = userSession.urgentThresholdDays;
      final targetCount = userSession.targetProspectCount;

      if (userSession.isFirstLogin && mounted) {
        await showConfirmDialog(
          context,
          text:
              '현재 설정\n\n'
              '고객 관리주기: $managePeriod일\n'
              '상령일 알림: $urgentThreshold일\n'
              '목표 고객수: $targetCount명\n\n'
              '설정⚙️ 에서 수정 가능합니다.',
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
    super.dispose();
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
                final filteredList = snapshot.data ?? [];

                return Scaffold(
                  resizeToAvoidBottomInset: true,
                  backgroundColor: Colors.transparent,
                  appBar: ProspectListAppBar(
                    viewModel: viewModel,
                    customers: filteredList,
                  ),

                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InactiveAndUrgentFilterBar(
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
                      ),
                     height(5),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final customer = filteredList[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  setFabCanBeShown(false);
                                  _lastIsSuccess = null;

                                  final result =
                                      await showBottomSheetWithDraggable(
                                        context: context,
                                        child: RegistrationBottomSheet(
                                          customerModel: customer,
                                          outerContext: context,
                                        ),
                                      );

                                  if (_lastIsSuccess == null &&
                                      result == null) {
                                    _lastIsSuccess = true;
                                    setFabCanBeShown(true);
                                  }

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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
