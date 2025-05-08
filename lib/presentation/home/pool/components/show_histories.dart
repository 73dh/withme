import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/history_model.dart';

Future<HistoryModel> showHistories(BuildContext context, List<HistoryModel> histories) async {
 return await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 라운드 10
        ),
        backgroundColor: Colors.white,
        child: Container(
          width: 300, // 적당한 넓이 (필요 시 조절 가능)
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...histories.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.contactDate.formattedDate}: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text(e.content)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              FilledButton(onPressed: () {
              return  context.pop(HistoryModel(contactDate: DateTime.now(), content: '테스트'));
              }, child: Text('이력 추가')),
            ],
          ),
        ),
      );
    },
  );
}
