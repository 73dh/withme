import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/widget/history_button.dart';
import 'package:withme/core/presentation/widget/select_history_menu.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/history_model.dart';

class CommonDialog {
  MenuController menuController;
  TextEditingController textController;

  CommonDialog({required this.menuController, required this.textController});

  Future<String?> showHistories(
    BuildContext context,
    List<HistoryModel> histories,
  ) async {
    return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 라운드 10
              ),
              backgroundColor: Colors.white,
              child: Container(
                width: 300, // 적당한 넓이 (필요 시 조절 가능)
                padding: const EdgeInsets.all(20),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(child: Text(e.content)),
                          ],
                        ),
                      ),
                    ),
                    height(10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (textController.text.isNotEmpty)
                          _historyButton(setState, context),
                        _historyMenu(setState),
                        if (textController.text.isEmpty) _etcInput(setState),
                        width(5),
                        FilledButton(
                          onPressed: () {
                            context.pop(textController.text);
                          },
                          child: const Text('추가'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  HistoryButton _historyButton(StateSetter setState, BuildContext context) {
    return HistoryButton(
      menuController: menuController,
      textController: textController,
      onPressed:
          () => setState(() {
            Focus.of(context).requestFocus();
          }),
    );
  }

  SelectHistoryMenu _historyMenu(StateSetter setState) {
    return SelectHistoryMenu(
      menuController: menuController,
      textController: textController,
      onTap: (textController) {
        setState(() {
          textController = textController;
        });
      },
    );
  }

  Expanded _etcInput(StateSetter setState) {
    return Expanded(
      child: CustomTextFormField(
        focusNode: FocusNode(),
        controller: textController,
        hintText: '내용을 입력 하세요.',
        autoFocus: true,
        onCompleted: () {
          setState(() {
            textController.text.trim();
          });
        },
      ),
    );
  }
}
