import 'dart:developer';

import 'package:withme/core/presentation/components/policy_item.dart';
import 'package:withme/core/presentation/widget/customerRegistrationAppBar.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/customer/customer_view_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_edit_policy_dialog.dart';
import '../../../domain/model/customer_model.dart';
import '../../../core/presentation/todo/todo_view_model.dart';
import '../components/customer_info.dart';

class CustomerScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerScreen({super.key, required this.customer});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final viewModel = getIt<CustomerViewModel>();
  final todoViewModel = getIt<TodoViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerKey = widget.customer.customerKey;

      todoViewModel.initializeTodos(
        userKey: UserSession.userId,
        customerKey: customerKey,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.customer.insuranceInfo;
    final difference = info.difference;
    final isUrgent = info.isUrgent;
    final insuranceChangeDate = info.insuranceChangeDate;

    return SafeArea(
      child: Scaffold(
        appBar: CustomerRegistrationAppBar(
          customer: widget.customer,
          todoViewModel: todoViewModel,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              height(10),
              CustomerInfo(
                customer: widget.customer,
                viewModel: viewModel,
                isUrgent: isUrgent,
                difference: difference,
                insuranceChangeDate: insuranceChangeDate,
              ),
              height(15),
              const PartTitle(text: '보험계약 정보'),
              Expanded(
                child: StreamBuilder<List<PolicyModel>>(
                  stream: viewModel.getPolicies(widget.customer.customerKey),
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
}
