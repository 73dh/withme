import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../../core/di/setup.dart';

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
      appBar: AppBar(title: const Text('Next Screen')),
      body: Stack(
        children: [
          const Center(child: Text('Main Content')),
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
                      return ListView(
                        controller: scrollController,
                        children: [
                          _dragUpBar(),
                          height(16),
                          ElevatedButton(
                            onPressed: () {
                              final searchedCustomers =
                                  viewModel.state.customers
                                      .where((e) => e.sex == '남')
                                      .toList();
                              print(searchedCustomers);
                              final searchedHistories =
                                  viewModel.state.histories
                                      .where((e) => e.content.contains('신'))
                                      .toList();
                              print(searchedHistories);
                            },
                            child: const Text('남자'),
                          ),
                          // 여기에 검색 옵션 등을 추가 가능
                        ],
                      );
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
