import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/domain/core_domain_import.dart';
import 'package:withme/core/presentation/components/customer_item.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';
import 'package:withme/presentation/customer/screen/customer_screen.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import '../../../../core/router/router_import.dart';
import '../../../../domain/model/history_model.dart';
import '../../../../domain/use_case/customer/update_searched_customers_use_case.dart';
import '../../../registration_sheet/sheet/registration_bottom_sheet.dart';
import '../search_page_view_model.dart';

class CustomerListView extends StatelessWidget {
  final List<CustomerModel> customers;
  final SearchPageViewModel viewModel;
  final String userKey;

  const CustomerListView({
    super.key,
    required this.customers,
    required this.viewModel,
    required this.userKey,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;

    final customersKey = customers.map((e) => e.customerKey).join(',');

    return AnimatedSwitcher(
      duration: AppDurations.duration300,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child:
          customers.isEmpty
              ? Center(
                key: const ValueKey('empty'),
                child: Column(
                  children: [
                    height(200),
                    const AnimatedText(text: '조건에 맞는 고객이 없습니다.'),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.only(bottom: 90.0),
                child: ListView.builder(
                  key: ValueKey(
                    'option-${viewModel.state.currentSearchOption}-$customersKey',
                  ),
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final item =
                        customer.policies.isEmpty
                            ? _buildProspectItem(context, customer)
                            : _buildCustomerItem(context, customer);

                    return AnimatedSlide(
                      key: ValueKey(customer.customerKey),
                      offset: const Offset(0, 0.1),
                      duration: Duration(milliseconds: 300 + index * 30),
                      child: AnimatedOpacity(
                        opacity: 1,
                        duration: Duration(milliseconds: 300 + index * 30),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: item,
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildProspectItem(BuildContext context, CustomerModel customer) {
    return GestureDetector(
      onTap: () async {
        final result = await showBottomSheetWithDraggable(
          context: context,
          child: RegistrationBottomSheet(
            customerModel: customer,
            scrollController: null, // optional, scrollController는 내부에서 다룸
            outerContext: context,
          ),
        );

        // ✅ 수정된 경우만 리스트 갱신
        if (result == true) {
          await UpdateSearchedCustomersUseCase.call(viewModel);
        }
      },
      child: ProspectItem(
        userKey: userKey,
        customer: customer,
        onTap:
            (histories) => _handleAddHistory(
              context,
              histories,
              customer,
              HistoryContent.title.toString(),
            ),
      ),
    );
  }

  Widget _buildCustomerItem(BuildContext context, CustomerModel customer) {
    return GestureDetector(
      onTap: () async {
        await showBottomSheetWithDraggable(
          context: context,
          child: CustomerScreen(customer: customer),
        );
      },
      child:
      CustomerItem(customer: customer,   onTap: (histories) async {
        await popupAddHistory(
          context,
          histories,
          customer,
          HistoryContent.title.toString(),
        );
      },)
      // SearchCustomerItem(
      //   userKey: userKey,
      //   customer: customer,
      //   onTap:
      //       (histories) => _handleAddHistory(
      //         context,
      //         histories,
      //         customer,
      //         HistoryContent.title.toString(),
      //       ),
      // ),
    );
  }

  void _handleAddHistory(
    BuildContext context,
    List<HistoryModel> histories,
    CustomerModel customer,
    String initContent,
  ) async {
    await popupAddHistory(context, histories, customer, initContent);
  }
}
