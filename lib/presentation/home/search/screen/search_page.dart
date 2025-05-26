import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/domain/enum/insurance_category.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/presentation/widget/pop_up_history.dart';
import 'package:withme/core/presentation/components/search_customer_item.dart';
import 'package:withme/core/presentation/components/prospect_item.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/presentation/home/search/components/coming_birth_filter_button.dart';
import 'package:withme/presentation/home/search/components/no_birth_filter_button.dart';
import 'package:withme/presentation/home/search/components/no_contact_filter_button.dart';
import 'package:withme/presentation/home/search/components/upcoming_insurance_age_filter_button.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../../core/presentation/components/part_title.dart';

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
              _buildCustomerList(context),
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
    final count = viewModel.state.searchedCustomers.length;
    return AppBar(
      title: option != '' ? Text('$option $count명') : const Text(''),
    );
  }

  Widget _buildCustomerList(BuildContext context) {
    final customers = viewModel.state.searchedCustomers;
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final itemWidget =
            customer.policies.isEmpty
                ? GestureDetector(
                  onTap: () async {
                    await context.push(RoutePath.registration, extra: customer);
                    await viewModel.getAllData();
                    await _updateSearchedCustomers();
                  },
                  child: ProspectItem(
                    customer: customer,
                    onTap:
                        (histories) =>
                            _handleAddHistory(context, histories, customer),
                  ),
                )
                : SearchCustomerItem(
                  customer: customer,
                  onTap:
                      (histories) =>
                          _handleAddHistory(context, histories, customer),
                );

        return Padding(padding: const EdgeInsets.all(8.0), child: itemWidget);
      },
    );
  }

  Widget _buildDraggableFilterSheet() {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent == 0.5) {
          viewModel.getAllData();
          return true;
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.1,
        minChildSize: 0.1,
        maxChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) => _buildFilterOptions(scrollController),
            ),
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
        height(16),
        NoContactFilterButton(viewModel: viewModel),
        height(5),
        ComingBirthFilterButton(viewModel: viewModel),
        height(5),
        UpcomingInsuranceAgeFilterButton(viewModel: viewModel),
        height(5),
        NoBirthFilterButton(viewModel: viewModel),
        height(5),
        PartTitle(text: '계약조회'),
        PopupMenuButton(itemBuilder: (context){
          return InsuranceCategory.values.map((e)=>PopupMenuItem(child: Text(e.toString()))).toList();
        })
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
    await viewModel.getAllData();
    await _updateSearchedCustomers();
  }

  Future<void> _updateSearchedCustomers() async {
    final state = viewModel.state;
    final currentOption = state.currentSearchOption;

    final event = switch (currentOption) {
      SearchOption.noRecentHistory =>
        SearchPageEvent.filterNoRecentHistoryCustomers(
          month: state.noContactMonth,
        ),
      SearchOption.comingBirth => SearchPageEvent.filterComingBirth(
        birthDay: state.comingBirth,
      ),
      SearchOption.upcomingInsuranceAge =>
        SearchPageEvent.filterUpcomingInsuranceAge(
          insuranceAge: state.upcomingInsuranceAge,
        ),
      SearchOption.noBirth => SearchPageEvent.filterNoBirthCustomers(),
      _ => null,
    };

    if (event != null) {
      await viewModel.onEvent(event);
    }
  }
}
