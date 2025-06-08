import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/core/presentation/components/policy_item.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/use_case/customer/update_searched_customers_use_case.dart';
import 'package:withme/presentation/home/search/components/coming_birth_filter_button.dart';
import 'package:withme/presentation/home/search/components/no_birth_filter_button.dart';
import 'package:withme/presentation/home/search/components/no_contact_filter_button.dart';
import 'package:withme/presentation/home/search/components/policy_filter_button.dart';
import 'package:withme/presentation/home/search/components/upcoming_insurance_age_filter_button.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';
import '../../../../core/domain/core_domain_import.dart';
import '../../../../core/presentation/core_presentation_import.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final viewModel = getIt<SearchPageViewModel>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              if (viewModel.state.currentSearchOption != null)
                _buildCustomerList(context),
              AnimatedSwitcher(
                duration: AppDurations.duration300,
                child:
                    viewModel.state.currentSearchOption == null
                        ? const Align(
                          key: ValueKey(
                            'select_button_text',
                          ), // key가 꼭 달라야 애니메이션이 동작함
                          alignment: FractionalOffset(0.5, 0.33),
                          child: Text(
                            'Select Button',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        : const SizedBox.shrink(
                          key: ValueKey(
                            'empty',
                          ), // 다른 key를 주어야 AnimatedSwitcher가 인식
                        ),
              ),
              _buildDraggableFilterSheet(),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    final state = viewModel.state;
    final currentOption = state.currentSearchOption;

    final option = switch (currentOption) {
      SearchOption.noRecentHistory => state.noContactMonth,
      SearchOption.comingBirth => state.comingBirth,
      SearchOption.upcomingInsuranceAge => state.upcomingInsuranceAge,
      SearchOption.noBirth => '생년월일 정보없음',
      _ => '',
    };
    final count = viewModel.state.filteredCustomers.length;
    return AppBar(
      title: option != '' ? Text('$option $count명') : const Text(''),
    );
  }

  Widget _buildCustomerList(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;
    final customers = viewModel.state.filteredCustomers;
    final policies = viewModel.state.filteredPolicies;

    if (viewModel.state.currentSearchOption == SearchOption.filterPolicy) {
      return ListView.builder(
        padding: EdgeInsets.only(bottom: bottomPadding),
        itemCount: policies.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: PolicyItem(policy: policies[index]),
          );
        },
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final item =
            customer.policies.isEmpty
                ? _buildProspectItem(context, customer)
                : _buildCustomerItem(context, customer);

        return Padding(padding: const EdgeInsets.all(8.0), child: item);
      },
    );
  }

  Widget _buildProspectItem(BuildContext context, dynamic customer) {
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await Future.delayed(AppDurations.duration100);
        if (context.mounted) {
          await context.push(RoutePath.registration, extra: customer);
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // await viewModel.getAllData();
        await UpdateSearchedCustomersUseCase.call(viewModel);
      },
      child: ProspectItem(
        customer: customer,
        onTap: (histories) => _handleAddHistory(context, histories, customer),
      ),
    );
  }

  Widget _buildCustomerItem(BuildContext context, dynamic customer) {
    return SearchCustomerItem(
      customer: customer,
      onTap: (histories) => _handleAddHistory(context, histories, customer),
    );
  }

  Widget _buildDraggableFilterSheet() {
    return NotificationListener<DraggableScrollableNotification>(
      child: DraggableScrollableSheet(
        initialChildSize: 0.1,
        minChildSize: 0.1,
        maxChildSize: 0.51,
        builder: (context, scrollController) {
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: ListenableBuilder(
                  listenable: viewModel,
                  builder:
                      (context, _) => _buildFilterOptions(scrollController),
                ),
              ),
              if (viewModel.state.isLoadingAllData)
                 Positioned(
                  top: 15,
                  left: 20,
                  child: Row(
                    children: [
                      Text('업데이트중'),width(5),
                      MyCircularIndicator(size: 10),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterOptions(ScrollController controller) {
    return ListView(
      controller: controller,
      children: [
        _buildDragHandle(),
        height(17),
        NoContactFilterButton(viewModel: viewModel),
        height(5),
        ComingBirthFilterButton(viewModel: viewModel),
        height(5),
        UpcomingInsuranceAgeFilterButton(viewModel: viewModel),
        height(5),
        NoBirthFilterButton(viewModel: viewModel),
        height(5),
        const PartTitle(text: '계약조회'),
        PartBox(child: PolicyFilterButton(viewModel: viewModel)),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _handleAddHistory(
    BuildContext context,
    dynamic histories,
    dynamic customer,
  ) async {
    await popupAddHistory(
      context,
      histories,
      customer,
      HistoryContent.title.toString(),
    );
    await UpdateSearchedCustomersUseCase.call(viewModel);
  }
}
