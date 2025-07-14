import 'dart:async';
import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
import 'package:withme/presentation/home/prospect_list/components/fab_oevelay_manager_mixin.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/components/info_icon_with_popup.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../../../../domain/use_case/customer/apply_current_sort_use_case.dart';
import '../../../registration_sheet/sheet/registration_bottom_sheet.dart';
import '../components/main_fab.dart';

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/presentation/home/prospect_list/components/animated_fab_container.dart';
import 'package:withme/presentation/home/prospect_list/components/fab_oevelay_manager_mixin.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/use_case/customer/apply_current_sort_use_case.dart';
import '../../../registration_sheet/sheet/registration_bottom_sheet.dart';
import '../components/main_fab.dart';

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

  String? _searchText = '';
  bool _showInactiveOnly = false;



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

    if (_searchText?.isNotEmpty ?? false) {
      filtered = filtered.where((e) => e.name.contains(_searchText!)).toList();
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

    final result = await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.57,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: RegistrationBottomSheet(
                    scrollController: scrollController,
                  ),
                ),
              ),
            );
          },
        );
      },
    );

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
                          setState(() {
                            _searchText = text;
                          });
                        },
                      ),
                    ],
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _showInactiveOnly
                              ? ColorStyles.activeSwitchColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              _showInactiveOnly = !_showInactiveOnly;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showInactiveOnly
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: _showInactiveOnly ? Colors.white : Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${getIt<UserSession>().managePeriodDays}일 미관리',
                                  style: TextStyle(
                                    color:
                                    _showInactiveOnly ? Colors.white : Colors.black87,
                                    fontWeight: _showInactiveOnly
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                     width(3),
                      InfoIconWithPopup(
                      message: '마지막 연락일 기준 ${getIt<UserSession>().managePeriodDays}일 이상 경과 고객'
                          '\n날짜는 설정(가망고객관리주기)에서 변경',
                      color: _showInactiveOnly ? Colors.blueAccent : Colors.black45,
                      ),
                    ],
                  ),
                ),


                      const SizedBox(height: 8),
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
                                  await showModalBottomSheet(
                                    context: context,
                                    useRootNavigator: true,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    builder: (modalContext) {
                                      return DraggableScrollableSheet(
                                        expand: false,
                                        initialChildSize: 0.57,
                                        maxChildSize: 0.95,
                                        minChildSize: 0.4,
                                        builder: (context, scrollController) {
                                          return ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(10),
                                                ),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              child: RegistrationBottomSheet(
                                                customerModel: customer,
                                                scrollController:
                                                    scrollController,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                  setFabCanBeShown(true);
                                  await viewModel.fetchData(force: true);
                                },
                                child: ProspectItem(
                                  userKey: UserSession.userId,
                                  customer: customer,
                                  onTap: (histories) async {
                                    setFabCanBeShown(false);
                                    final result = await popupAddHistory(
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

//
// class ProspectListPage extends StatefulWidget {
//   const ProspectListPage({super.key});
//
//   @override
//   State<ProspectListPage> createState() => _ProspectListPageState();
// }
//
// class _ProspectListPageState extends State<ProspectListPage>
//     with RouteAware, FabOverlayManagerMixin<ProspectListPage> {
//   final RouteObserver<PageRoute> _routeObserver =
//       getIt<RouteObserver<PageRoute>>();
//   @override
//   final viewModel = getIt<ProspectListViewModel>();
//
//   String? _searchText = '';
//   int? _selectedMonth = DateTime.now().month;
//
//   @override
//   void initState() {
//     super.initState();
//     viewModel.fetchData(force: true);
//     _selectedMonth = DateTime.now().month;
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final ModalRoute? modalRoute = ModalRoute.of(context);
//     if (modalRoute is PageRoute) {
//       _routeObserver.subscribe(this, modalRoute);
//     }
//   }
//
//   @override
//   void dispose() {
//     _routeObserver.unsubscribe(this);
//     super.dispose();
//   }
//
//   List<CustomerModel> _applyFilterAndSort(List<CustomerModel> customers) {
//     var filtered = customers.where((e) => e.policies.isEmpty).toList();
//
//     if (_searchText?.isNotEmpty ?? false) {
//       filtered = filtered.where((e) => e.name.contains(_searchText!)).toList();
//     }
//
//     if (_selectedMonth != null) {
//       filtered =
//           filtered
//               .where((e) => e.registeredDate.month == _selectedMonth)
//               .toList();
//     }
//
//     return ApplyCurrentSortUseCase(
//       isAscending: viewModel.sortStatus.isAscending,
//       currentSortType: viewModel.sortStatus.type,
//     ).call(filtered);
//   }
//
//   @override
//   Future<void> onMainFabPressedLogic() async {
//     if (!mounted) return;
//
//     final isLimited = await FreeLimitDialog.checkAndShow(
//       context: context,
//       viewModel: viewModel,
//     );
//     if (isLimited) return;
//
//     setIsProcessActive(true); // 믹스인에게 프로세스 시작을 알림
//
//     if (!context.mounted) return;
//
//     final result = await showModalBottomSheet(
//       context: context,
//       useRootNavigator: true,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (modalContext) {
//         return DraggableScrollableSheet(
//           expand: false,
//           initialChildSize: 0.57,
//           maxChildSize: 0.95,
//           minChildSize: 0.4,
//           builder: (context, scrollController) {
//             return ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
//               child: Container(
//                 decoration: const BoxDecoration(color: Colors.white),
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   child: RegistrationBottomSheet(
//                     scrollController: scrollController,
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//
//     setIsProcessActive(false);
//
//     if (!mounted) return;
//
//     if (result == true) {
//       await viewModel.fetchData(force: true);
//     }
//   }
//
//   @override
//   void onSortActionLogic(Function() sortFn) {
//     sortFn();
//     callOverlaySetState(); // ✅ 믹스인 함수로 변경
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return VisibilityDetector(
//       key: const Key('prospect-list-visibility'),
//       onVisibilityChanged: handleVisibilityChange,
//
//       child: SafeArea(
//         child: AnimatedBuilder(
//           animation: viewModel,
//           builder: (context, _) {
//             return StreamBuilder<List<CustomerModel>>(
//               stream: viewModel.cachedProspects,
//               builder: (context, snapshot) {
//                 final data = snapshot.data ?? [];
//                 final filteredProspects = _applyFilterAndSort(data);
//
//                 if (snapshot.hasError) {
//                   log('StreamBuilder error: ${snapshot.error}');
//                 }
//
//                 return Scaffold(
//                   backgroundColor: Colors.transparent,
//                   appBar: AppBar(
//                     title: Text('Prospect ${filteredProspects.length}명'),
//                     actions: [
//                       AppBarSearchWidget(
//                         onSubmitted: (text) {
//                           setState(() {
//                             _searchText = text;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   body: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildMonthChips(data),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         child: ListView.builder(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           itemCount: filteredProspects.length,
//                           itemBuilder: (context, index) {
//                             final customer = filteredProspects[index];
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 8.0,
//                               ),
//                               child: GestureDetector(
//                                 onTap: () async {
//                                   setFabCanBeShown(false); // 모달 표시 전 FAB 숨김
//
//                                   await showModalBottomSheet(
//                                     context: context,
//                                     useRootNavigator: true,
//                                     // ★ 중요!
//                                     isScrollControlled: true,
//                                     backgroundColor: Colors.transparent,
//                                     shape: const RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.vertical(
//                                         top: Radius.circular(16),
//                                       ),
//                                     ),
//                                     builder: (modalContext) {
//                                       return DraggableScrollableSheet(
//                                         expand: false,
//                                         initialChildSize: 0.57,
//                                         maxChildSize: 0.95,
//                                         minChildSize: 0.4,
//                                         builder: (context, scrollController) {
//                                           return ClipRRect(
//                                             borderRadius:
//                                                 const BorderRadius.vertical(
//                                                   top: Radius.circular(10),
//                                                 ),
//                                             child: Container(
//                                               decoration: const BoxDecoration(
//                                                 color: Colors.white,
//                                               ),
//                                               child: RegistrationBottomSheet(
//                                                 customerModel: customer,
//                                                 scrollController:
//                                                     scrollController,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       );
//                                     },
//                                   );
//
//                                   setFabCanBeShown(true); // 모달 닫힌 후 FAB 다시 표시
//                                   await viewModel.fetchData(force: true);
//                                 },
//
//                                 child: ProspectItem(
//                                   userKey: UserSession.userId,
//                                   customer: customer,
//                                   onTap: (histories) async {
//                                     setFabCanBeShown(false); // 팝업 전 FAB 숨김
//
//                                     final result = await popupAddHistory(
//                                       context,
//                                       histories,
//                                       customer,
//                                       HistoryContent.title.toString(),
//                                     );
//
//                                     if (!mounted) return;
//                                     setFabCanBeShown(true); // 팝업 후 FAB 다시 표시
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMonthChips(List<CustomerModel> customers) {
//     final months =
//         customers
//             .where((e) => e.policies.isEmpty)
//             .map((e) => e.registeredDate.month)
//             .toSet()
//             .toList()
//           ..sort();
//
//     return SizedBox(
//       height: 48,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         separatorBuilder: (_, __) => const SizedBox(width: 6),
//         itemCount: months.length,
//         itemBuilder: (_, index) {
//           final month = months[index];
//           final selected = _selectedMonth == month;
//           return ChoiceChip(
//             label: Text('$month월'),
//             selected: selected,
//             onSelected: (isSelected) {
//               setState(() {
//                 // ✅ 같은 월 다시 누르면 해제
//                 if (_selectedMonth == month) {
//                   _selectedMonth = null;
//                 } else {
//                   _selectedMonth = month;
//                 }
//               });
//             },
//           );
//         },
//       ),
//     );
//   }
// }
