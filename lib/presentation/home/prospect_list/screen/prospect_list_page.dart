import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/presentation/widget/app_bar_search_widget.dart';
import 'package:withme/core/presentation/widget/pop_up_history.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';
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
