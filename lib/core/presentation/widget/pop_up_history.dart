import 'package:flutter/material.dart';
import 'package:withme/core/presentation/widget/show_histories.dart';

import '../../../domain/model/customer_model.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/use_case/history/add_history_use_case.dart';
import '../../../domain/use_case/history_use_case.dart';
import '../../di/setup.dart';

Future<void> popupAddHistory(
  BuildContext context,
  List<HistoryModel> histories,
  CustomerModel prospect,
  String initContent,
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
    if (content != null) {
      Map<String, dynamic> historyData = HistoryModel.toMapForHistory(
        content: content,
      );
      if(historyData.isNotEmpty){
        getIt<HistoryUseCase>().execute(
          usecase: AddHistoryUseCase(
            userKey: 'user1',
            customerKey: prospect.customerKey,
            historyData: historyData,
          ),
        );
      }else{
        null;
      }
    }
  } finally {
    // textController.dispose();
  }
}
