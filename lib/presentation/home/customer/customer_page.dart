import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/presentation/home/customer/components/customer_card.dart';
import 'package:withme/presentation/home/customer/customer_view_model.dart';
import 'package:withme/presentation/home/prospect/components/prospect_card.dart';
import 'package:withme/presentation/home/prospect/prospect_event.dart';
import 'package:withme/presentation/home/prospect/prospect_view_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/widget/my_circular_indicator.dart';
import '../../../../domain/model/history_model.dart';
import '../../../../core/presentation/widget/show_histories.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<CustomerViewModel>();
    final MenuController menuController = MenuController();
    final TextEditingController textController = TextEditingController(
      text: HistoryContent.title.toString(),
    );
    return SafeArea(
      child: StreamBuilder(
        stream: viewModel.getCustomers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            List<CustomerModel> customers = snapshot.data;
            return Scaffold(
              appBar: AppBar(title: Text('Customer ${customers.length}명')),
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
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: () {

                              },
                              child: CustomerCard(customer: customers[index],),
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
