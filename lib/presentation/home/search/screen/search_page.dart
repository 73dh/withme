import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/ui/icon/const.dart';
import 'package:withme/presentation/home/customer_list/components/customer_item.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('검색 결과')),
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: viewModel,
            builder: (BuildContext context, Widget? child) {
              return ListView.builder(
                itemCount: viewModel.state.searchedCustomers.length,
                itemBuilder: (context, index) {
                  return Text(viewModel.state.searchedCustomers[index].name);
                },
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
  }

  ListView _searchConditionBox(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      children: [
        _dragUpBar(),
        height(16),
        RenderFilledButton(
          onPressed: () {
            viewModel.isThisMonthBirth();
          },
          text: '이달 생일 (오늘 포함 도래예정)',
          backgroundColor: ColorStyles.searchButtonColor,
          borderRadius: 10,
        ),
        height(5),
        RenderFilledButton(
          onPressed: () {
            viewModel.filterCustomersByUpcomingInsuranceAgeIncrease;
          },
          text: '상령일 30일~60일 사이',
          backgroundColor: ColorStyles.searchButtonColor,
          borderRadius: 10,
        ),
        height(5),
        RenderFilledButton(
          onPressed: () {
            viewModel.isThisMonthBirth();
          },
          text: '직전 3개월 이내 관리이력 없음',
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
