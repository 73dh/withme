import 'dart:developer';

import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/policy_item.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/customer/customer_view_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_edit_policy_dialog.dart';
import '../../../domain/model/customer_model.dart';
import '../components/customer_info.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/policy_item.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/customer/customer_view_model.dart';

import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_edit_policy_dialog.dart';
import '../../../domain/model/customer_model.dart';
import '../components/customer_info.dart';

class CustomerScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<CustomerViewModel>();

    // final birthDate = customer.birth;
    // final userSession = getIt<UserSession>();
    //
    // int? difference;
    // DateTime? insuranceChangeDate;
    // bool isUrgent = false;
    //
    // if (birthDate != null) {
    //   insuranceChangeDate = getInsuranceAgeChangeDate(birthDate);
    //   difference = insuranceChangeDate.difference(DateTime.now()).inDays;
    //   isUrgent = difference >= 0 && difference <= userSession.urgentThresholdDays;
    // }


    final info = customer.insuranceInfo;
    final difference = info.difference;
    final isUrgent = info.isUrgent;
    final insuranceChangeDate = info.insuranceChangeDate;

    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              height(10),
              CustomerInfo(
                customer: customer,
                viewModel: viewModel,
                isUrgent: isUrgent,
                difference: difference,
                insuranceChangeDate: insuranceChangeDate,
              ),
              height(15),
              const PartTitle(text: '보험계약 정보'),
              Expanded(
                child: StreamBuilder<List<PolicyModel>>(
                  stream: viewModel.getPolicies(customer.customerKey),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      log(snapshot.error.toString());
                    }
                    if (!snapshot.hasData) {
                      return const MyCircularIndicator();
                    }
                    final policies = snapshot.data!;
                    return ListView.builder(
                      itemCount: policies.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () async {
                            await showEditPolicyDialog(
                              context: context,
                              policy: policies[index],
                              viewModel: viewModel,
                            );
                          },
                          child: PolicyItem(policy: policies[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            customer.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '(${customer.registeredDate.formattedDate})',
            style: const TextStyle(fontSize: 18, color: Colors.black45),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AddPolicyWidget(
            onTap: () {
              context.push(RoutePath.policy, extra: customer);
            },
            size: 40,
          ),
        ),
      ],
    );
  }
}

//
// class CustomerScreen extends StatelessWidget {
//   final CustomerModel customer;
//
//   const CustomerScreen({super.key, required this.customer});
//
//   @override
//   Widget build(BuildContext context) {
//     final viewModel = getIt<CustomerViewModel>();
//     return SafeArea(
//       child: Scaffold(
//         appBar: _appBar(context),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               height(10),
//               CustomerInfo(customer: customer, viewModel: viewModel),
//               height(15),
//               const PartTitle(text: '보험계약 정보'),
//               Expanded(
//                 child: StreamBuilder<List<PolicyModel>>(
//                   stream: viewModel.getPolicies(customer.customerKey),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       log(snapshot.error.toString());
//                     }
//                     if (!snapshot.hasData) {
//                       return const MyCircularIndicator();
//                     }
//                     final policies = snapshot.data!;
//                     return ListView.builder(
//                       itemCount: policies.length,
//                       itemBuilder:
//                           (context, index) => Padding(
//                             padding: const EdgeInsets.only(bottom: 10),
//                             child: GestureDetector(
//                               onTap: () async {
//                                 await showEditPolicyDialog(
//                                   context: context,
//                                   policy: policies[index],
//                                   viewModel: viewModel,
//                                 );
//                               },
//                               child: PolicyItem(policy: policies[index]),
//                             ),
//                           ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   AppBar _appBar(BuildContext context) {
//     return AppBar(
//       centerTitle: true,
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(
//             customer.name,
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '(${customer.registeredDate.formattedDate})',
//             style: const TextStyle(fontSize: 18, color: Colors.black45),
//           ),
//         ],
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: AddPolicyWidget(
//             onTap: () {
//               context.push(RoutePath.policy, extra: customer);
//             },
//             size: 40,
//           ),
//         ),
//       ],
//     );
//   }
// }
