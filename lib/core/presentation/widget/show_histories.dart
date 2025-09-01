import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/components/custom_text_form_field.dart';
import 'package:withme/core/presentation/components/width_height.dart';
import 'package:withme/core/presentation/widget/history_button.dart';
import 'package:withme/core/presentation/widget/select_history_menu.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';
import 'package:withme/core/utils/extension/date_time.dart';
import 'package:withme/domain/model/history_model.dart';

import '../../const/duration.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    histories.sort((a, b) => a.contactDate.compareTo(b.contactDate));

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
                    color: colorScheme.surface, // backgroundColor
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      height(12),
                      Text(
                        '관리 이력',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      height(12),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.outlineVariant,
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
                                    e.contactDate.formattedBirth,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  height(2),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      e.content,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            '등록된 이력이 없습니다.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      height(10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _inputArea(context, setState, colorScheme),
                      ),
                      height(60),
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

  Widget _inputArea(
    BuildContext context,
    StateSetter setState,
    ColorScheme colorScheme,
  ) {
    final showTextField = textController.text.isEmpty;

    return Row(
      children: [
        if (!showTextField) _historyButton(setState, context),
        _historyMenu(setState),
        width(5),
        if (showTextField)
          Flexible(
            child: CustomTextFormField(
              focusNode: FocusNode(),
              controller: textController,
              hintText: '내용을 입력 하세요.',
              autoFocus: true,
              textStyle: TextStyle(color: colorScheme.onSurface),
              onCompleted: () => setState(() => textController.text.trim()),
            ),
          )

        else
          const Spacer(),
        width(5),
        FilledButton(
          onPressed: () {
            final input = textController.text.trim();
            if (input.isEmpty || input == HistoryContent.title.toString()) {
              showOverlaySnackBar(
                context,
                '내용을 입력해 주세요',
                backgroundColor: colorScheme.errorContainer,
                textColor: colorScheme.onErrorContainer,
              );
              return;
            }
            context.pop(input);
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
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
}
