import 'package:withme/core/domain/core_domain_import.dart';
import 'package:withme/core/presentation/widget/show_histories.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/use_case/history/add_history_use_case.dart';
import '../../data/fire_base/user_session.dart';
import '../../di/di_setup_import.dart';
import '../../di/setup.dart';
import '../core_presentation_import.dart';

Future<HistoryModel?> popupAddHistory(
  BuildContext context,
  List<HistoryModel> histories,
  CustomerModel prospect,
  String? initContent,
) async {
  final MenuController menuController = MenuController();
  final TextEditingController textController = TextEditingController(
    text: initContent,
  );

  try {
    String? content = await CommonDialog(
      menuController: menuController,
      textController: textController,
    ).showHistories(context, histories);

    if (content == null) return null;
    if (textController.text == HistoryContent.title.toString() &&
        context.mounted) {
      showOverlaySnackBar(context, '내용을 입력해 주세요');
      return null;
    }
    if (content.trim().isNotEmpty) {
      final now = DateTime.now();
      Map<String, dynamic> historyData = HistoryModel.toMapForHistory(
        content: content,
        registeredDate: DateTime.now(),
      );
      if (historyData.isNotEmpty) {
        await getIt<HistoryUseCase>().execute(
          usecase: AddHistoryUseCase(
            userKey: UserSession.userId,
            customerKey: prospect.customerKey,
            historyData: historyData,
          ),
        );
        return HistoryModel(content: content, contactDate: now); // 🎯 성공 시 true
      }
    }
    return null; // 사용자가 취소했거나 내용 없음
  } catch (e) {
    debugPrint('popupAddHistory error: $e');
    return null;
  }
}
