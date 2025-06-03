import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/widget/history_button.dart';
import 'package:withme/core/presentation/widget/select_history_menu.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/history_model.dart';

import '../../ui/text_style/text_styles.dart';

class CommonDialog {
  final MenuController menuController;
  final TextEditingController textController;
  final scrollController = ScrollController();

  CommonDialog({required this.menuController, required this.textController});

  Future<String?> showHistories(
    BuildContext context,
    List<HistoryModel> histories,
  ) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AnimatedPadding(
              duration: AppDurations.duration100,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // 연한 검정색
                      blurRadius: 12, // 퍼짐 정도
                      offset: Offset(0, -4), // 위쪽에서 퍼지도록 설정
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      '관리이력',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        itemCount: histories.length,
                        itemBuilder: (_, index) {
                          final e = histories[index];
                          return Padding(
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
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _inputArea(
                        context,
                        setState,
                      ), // <- 여기에 TextField 들어 있음
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _inputArea(BuildContext context, StateSetter setState) {
    final showTextField = textController.text.isEmpty;

    return Row(
      children: [
        if (!showTextField) _historyButton(setState, context),
        _historyMenu(setState),
        width(5),
        if (showTextField) _buildTextField(setState) else const Spacer(),
        width(5),
        FilledButton(
          onPressed: () => context.pop(textController.text),
          child: const Text('추가'),
        ),
      ],
    );
  }

  HistoryButton _historyButton(StateSetter setState, BuildContext context) {
    return HistoryButton(
      menuController: menuController,
      textController: textController,
      onPressed: () => setState(() => Focus.of(context).requestFocus()),
    );
  }

  SelectHistoryMenu _historyMenu(StateSetter setState) {
    return SelectHistoryMenu(
      menuController: menuController,
      textController: textController,
      onTap: (textController) {
        setState(() => textController = textController);
      },
    );
  }

  Flexible _buildTextField(StateSetter setState) {
    return Flexible(
      child: CustomTextFormField(
        focusNode: FocusNode(),
        controller: textController,
        hintText: '내용을 입력 하세요.',
        autoFocus: true,
        onCompleted: () => setState(() => textController.text.trim()),
      ),
    );
  }
}
