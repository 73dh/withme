import 'package:withme/core/presentation/todo/todo_view_model.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import '../../../domain/model/todo_model.dart';
import '../components/todo_count_icon.dart';
import '../core_presentation_import.dart';
import '../widget/show_add_todo_dialog.dart';

class ManageTodoList extends StatefulWidget {
  final TodoViewModel viewModel;
  final String customerSex; // '남' 또는 '여'
  final Color? textColor;
  final VoidCallback onAddPressed;

  const ManageTodoList({
    super.key,
    required this.viewModel,
    required this.customerSex,
    required this.onAddPressed,
    this.textColor,
  });

  @override
  State<ManageTodoList> createState() => _ManageTodoListState();
}

class _ManageTodoListState extends State<ManageTodoList> {
  @override
  void initState() {
    super.initState();
    // ViewModel 변경시 UI 갱신
    widget.viewModel.addListener(_onTodoChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onTodoChanged);
    super.dispose();
  }

  void _onTodoChanged() {
    if (!mounted) return;
    setState(() {}); // ViewModel.todoList를 직접 참조
  }

  @override
  Widget build(BuildContext context) {
    final todoList = widget.viewModel.todoList; // ✅ 직접 참조
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveTextColor =
        widget.textColor ??
        (widget.customerSex == '남'
            ? colorScheme.primary
            : colorScheme.secondary);

    if (todoList.isEmpty) {
      return IconButton(
        icon: Icon(
          Icons.add_circle_outline_outlined,
          color: effectiveTextColor,
        ),
        tooltip: '할 일 추가',
        onPressed: widget.onAddPressed,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Row(
            children: [
              StreamTodoText(
                todoList: todoList.map((t) => t.content).toList(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: getSexIconColor(widget.customerSex, colorScheme),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTapDown: (details) async {
                  final overlay =
                      Overlay.of(context).context.findRenderObject()!
                          as RenderBox;
                  final position = details.globalPosition + const Offset(0, 20);

                  final selected = await showMenu<String>(
                    context: context,
                    position: RelativeRect.fromRect(
                      position & const Size(40, 40),
                      Offset.zero & overlay.size,
                    ),
                    items: _buildTodoMenuItems(
                      effectiveTextColor,
                      colorScheme,
                      todoList,
                    ),
                    elevation: 8,
                  );

                  if (selected != null && selected == 'add') {
                    widget.onAddPressed();
                  }
                },
                child: TodoCountIcon(todos: todoList, sex: widget.customerSex),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildTodoMenuItems(
    Color textColor,
    ColorScheme colorScheme,
    List<TodoModel> todoList,
  ) {
    final items = <PopupMenuEntry<String>>[];

    for (final todo in todoList) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final edited = await showAddOrEditTodoDialog(
                    context,
                    currentTodo: todo,
                  );
                  if (edited != null) {
                    await widget.viewModel.addOrUpdateTodo(
                      currentTodo: todo,
                      newTodo: edited,
                    );
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '[${todo.dueDate.formattedMonthAndDate}] ',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      TextSpan(
                        text: todo.content,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final edited = await showAddOrEditTodoDialog(
                        context,
                        currentTodo: todo,
                        type: TodoDialogType.complete,
                      );
                      if (edited != null) {
                        await widget.viewModel.completeTodo(todo, edited);
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: 15,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      '완료 (이력추가)',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await widget.viewModel.deleteTodo(todo);
                      if (mounted) Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: 15,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      '취소 (삭제)',
                      style: TextStyle(fontSize: 13, color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    items.add(
      PopupMenuItem<String>(
        value: 'add',
        child: Row(
          children: [
            const Spacer(),
            Icon(
              Icons.add_circle_outline_outlined,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '할 일 추가',
              style: TextStyle(fontSize: 14, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );

    return items;
  }
}
