import 'dart:developer';

import 'package:withme/core/presentation/components/policy_item.dart';
import 'package:withme/core/presentation/widget/customer_registration_app_bar.dart';
import 'package:withme/core/presentation/widget/show_update_memo_dialog.dart';
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
  late CustomerModel _customer; // 내부 상태로 관리

  @override
  void initState() {
    super.initState();

    // widget.customer를 내부 상태에 복사
    _customer = widget.customer;

    todoViewModel = TodoViewModel(
      userKey: UserSession.userId,
      customerKey: _customer.customerKey,
    );

    todoViewModel.loadTodos(_customer.todos);
  }

  Future<void> _updateMemo(String newMemo) async {
    await viewModel.updateMemo(
      userKey: UserSession.userId,
      customerKey: _customer.customerKey,
      memo: newMemo,
    );

    // DB 반영 후, 상태도 즉시 업데이트
    setState(() {
      _customer = _customer.copyWith(memo: newMemo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final info = _customer.insuranceInfo;
    final difference = info.difference;
    final isUrgent = info.isUrgent;
    final insuranceChangeDate = info.insuranceChangeDate;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: CustomerRegistrationAppBar(
          customer: _customer,
          todoViewModel: todoViewModel,
        ),
        body: StreamBuilder<List<PolicyModel>>(
          stream: viewModel.getPolicies(_customer.customerKey),
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
                  GestureDetector(
                    onTap: () async {
                      final newMemo = await showUpdateMemoDialog(
                        context,
                        title: _customer.name,
                        initMemo: _customer.memo,
                      );
                      if (newMemo != null && newMemo.isNotEmpty) {
                        await _updateMemo(newMemo);
                      }
                    },
                    child: CustomerInfo(
                      customer: _customer,
                      viewModel: viewModel,
                      isUrgent: isUrgent,
                      difference: difference,
                      insuranceChangeDate: insuranceChangeDate,
                    ),
                  ),
                  height(20),
                  Text(
                    '보험계약 정보',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  height(12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: policies.length,
                    separatorBuilder: (_, __) => height(10),
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
