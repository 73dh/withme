import 'package:withme/core/domain/core_domain_import.dart';
import 'package:withme/core/presentation/components/customer_item.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/presentation/customer/screen/customer_screen.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/presentation/widget/show_bottom_sheet_with_draggable.dart';
import '../../../../domain/use_case/customer/update_searched_customers_use_case.dart';
import '../../../registration/screen/registration_screen.dart';
import '../search_page_view_model.dart';

/// 고객 목록 리스트 뷰
class CustomerListView extends StatelessWidget {
  final List<CustomerModel> customers; // 필터링된 고객 리스트
  final SearchPageViewModel viewModel; // 검색 뷰모델
  final String userKey; // 현재 사용자 키

  const CustomerListView({
    super.key,
    required this.customers,
    required this.viewModel,
    required this.userKey,
  });

  @override
  Widget build(BuildContext context) {
    // 하단 여백 설정 (FAB와 겹치지 않도록)
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;

    // 고객 키들을 문자열로 결합하여 리스트 상태 키로 사용
    final customersKey = customers.map((e) => e.customerKey).join(',');

    return AnimatedSwitcher(
      duration: AppDurations.duration300,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child:
          customers.isEmpty
              // 조건에 맞는 고객이 없을 때
              ? Center(
                key: const ValueKey('empty'),
                child: Column(
                  children: [
                    height(200),
                    const AnimatedText(text: '조건에 맞는 고객이 없습니다.'),
                  ],
                ),
              )
              // 조건에 맞는 고객이 있을 때
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

                    // 보험이 없는 경우: 잠재 고객 아이템
                    // 보험이 있는 경우: 기존 고객 아이템
                    final item =
                        customer.policies.isEmpty
                            ? _buildProspectItem(context, customer)
                            : _buildCustomerItem(context, customer);

                    // 슬라이드 및 페이드 애니메이션 효과 적용
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

  /// 잠재 고객(보험 없음) 아이템 생성
  Widget _buildProspectItem(BuildContext context, CustomerModel customer) {
    return GestureDetector(
      onTap: () async {
        // 고객 상세화면 (모달 시트)
        await showBottomSheetWithDraggable(
          context: context,
          builder:
              (scrollController) => RegistrationScreen(customer: customer),
          onClosed: () async {
            // 닫힌 후 검색 결과 다시 갱신
            await UpdateSearchedCustomersUseCase.call(viewModel);
            await Future.delayed(const Duration(milliseconds: 200));
          },
        );
      },
      child: ProspectItem(
        userKey: userKey,
        customer: customer,
        onTap: (histories) async {
          final newHistory = await popupAddHistory(
            context: context,
            histories: histories,
            customer: customer,
            viewModel: viewModel,
            initContent: HistoryContent.title.toString(),
          );

          if (newHistory != null) {
            debugPrint('히스토리 추가됨: ${newHistory.content}');
          }
        },
      ),
    );
  }

  /// 기존 고객(보험 있음) 아이템 생성
  Widget _buildCustomerItem(BuildContext context, CustomerModel customer) {
    return GestureDetector(
      onTap: () async {
        // 고객 상세화면 (모달 시트)
        await showBottomSheetWithDraggable(
          context: context,
          builder: (scrollController) => CustomerScreen(customer: customer),
          onClosed: () async {
            // 닫힌 후 검색 결과 다시 갱신
            await UpdateSearchedCustomersUseCase.call(viewModel);
            await Future.delayed(const Duration(milliseconds: 200));
          },
        );
      },
      child: CustomerItem(
        customer: customer,
        onTap: (histories) async {
          final newHistory = await popupAddHistory(
            context: context,
            histories: histories,
            customer: customer,
            viewModel: viewModel,
            initContent: HistoryContent.title.toString(),
          );

          if (newHistory != null) {
            debugPrint('히스토리 추가됨: ${newHistory.content}');
          }
        },
      ),
    );
  }
}
