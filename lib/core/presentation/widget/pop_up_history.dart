import 'package:withme/core/domain/core_domain_import.dart';
import 'package:withme/core/presentation/widget/show_histories.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/use_case/customer/update_searched_customers_use_case.dart';
import '../../../domain/use_case/history/add_history_use_case.dart';
import '../../../presentation/home/search/search_page_view_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/di_setup_import.dart';
import '../../di/setup.dart';
import '../core_presentation_import.dart';

Future<HistoryModel?> popupAddHistory({
  required BuildContext context,
  required List<HistoryModel> histories,
  required CustomerModel customer,
  SearchPageViewModel? viewModel,
  String? initContent,
}) async {
  final menuController = MenuController();
  final textController = TextEditingController(text: initContent ?? '');

  try {
    final content = await CommonDialog(
      menuController: menuController,
      textController: textController,
    ).showHistories(context, histories);

    if (content == null || content.trim().isEmpty) return null;

    if (content.trim() == HistoryContent.title.toString()) {
      if (context.mounted) {
        showOverlaySnackBar(context, '내용을 입력해 주세요');
      }
      return null;
    }

    final now = DateTime.now();
    final historyData = HistoryModel.toMapForHistory(
      content: content.trim(),
      registeredDate: now,
    );

    await getIt<HistoryUseCase>().execute(
      usecase: AddHistoryUseCase(
        userKey: UserSession.userId,
        customerKey: customer.customerKey,
        historyData: historyData,
      ),
    );

    // 화면 재갱신: 현재 필터 적용된 상태로 리스트 다시 불러오기
    if (viewModel != null) {
      await UpdateSearchedCustomersUseCase.call(viewModel);
    }

    return HistoryModel(content: content.trim(), contactDate: now);
  } catch (e) {
    debugPrint('popupAddHistory error: $e');
    return null;
  }
}
