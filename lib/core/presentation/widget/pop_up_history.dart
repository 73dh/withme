import 'package:withme/core/presentation/widget/show_histories.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/history_model.dart';

void popupHistory(
    List<HistoryModel> histories,
    CustomerModel prospect,
    ) async {
  String? content = await CommonDialog(
    menuController: menuController,
    textController: textController,
  ).showHistories(context, histories);
  if (content != null) {
    Map<String, dynamic> historyData = HistoryModel.toMapForHistory(
      content: content,
    );
    viewModel.onEvent(
      ProspectListEvent.addHistory(
        customerKey: prospect.customerKey,
        historyData: historyData,
      ),
    );
  }
}