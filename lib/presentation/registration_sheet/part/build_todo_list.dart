import 'package:withme/core/presentation/components/stream_todo_text.dart';
import 'package:withme/core/presentation/components/blinking_toggle_icon.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/presentation/registration_sheet/registration_view_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_add_todo_dialog.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/todo_model.dart';
import '../registration_event.dart';

class BuildTodoList extends StatelessWidget {
  final RegistrationViewModel viewModel;
  final CustomerModel? customer;
  final void Function(String)? onSelected;
  final VoidCallback onPressed;

  const BuildTodoList({
    super.key,
    required this.viewModel,
    this.customer,
    this.onSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<TodoModel> todoList = viewModel.todoList;
    // todoList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    // final TodoModel? nearestTodo = todoList.isNotEmpty ? todoList.first : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SizedBox(
                  width: 80,
                  child: StreamTodoText(todoList: todoList),
                ),
              ),
              if (todoList.isNotEmpty)
                PopupMenuButton<String>(
                  tooltip: '할 일 목록',
                  icon:Stack(
    alignment: Alignment.center,
    children: [
     Icon(Icons.circle, size: 25, color: ColorStyles.badgeColor),
    Text(
    '${todoList.length}',
    style: const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
                  onSelected: onSelected,
                  itemBuilder: (context) {
                    final List<PopupMenuEntry<String>> items = [];

                    for (int i = 0; i < todoList.length; i++) {
                      final todo = todoList[i];
                      items.add(
                        PopupMenuItem<String>(
                          enabled: false,
                          padding: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 4,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorStyles.todoBoxColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${todo.dueDate.formattedBirth} ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        TextSpan(
                                          text: todo.content,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        // TODO: 완료 처리
                                      },
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        size: 15,
                                      ),
                                      label: const Text(
                                        '완료 (이력추가)',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        // TODO: 삭제 처리
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 15,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        '취소 (삭제)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.red,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    items.add(
                      const PopupMenuItem<String>(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 6),
                            Text('할 일 추가'),
                          ],
                        ),
                      ),
                    );

                    return items;
                  },
                ),
            ],
          ),
        ),
        if (todoList.isEmpty)
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '할 일 추가',
            onPressed: onPressed,
          ),
      ],
    );
  }
}
