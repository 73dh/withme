import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/presentation/registration_sheet/registration_view_model.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/presentation/widget/show_add_todo_dialog.dart';
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
    this.onSelected, required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<TodoModel> todoList = viewModel.todoList;
    todoList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final TodoModel? nearestTodo = todoList.isNotEmpty ? todoList.first : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nearestTodo != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  nearestTodo.content,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '할 일 목록',
                icon: const Icon(Icons.expand_more),
                onSelected: onSelected,
                itemBuilder: (context) {
                  final List<PopupMenuEntry<String>> items = [];

                  for (int i = 0; i < todoList.length; i++) {
                    final todo = todoList[i];
                    items.add(
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${todo.dueDate.formattedDate} ${todo.content}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      // TODO: 완료 처리
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Text('완료, 관리이력 추가'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () async {
                                    // TODO: 삭제 처리
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '할 일 삭제',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (i != todoList.length - 1)
                              const PopupMenuDivider(),
                          ],
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
