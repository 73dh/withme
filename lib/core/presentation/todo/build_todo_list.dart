import 'package:withme/core/presentation/components/todo_count_icon.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import '../../../domain/domain_import.dart';
import '../../../domain/model/customer_model.dart';
import '../../../domain/model/todo_model.dart';
import '../../presentation/core_presentation_import.dart';
import 'todo_view_model.dart';

class BuildTodoList extends StatefulWidget {
  final TodoViewModel viewModel;
  final CustomerModel? customer;
  final void Function(String)? onSelected;
  final VoidCallback onPressed;
  final void Function(TodoModel) onDeleteTodo;
  final void Function(TodoModel) onUpdateTodo;
  final void Function(TodoModel) onCompleteTodo;
  final Color? textColor;

  const BuildTodoList({
    super.key,
    required this.viewModel,
    this.customer,
    this.onSelected,
    required this.onPressed,
    required this.onDeleteTodo,
    required this.onUpdateTodo,
    required this.onCompleteTodo,
    this.textColor,
  });

  @override
  State<BuildTodoList> createState() => _BuildTodoListState();
}

class _BuildTodoListState extends State<BuildTodoList> {
  late List<TodoModel> todoList;

  @override
  void initState() {
    super.initState();
    todoList = widget.viewModel.todoList;
    widget.viewModel.addListener(_onTodoChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onTodoChanged);
    super.dispose();
  }

  void _onTodoChanged() {
    if (!mounted) return;
    setState(() {
      todoList = widget.viewModel.todoList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveTextColor = widget.textColor ?? colorScheme.onSurface;

    if (todoList.isEmpty) {
      return IconButton(
        icon: Icon(
          Icons.add_circle_outline_outlined,
          color: colorScheme.primary,
        ),
        tooltip: '할 일 추가',
        onPressed: widget.onPressed,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTodoText(effectiveTextColor),
              _buildPopupMenu(effectiveTextColor, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodoText(Color textColor) {
    print('todoList: ${widget.viewModel.todoList}');
    return Flexible(
      child: SizedBox(
        width: 100,
        child: StreamTodoText(
          todoList: widget.viewModel.todoList,
          // todoList,
          sex: widget.customer?.sex ?? '',
        ),
      ),
    );
  }

  Widget _buildPopupMenu(Color textColor, ColorScheme colorScheme) {
    return GestureDetector(
      onTapDown: (details) async {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final Offset position = details.globalPosition + const Offset(0, 20);

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromRect(
            position & const Size(40, 40),
            Offset.zero & overlay.size,
          ),
          items: buildTodoMenuItems(textColor, colorScheme),
          elevation: 8,
        );

        if (selected != null) {
          widget.onSelected?.call(selected);
        }
      },
      // child: TodoCountIcon(todos: todoList, sex: widget.customer?.sex ?? ''),
      child: TodoCountIcon(todos: widget.viewModel.todoList, sex: widget.customer?.sex ?? ''),
    );
  }

  List<PopupMenuEntry<String>> buildTodoMenuItems(
    Color textColor,
    ColorScheme colorScheme,
  ) {
    final items = <PopupMenuEntry<String>>[];

    for (final todo in todoList) {
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: _buildTodoMenuItem(todo, textColor, colorScheme),
        ),
      );
    }

    // 추가 버튼
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

  Widget _buildTodoMenuItem(
    TodoModel todo,
    Color textColor,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodoTitle(todo, colorScheme),
          _buildTodoActions(todo, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTodoTitle(TodoModel todo, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: GestureDetector(
        onTap: () => widget.onUpdateTodo(todo),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '[${todo.dueDate.formattedMonthAndDate}] ',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(
                text: todo.content,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoActions(TodoModel todo, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () => widget.onCompleteTodo(todo),
          icon: Icon(
            Icons.check_circle_outline,
            size: 15,
            color: colorScheme.primary,
          ),
          label: Text(
            '완료 (이력추가)',
            style: TextStyle(fontSize: 13, color: colorScheme.primary),
          ),
          style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
        ),
        TextButton.icon(
          onPressed: () => widget.onDeleteTodo(todo),
          icon: Icon(Icons.delete_outline, size: 15, color: colorScheme.error),
          label: Text(
            '취소 (삭제)',
            style: TextStyle(fontSize: 13, color: colorScheme.error),
          ),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
        ),
      ],
    );
  }
}
