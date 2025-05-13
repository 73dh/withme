import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/data/repository/customer_repository_impl.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/customer/get_prospect_use_case.dart';
import 'package:withme/presentation/home/prospect/components/prospect_card.dart';
import 'package:withme/presentation/home/prospect/prospect_event.dart';
import 'package:withme/presentation/home/prospect/prospect_view_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/widget/my_circular_indicator.dart';
import '../../../../domain/model/history_model.dart';
import '../../../../core/presentation/widget/show_histories.dart';

class ProspectPage extends StatelessWidget {
  const ProspectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<ProspectViewModel>();
    final MenuController menuController = MenuController();
    final TextEditingController textController = TextEditingController(
      text: HistoryContent.title.toString(),
    );
    return SafeArea(
      child: StreamBuilder(
        stream: viewModel.getProspects(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            List<CustomerModel> pools = snapshot.data;
            return Scaffold(
              appBar: AppBar(title: Text('Prospect ${pools.length}명')),
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
                        itemCount: pools.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: (){
                                context.push(RoutePath.registration,extra: pools[index]);
                              },
                              child: ProspectCard(
                                customer: pools[index],
                                onTap: (List<HistoryModel> histories) async {
                                  String? content = await CommonDialog(
                                    menuController: menuController,
                                    textController: textController,
                                  ).showHistories(context, histories);
                                  if (content != null) {
                                    Map<String, dynamic> historyData =
                                        HistoryModel.toMapForHistory(
                                          content: content,
                                        );
                                    viewModel.onEvent(
                                      ProspectEvent.addHistory(
                                        customerKey: pools[index].customerKey,
                                        historyData: historyData,
                                      ),
                                    );
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
              ),
            );
          } else {
            return const MyCircularIndicator();
          }
        },
      ),
    );
  }
}
