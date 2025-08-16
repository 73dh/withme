import '../../../domain/model/todo_model.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
import '../../../domain/model/todo_model.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class TodoCountIcon extends StatelessWidget {
  final List<TodoModel> todos;
  final double iconSize;
  final String sex;

  const TodoCountIcon({
    super.key,
    required this.todos,
    this.iconSize = 23,
    required this.sex,
  });

  @override
  Widget build(BuildContext context) {
    // 성별 색상 적용
    final bgColor = sex == '남'
        ? ColorStyles.manColor.withValues(alpha: 0.15)
        : ColorStyles.womanColor.withValues(alpha: 0.15);
    final textColor = sex == '남' ? ColorStyles.manColor : ColorStyles.womanColor;

    return Container(
      width: iconSize,
      height: iconSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        '${todos.length}',
        style: TextStyle(
          color: textColor,
          fontSize: iconSize * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
