import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/presentation/widget/app_bar_search_widget.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/presentation/home/prospect_list/components/prospect_item.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/components/my_circular_indicator.dart';
import '../../../../core/presentation/widget/show_histories.dart';
import '../../../../domain/model/history_model.dart';
import '../prospect_list_event.dart';
import '../prospect_list_view_model.dart';

class ProspectListPage extends StatefulWidget {
  const ProspectListPage({super.key});

  @override
  State<ProspectListPage> createState() => _ProspectListPageState();
}

class _ProspectListPageState extends State<ProspectListPage> {
  final viewModel = getIt<ProspectListViewModel>();
  String? _searchText = '';

  final MenuController menuController = MenuController();
  final TextEditingController textController = TextEditingController(
    text: HistoryContent.title.toString(),
  );

  @override
  void dispose() {
    menuController.close();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: viewModel.getProspects(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            List<CustomerModel> prospectsOrigin = snapshot.data;
            final prospects =
                prospectsOrigin.where((e) {
                  return e.name.contains(_searchText ?? '');
                }).toList();
            return Scaffold(
              appBar: AppBar(
                title: Text('Prospect ${prospects.length}명'),
                actions: [
                  // _searchPart()
                  AppBarSearchWidget(
                    onSubmitted: (text) {
                      setState(() {
                        _searchText = text;
                      });
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
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
                              onTap:
                                  () => context.push(
                                    RoutePath.registration,
                                    extra: prospects[index],
                                  ),
                              child: ProspectItem(
                                customer: prospects[index],
                                onTap: (histories) {
                                  _popupHistory(histories, prospects[index]);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const MyCircularIndicator();
          }
        },
      ),
    );
  }

  // void _popupHistory(
  //   List<HistoryModel> histories,
  //   CustomerModel prospect,
  // ) async {
  //   String? content = await CommonDialog(
  //     menuController: menuController,
  //     textController: textController,
  //   ).showHistories(context, histories);
  //   if (content != null) {
  //     Map<String, dynamic> historyData = HistoryModel.toMapForHistory(
  //       content: content,
  //     );
  //     viewModel.onEvent(
  //       ProspectListEvent.addHistory(
  //         customerKey: prospect.customerKey,
  //         historyData: historyData,
  //       ),
  //     );
  //   }
  // }
}
