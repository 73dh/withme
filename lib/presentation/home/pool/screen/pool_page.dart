import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/widget/my_circular_indicator.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/presentation/home/pool/components/pool_card.dart';
import 'package:withme/presentation/home/pool/pool_event.dart';
import 'package:withme/presentation/home/pool/pool_view_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../domain/model/history_model.dart';
import '../components/show_histories.dart';

class PoolPage extends StatelessWidget {
  const PoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<PoolViewModel>();
    return SafeArea(
      child: StreamBuilder(
        stream: viewModel.getPools(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            List<CustomerModel> pools = snapshot.data;
            return Scaffold(
              appBar: AppBar(title: Text('Pool [${pools.length}]')),
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
                            child: PoolCard(
                              customer: pools[index],
                              onTap: (List<HistoryModel> histories) async{
                               HistoryModel? historyResult=await showHistories(context, histories);
                              if(historyResult!=null){

                               print(historyResult);
                              }
                              },
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
