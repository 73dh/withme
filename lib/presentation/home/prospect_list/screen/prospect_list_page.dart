import 'dart:developer';

import 'package:withme/core/di/di_setup_import.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/router/router_import.dart';
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

  @override
  void initState() {
    super.initState();
    viewModel.fetchData; // 처음 로드할 때 데이터 요청
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _route = route; // ✅ 저장해두기
      getIt<RouteObserver<PageRoute>>().subscribe(this, _route!);
    } }

  @override
  void dispose() {
    if (_route != null) {
      getIt<RouteObserver<PageRoute>>().unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // 등록화면에서 돌아왔을 때 호출됨
    viewModel.fetchData;
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
}
