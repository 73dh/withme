import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/presentation/components/prospect_item.dart';
import 'package:withme/core/presentation/widget/app_bar_search_widget.dart';
import 'package:withme/core/presentation/widget/pop_up_history.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/domain/model/customer_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/components/my_circular_indicator.dart';
import '../prospect_list_view_model.dart';

class ProspectListPage extends StatefulWidget {
  const ProspectListPage({super.key});

  @override
  State<ProspectListPage> createState() => _ProspectListPageState();
}

class _ProspectListPageState extends State<ProspectListPage> {
  final viewModel = getIt<ProspectListViewModel>();
  String? _searchText = '';

  @override
  void initState() {
    super.initState();
    viewModel.fetchOnce(); // 처음 로드할 때 데이터 요청
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(listenable: viewModel, builder: (context,widget){
        return Scaffold(
                  appBar: _appBar(viewModel.state.cachedProspects),
                  body: _prospectList(viewModel.state.cachedProspects),);
      })

      // FutureBuilder(
      //   // stream: viewModel.prospectsStream,
      //   future: viewModel.fetchOnce(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasError) {
      //       log(snapshot.error.toString());
      //     }
      //     if (!snapshot.hasData || viewModel.state.isLoading==true) {
      //       return MyCircularIndicator();
      //     }
      //     List<CustomerModel> prospectsOrigin =viewModel.state.cachedProspects;
      //     final prospects =
      //         prospectsOrigin.where((e) {
      //           return e.name.contains(_searchText ?? '');
      //         }).toList();
      //     return Scaffold(
      //       appBar: _appBar(prospects),
      //       body: _prospectList(prospects),
      //     );
      //   },
      // ),
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

  AppBar _appBar(List<CustomerModel> prospects) {
    return AppBar(
      title: Text('Prospect ${prospects.length}명'),
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
