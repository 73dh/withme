import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/widget/my_circular_indicator.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/presentation/home/pool/components/pool_card.dart';
import 'package:withme/presentation/home/pool/pool_view_model.dart';

import '../../../core/di/setup.dart';

class PoolPage extends StatelessWidget {
  const PoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel=getIt<PoolViewModel>();
    return SafeArea(
      child: StreamBuilder(
        stream:viewModel.getPools() ,
        builder: (context,snapshot) {
          if(snapshot.hasError){
            log(snapshot.error.toString());
          }
          if(snapshot.hasData){
            List<CustomerModel> pools=snapshot.data;
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
                      physics: ScrollPhysics(),
                      itemCount: pools.length,
                      itemBuilder: (context, index) {

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: PoolCard(customer:pools[index]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
              );
          }
          else{
            return const MyCircularIndicator();
          }
        }
      ),
    );
  }
}
