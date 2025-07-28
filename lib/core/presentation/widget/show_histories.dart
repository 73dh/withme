import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/presentation/widget/history_button.dart';
import 'package:withme/core/presentation/widget/select_history_menu.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/history_model.dart';

import '../../domain/core_domain_import.dart';

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
      context: Overlay.of(context).context,
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 최소 크기 유지
                    children: [
                      height(12),
                      const Text(
                        '관리 이력',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height(12),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),
                      if (histories.isNotEmpty)
                        Flexible(
                          child: ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: histories.length,
                            separatorBuilder: (_, __) => height(8),
                            itemBuilder: (_, index) {
                              final e = histories[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    e.contactDate.formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  height(2),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      e.content,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            '등록된 이력이 없습니다.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      height(10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _inputArea(context, setState),
                      ),
                      height(20),
                    ],
                  ),
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
          onPressed: () {
            final input = textController.text.trim();
            if (input.isEmpty || input == HistoryContent.title.toString()) {
              showOverlaySnackBar(context, '내용을 입력해 주세요');
              return; // ✅ 닫지 않고 종료
            }
            context.pop(input); // ✅ 유효한 경우만 닫기
          },
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
