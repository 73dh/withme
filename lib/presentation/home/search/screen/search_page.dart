import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/presentation/widget/pop_up_history.dart';
import 'package:withme/core/presentation/components/search_customer_item.dart';
import 'package:withme/core/presentation/components/prospect_item.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/enum/selected_menu_no_contact.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final viewModel = getIt<SearchPageViewModel>();

  SelectedMenuNoContact _selectedMenuNoContact =
      SelectedMenuNoContact.threeMonth;

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
    final option = viewModel.state.currentSearchOption;
    final count = viewModel.state.searchedCustomers.length;
    return AppBar(
      title: option != null ? Text('$option $count명') : const Text(''),
    );
  }

  Widget _buildCustomerList(BuildContext context) {
    final customers = viewModel.state.searchedCustomers;
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final item =
            customer.policies.isEmpty
                ? ProspectItem(
                  customer: customer,
                  onTap:
                      (histories) =>
                          _handleAddHistory(context, histories, customer),
                )
                : SearchCustomerItem(
                  customer: customer,
                  onTap:
                      (histories) =>
                          _handleAddHistory(context, histories, customer),
                );

        return Padding(padding: const EdgeInsets.all(8.0), child: item);
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
        _buildFilterButton(
          text: '${_selectedMenuNoContact.toString()} 미관리',
          option: SearchOption.noRecentHistory,
          menuItems:
              SelectedMenuNoContact.values
                  .map(
                    (menu) => PopupMenuItem<SelectedMenuNoContact>(
                      value: menu,
                      child: Text(menu.toString()),
                    ),
                  )
                  .toList(),

          event: SearchPageEvent.filterNoRecentHistoryCustomers(
            month: _selectedMenuNoContact.toInt,
          ),
        ),
        height(5),
        _buildFilterButton(
          text: '생일 (30일 이내)',
          option: SearchOption.comingBirth,
          event: SearchPageEvent.filterCustomersByComingBirth(),
        ),
        height(5),
        _buildFilterButton(
          text: '상령일 잔여일 (10일~30일)',
          option: SearchOption.upcomingInsuranceAge,
          event:
              SearchPageEvent.filterCustomersByUpcomingInsuranceAgeIncrease(),
        ),
        height(5),
        _buildFilterButton(
          text: '생년월일 정보 없음',
          option: SearchOption.noBirth,
          event: SearchPageEvent.filterNoBirthCustomers(),
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String text,
    required SearchOption option,
    required SearchPageEvent event,
    List<PopupMenuEntry<SelectedMenuNoContact>>? menuItems,
  }) {
    final isActive = viewModel.state.currentSearchOption == option;
    return RenderFilledButton(
      onPressed: () => viewModel.onEvent(event),

      menuItems: menuItems,
      onMenuSelected: (selectedOption) {
        setState(() {
          _selectedMenuNoContact = selectedOption;

          viewModel.onEvent(event);
        });
      },
      text: text,
      backgroundColor:
          isActive
              ? ColorStyles.activeSearchButtonColor
              : ColorStyles.unActiveSearchButtonColor,
      borderRadius: 10,
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

    final option = viewModel.state.currentSearchOption;
    switch (option) {
      case SearchOption.noRecentHistory:
        await viewModel.onEvent(
          SearchPageEvent.filterNoRecentHistoryCustomers(
            month: _selectedMenuNoContact.toInt,
          ),
        );
        break;
      case SearchOption.comingBirth:
        await viewModel.onEvent(SearchPageEvent.filterCustomersByComingBirth());
        break;
      case SearchOption.upcomingInsuranceAge:
        await viewModel.onEvent(
          SearchPageEvent.filterCustomersByUpcomingInsuranceAgeIncrease(),
        );
        break;
      case SearchOption.noBirth:
        await viewModel.onEvent(SearchPageEvent.filterNoBirthCustomers());
        break;
      case null:
        break;
    }
  }
}
