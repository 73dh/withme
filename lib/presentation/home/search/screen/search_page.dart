import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/history_content.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/presentation/widget/pop_up_history.dart';
import 'package:withme/presentation/home/search/components/searched_customer_item.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../../core/di/setup.dart';
import '../../../../core/ui/color/color_style.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _NextScreenState();
}

class _NextScreenState extends State<SearchPage> {
  final viewModel = getIt<SearchPageViewModel>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title:
                (viewModel.state.isInitScreen == false)
                    ? Text(
                      '${viewModel.state.currentSearchOption!.toString()}  ${viewModel.state.searchedCustomers.length}명',
                    )
                    : null,
          ),
          body: Stack(
            children: [
              if (viewModel.state.isInitScreen == false)
                ListView.builder(
                  itemCount: viewModel.state.searchedCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = viewModel.state.searchedCustomers[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SearchedCustomerItem(
                        customer: customer,
                        onTap: (histories) async {
                          await onPopupAddHistory(histories, customer);
                        },
                      ),
                    );
                  },
                ),
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent == 0.5) {
                    viewModel.onEvent(
                      SearchPageEvent.filterNoRecentHistoryCustomers(),
                    );
                    return true;
                  }
                  return false;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: 0.1, // 처음 비율
                  minChildSize: 0.1, // 최소 높이
                  maxChildSize: 0.5, // 최대 높이
                  builder: (context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(blurRadius: 10, color: Colors.black26),
                        ],
                      ),
                      child: ListenableBuilder(
                        listenable: viewModel,
                        builder: (context, widget) {
                          return _searchConditionBox(scrollController);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onPopupAddHistory(histories, customer) async {
    await popupAddHistory(
      context,
      histories,
      customer,
      HistoryContent.title.toString(),
    );
    switch (viewModel.state.currentSearchOption) {
      case SearchOption.noRecentHistory:
        viewModel.onEvent(SearchPageEvent.filterNoRecentHistoryCustomers());
        break;
      case SearchOption.comingBirth:
        viewModel.onEvent(SearchPageEvent.filterCustomersByComingBirth());
        break;
      case SearchOption.upcomingInsuranceAge:
        viewModel.onEvent(
          SearchPageEvent.filterCustomersByUpcomingInsuranceAgeIncrease(),
        );
        break;

      case null:
        break;
    }
    // await viewModel.getAllData();
  }

  ListView _searchConditionBox(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      children: [
        _dragUpBar(),
        height(16),
        _buildFilterButton(
          onPressed:
              () => viewModel.onEvent(
                SearchPageEvent.filterNoRecentHistoryCustomers(),
              ),
          text: '3개월 이내 미관리',
          isActive:
              viewModel.state.currentSearchOption ==
              SearchOption.noRecentHistory,
        ),
        height(5),
        _buildFilterButton(
          onPressed:
              () => viewModel.onEvent(
                SearchPageEvent.filterCustomersByComingBirth(),
              ),
          text: '생일 (30일 이내)',
          isActive:
              viewModel.state.currentSearchOption == SearchOption.comingBirth,
        ),
        height(5),
        _buildFilterButton(
          onPressed:
              () => viewModel.onEvent(
                SearchPageEvent.filterCustomersByUpcomingInsuranceAgeIncrease(),
              ),
          text: '상령일 잔여일 (10일~30일)',
          isActive:
              viewModel.state.currentSearchOption ==
              SearchOption.upcomingInsuranceAge,
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required VoidCallback onPressed,
    required String text,
    required bool isActive,
  }) {
    return RenderFilledButton(
      onPressed: onPressed,
      text: text,
      backgroundColor:
          isActive
              ? ColorStyles.activeSearchButtonColor
              : ColorStyles.unActiveSearchButtonColor,
      borderRadius: 10,
    );
  }

  Center _dragUpBar() {
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
}
