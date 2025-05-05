import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/core/widget/circle_item.dart';
import 'package:withme/core/widget/width_height.dart';
import 'package:withme/data/mock/mock_customer.dart';
import 'package:withme/domain/use_case/get_pool_use_case.dart';
import 'package:withme/presentation/home/pool/components/pool_card.dart';
import 'package:withme/presentation/home/pool/pool_view_model.dart';

import '../../../core/ui/text_style/text_styles.dart';
import '../../../domain/model/customer.dart';

class PoolPage extends StatelessWidget {
  const PoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Pool [${10}]')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final customers =
                        mockCustomers.map((e) => Customer.fromJson(e)).toList();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PoolCard(customer: customers[0]),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
          ),
    );
  }
}
