import 'dart:developer';

import 'package:withme/core/presentation/components/policy_item.dart';
import 'package:withme/core/presentation/widget/customer_registration_app_bar.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/customer/customer_view_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/todo/todo_view_model.dart';
import '../../../core/presentation/widget/show_edit_policy_dialog.dart';
import '../../../domain/model/customer_model.dart';
import '../components/customer_info.dart';

class CustomerScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerScreen({super.key, required this.customer});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final viewModel = getIt<CustomerViewModel>();
  late final TodoViewModel todoViewModel;

  @override
  void initState() {
    super.initState();
    todoViewModel = TodoViewModel(
      userKey: UserSession.userId,
      customerKey: widget.customer.customerKey,
    );

    todoViewModel.loadTodos(widget.customer.todos);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final info = widget.customer.insuranceInfo;
    final difference = info.difference;
    final isUrgent = info.isUrgent;
    final insuranceChangeDate = info.insuranceChangeDate;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: CustomerRegistrationAppBar(
          customer: widget.customer,
          todoViewModel: todoViewModel,
        ),
        body: StreamBuilder<List<PolicyModel>>(
          stream: viewModel.getPolicies(widget.customer.customerKey),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              log(snapshot.error.toString());
            }

            if (!snapshot.hasData) {
              return const Center(child: MyCircularIndicator());
            }

            final policies = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  CustomerInfo(
                    customer: widget.customer,
                    viewModel: viewModel,
                    isUrgent: isUrgent,
                    difference: difference,
                    insuranceChangeDate: insuranceChangeDate,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '보험계약 정보',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: policies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final policy = policies[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await showEditPolicyDialog(
                            context: context,
                            policy: policy,
                            viewModel: viewModel,
                          );
                        },
                        child: PolicyItem(policy: policy),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}



//
// class CustomerScreen extends StatefulWidget {
//   final CustomerModel customer;
//
//   const CustomerScreen({super.key, required this.customer});
//
//   @override
//   State<CustomerScreen> createState() => _CustomerScreenState();
// }
//
// class _CustomerScreenState extends State<CustomerScreen> {
//   final viewModel = getIt<CustomerViewModel>();
//   late final TodoViewModel todoViewModel;
//
//   @override
//   void initState() {
//     super.initState();
//     // TodoViewModel 생성 시 userKey/customerKey 바로 주입
//     todoViewModel = TodoViewModel(
//       userKey: UserSession.userId,
//       customerKey: widget.customer.customerKey,
//     );
//
//     // Firestore 초기값이 있다면 loadTodos 호출
//     todoViewModel.loadTodos(widget.customer.todos);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final textTheme = theme.textTheme;
//
//     final info = widget.customer.insuranceInfo;
//     final difference = info.difference;
//     final isUrgent = info.isUrgent;
//     final insuranceChangeDate = info.insuranceChangeDate;
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         resizeToAvoidBottomInset: true, // 기본값 true지만 명시
//         appBar: CustomerRegistrationAppBar(
//           customer: widget.customer,
//           todoViewModel: todoViewModel,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12.0),
//           // theme.spacing 가 없으니 base spacing 고정
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 8),
//               CustomerInfo(
//                 customer: widget.customer,
//                 viewModel: viewModel,
//                 isUrgent: isUrgent,
//                 difference: difference,
//                 insuranceChangeDate: insuranceChangeDate,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 '보험계약 정보',
//                 style: textTheme.titleMedium?.copyWith(
//                   color: colorScheme.onSurface,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Expanded(
//                 child: StreamBuilder<List<PolicyModel>>(
//                   stream: viewModel.getPolicies(widget.customer.customerKey),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       log(snapshot.error.toString());
//                     }
//                     if (!snapshot.hasData) {
//                       return const Center(child: MyCircularIndicator());
//                     }
//                     final policies = snapshot.data!;
//                     return ListView.separated(
//                       itemCount: policies.length,
//                       separatorBuilder: (_, __) => const SizedBox(height: 10),
//                       itemBuilder:
//                           (context, index) => InkWell(
//                             borderRadius: BorderRadius.circular(12),
//                             onTap: () async {
//                               await showEditPolicyDialog(
//                                 context: context,
//                                 policy: policies[index],
//                                 viewModel: viewModel,
//                               );
//                             },
//                             child: PolicyItem(policy: policies[index]),
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
// }
