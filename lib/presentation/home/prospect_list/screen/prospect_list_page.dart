import 'dart:developer';

import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/presentation/home/prospect_list/components/main_fab.dart';
import 'package:withme/presentation/home/prospect_list/components/small_fab.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/router/router_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';

class ProspectListPage extends StatefulWidget {
  const ProspectListPage({super.key});

  @override
  State<ProspectListPage> createState() => _ProspectListPageState();
}

class _ProspectListPageState extends State<ProspectListPage> with RouteAware {
  final viewModel = getIt<ProspectListViewModel>();
  String? _searchText = '';
  PageRoute? _route; // ✅ 안전하게 캐시
  OverlayEntry? _fabOverlayEntry;

  bool _fabExpanded = true; // FAB 확장 여부
  bool _fabVisibleLocal = false;
  void Function(void Function())? overlaySetState;

  @override
  void initState() {
    super.initState();
    viewModel.fetchData;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertFabOverlay(); // FAB 삽입
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _route = route; // ✅ 저장해두기
      getIt<RouteObserver<PageRoute>>().subscribe(this, _route!);
    }
  }

  @override
  void dispose() {
    if (_route != null) {
      getIt<RouteObserver<PageRoute>>().unsubscribe(this);
    }
    _fabOverlayEntry?.remove();
    super.dispose();
  }

  @override
  void didPopNext() {
    viewModel.fetchData;

    // 🔁 FAB 다시 보이게 설정
    if (_fabOverlayEntry?.mounted ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        overlaySetState?.call(() {
          _fabVisibleLocal = true;
          _fabExpanded = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: viewModel.cachedProspects,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (!snapshot.hasData || viewModel.state.isLoading == true) {
            return const MyCircularIndicator();
          }
          List<CustomerModel> prospectsOrigin = snapshot.data!;
          final filteredProspects =
              prospectsOrigin.where((e) {
                return e.name.contains(_searchText ?? '');
              }).toList();
          return Scaffold(
            appBar: _appBar(filteredProspects.length),
            body: _prospectList(filteredProspects),
          );
        },
      ),
    );
  }

  AppBar _appBar(int count) {
    return AppBar(
      title: Text('Prospect $count명'),
      actions: [
        AppBarSearchWidget(
          onSubmitted: (text) {
            setState(() {
              _searchText = text;
            });
          },
        ),
      ],
    );
  }

  SingleChildScrollView _prospectList(List<CustomerModel> prospects) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: prospects.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      context.push(
                        RoutePath.registration,
                        extra: prospects[index],
                      );
                    },
                    child: ProspectItem(
                      customer: prospects[index],
                      onTap: (histories) {
                        popupAddHistory(
                          context,
                          histories,
                          prospects[index],
                          HistoryContent.title.toString(),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _insertFabOverlay() {
    _fabOverlayEntry = OverlayEntry(
      builder: (context) {
        overlaySetState = null; // reset
        return StatefulBuilder(
          builder: (context, setState) {
            overlaySetState = setState;
            return Stack(
              children: [
                SmallFab(
                  fabExpanded: _fabExpanded,
                  overlaySetState: (void Function() function) {
                    overlaySetState?.call(() {
                      _fabExpanded = !_fabExpanded;
                    });
                  },
                  overlaySetStateFold: (void Function() function) {
                    overlaySetState?.call(() {
                      _fabExpanded = !_fabExpanded;
                    });
                  },
                ),
                MainFab(
                  fabVisibleLocal: _fabVisibleLocal,
                  onPressed: () async {
                    overlaySetState?.call(() {
                      _fabVisibleLocal = false; // MainFAB 숨김
                      _fabExpanded = false; // SmallFAB 숨김
                    });
                    await Future.delayed(AppDurations.duration500);
                    if (context.mounted) {
                      await context.push(RoutePath.registration);
                    }
                    // 돌아오면 다시 나타나게 될 것 (didPopNext에서 처리)
                  },
                ),
              ],
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_fabOverlayEntry!);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (overlaySetState != null) {
        overlaySetState!(() => _fabVisibleLocal = true);
      }
    });
  }
}
