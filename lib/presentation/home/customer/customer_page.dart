import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/use_case/customer/get_customers_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/presentation/home/customer/components/customer_card.dart';
import 'package:withme/presentation/home/customer/customer_view_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/widget/my_circular_indicator.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<CustomerViewModel>();
    return SafeArea(
      child: StreamBuilder(
        stream: getIt<CustomerUseCase>().call(usecase: GetCustomersUseCase()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            List<CustomerModel> customers = snapshot.data ;
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
                              onTap: () {},
                              child: CustomerCard(customer: customers[index]),
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
