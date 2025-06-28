import 'dart:developer';

import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/policy_item.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/customer/customer_view_model.dart';

import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../domain/model/customer_model.dart';
import '../components/customer_info.dart';
import '../components/policy_part.dart';

class CustomerScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<CustomerViewModel>();
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const TitleWidget(title: 'Customer Info'),
              height(20),
              PartTitle(
                text: '고객 정보 (등록일: ${customer.registeredDate.formattedDate})',
              ),
              CustomerInfo(customer: customer, viewModel: viewModel),
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
                      itemBuilder:
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PolicyItem(policy: policies[index])
                            
                            // PolicyPart(
                            //   policy: policies[index],
                            //   customer: customer,
                            // ),
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
