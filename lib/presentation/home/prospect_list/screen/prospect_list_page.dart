import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/presentation/home/prospect_list/components/fab_container.dart';
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
  PageRoute? _route;
  OverlayEntry? _fabOverlayEntry;

  bool _fabExpanded = true;
  bool _fabVisibleLocal = false;
  void Function(void Function())? overlaySetState;

  bool _fabOverlayInserted = false;

  @override
  void initState() {
    super.initState();
    viewModel.fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();



    if (!_fabOverlayInserted) {
      // SchedulerBinding을 활용해 빌드 완료 후 가장 안전한 시점에 실행
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _insertFabOverlay();
        _fabOverlayInserted = true;
      });
    }

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _route = route;
      getIt<RouteObserver<PageRoute>>().subscribe(this, _route!);
      log('✅ RouteObserver 구독 완료');
    } else {
      log('❌ PageRoute 아님!');
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
    viewModel.fetchData();
    log('📌 didPopNext 호출됨, FAB 다시 삽입 시도');
    _insertFabOverlay();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<CustomerModel>>(
        stream: viewModel.cachedProspects,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const MyCircularIndicator();
          }
          List<CustomerModel> prospectsOrigin = snapshot.data!;
          final filteredProspects = prospectsOrigin
              .where((e) => e.name.contains(_searchText ?? ''))
              .toList();

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
                      onTap: (histories) async {
                        _fabOverlayEntry?.remove();
                     bool? result=   await popupAddHistory(
                          context,
                          histories,
                          prospects[index],
                          HistoryContent.title.toString(),
                        );
                     if(result ==true){

                        _insertFabOverlay();
                     }
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
    _fabOverlayEntry?.remove();
    _fabOverlayEntry = null;

    _fabVisibleLocal = false;
    _fabExpanded = false;

    // 다시 한번 FrameCallback으로 삽입 안전시점 보장
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      OverlayState overlay = Overlay.of(context,rootOverlay: true);


      _fabOverlayEntry = OverlayEntry(
        builder: (context) {
          overlaySetState = null;
          return StatefulBuilder(
            builder: (context, setState) {
              overlaySetState = setState;
              return Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_fabVisibleLocal,
                  child: Stack(
                    children: [
                      FabContainer(
                        fabVisibleLocal: _fabVisibleLocal,
                        rightPosition: 16,
                        bottomPosition: 132,
                        child: SmallFab(
                          fabExpanded: _fabExpanded,
                          fabVisibleLocal: _fabVisibleLocal,
                          overlaySetState: (_) => _toggleFabExpanded(),
                          overlaySetStateFold: (_) => _toggleFabExpanded(),
                        ),
                      ),
                      FabContainer(
                        fabVisibleLocal: _fabVisibleLocal,
                        rightPosition: 16,
                        bottomPosition: 66,
                        child: MainFab(
                          fabVisibleLocal: _fabVisibleLocal,
                          onPressed: () async {
                            overlaySetState?.call(() {
                              _fabExpanded = false;
                              _fabVisibleLocal = false;
                            });
                            if (context.mounted) {
                              await context.push(RoutePath.registration);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      overlay.insert(_fabOverlayEntry!);

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          overlaySetState?.call(() {
            _fabVisibleLocal = true;
            _fabExpanded = false;
          });
        });
      });
    });
  }

  void _toggleFabExpanded() {
    overlaySetState?.call(() {
      _fabExpanded = !_fabExpanded;
    });
  }
}
