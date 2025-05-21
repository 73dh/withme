import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/presentation/home/search/components/searched_customer_item.dart';
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
            title: Text('검색 결과  ${viewModel.state.searchedCustomers.length}명'),
          ),
          body: Stack(
            children: [
              ListView.builder(
                itemCount: viewModel.state.searchedCustomers.length,
                itemBuilder: (context, index) {
                  final customer = viewModel.state.searchedCustomers[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchedCustomerItem(
                      customer: customer,
                      onTap: (text) {
                        print('tap');
                      },
                    ),
                  );
                },
              ),
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent == 0.5) {
                    viewModel.getAllData();
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

  ListView _searchConditionBox(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      children: [
        _dragUpBar(),
        height(16),
        RenderFilledButton(
          onPressed:
              () => viewModel.onEvent(
                SearchPageEvent.filterCustomersByComingBirth(),
              ),
          text: '생일 (30일 이내)',
          backgroundColor: ColorStyles.searchButtonColor,
          borderRadius: 10,
        ),
        height(5),
        RenderFilledButton(
          onPressed:
              () => viewModel.onEvent(
                SearchPageEvent.filterCustomersByUpcomingInsuranceAgeIncrease(),
              ),
          text: '상령일 잔여일 (10일~30일)',
          backgroundColor: ColorStyles.searchButtonColor,
          borderRadius: 10,
        ),
        height(5),
        RenderFilledButton(
          onPressed:
              () => viewModel.onEvent(
                SearchPageEvent.filterNoRecentHistoryCustomers(),
              ),
          text: '3개월 이내 미관리',
          backgroundColor: ColorStyles.searchButtonColor,
          borderRadius: 10,
        ),
      ],
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
