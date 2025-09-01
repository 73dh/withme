import 'package:firebase_auth/firebase_auth.dart';
import 'package:withme/core/di/setup.dart';

import '../../../../core/const/duration.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../home_grand_import.dart';
import '../components/policy_list_app_bar.dart';
import '../filter/filter_box.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final viewModel = getIt<SearchPageViewModel>();
  final userKey = FirebaseAuth.instance.currentUser?.uid;

  bool _isSearchingByName = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (userKey == null) {
      return Center(
        child: Text(
          '로그인 정보가 없습니다.',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
      );
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: colorScheme.surface, // Scaffold 배경 통일
          appBar:
              viewModel.state.currentSearchOption == SearchOption.filterPolicy
                  ? PolicyListAppBar(
                    count: viewModel.state.filteredPolicies.length,
                  )
                  : CustomerListAppBar(viewModel: viewModel),
          body: Stack(
            children: [
              AnimatedSwitcher(
                duration: AppDurations.duration300,
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: _buildSearchResultView(viewModel),
              ),
              AnimatedSwitcher(
                duration: AppDurations.duration300,
                child:
                    viewModel.state.currentSearchOption == null
                        ? Stack(
                          key: ValueKey(
                            'search_option-${viewModel.state.currentSearchOption}',
                          ),
                          children: [
                            Positioned(
                              top: 200,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search,
                                    color:
                                        colorScheme.primary, // 검색 아이콘에 theme 반영
                                  ),
                                  width(20),
                                  AnimatedText(
                                    text: '아래 조건을 선택하세요.',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(key: ValueKey('empty')),
              ),
              DraggableFilterSheet(
                isLoadingAllData: viewModel.state.isLoadingAllData,
                onExpandFetch: () {
                  viewModel.resetSearchOption();
                  viewModel.getAllData();
                },
                buildFilterOptions:
                    (scrollController) => FilterBox(
                      controller: scrollController,
                      viewModel: viewModel,
                      isSearchingByName: _isSearchingByName,
                      searchFocusNode: _searchFocusNode,
                      onToggleSearch: () {
                        setState(() {
                          _isSearchingByName = !_isSearchingByName;
                          viewModel.toggleNameSearch(_isSearchingByName);
                        });
                        if (!_isSearchingByName) {
                          viewModel.resetSearchOption();
                        }
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResultView(SearchPageViewModel viewModel) {
    final key = ValueKey(viewModel.state.currentSearchOption);

    if (viewModel.state.currentSearchOption == SearchOption.filterPolicy) {
      return Column(
        children: [
          Expanded(
            child: PolicyListView(
              key: key,
              policies: viewModel.state.filteredPolicies,
            ),
          ),
        ],
      );
    } else if (viewModel.state.currentSearchOption != null) {
      return CustomerListView(
        key: key,
        customers: viewModel.state.filteredCustomers,
        viewModel: viewModel,
        userKey: userKey ?? '',
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
