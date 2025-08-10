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
    final bgColor = sex == '남'
        ? ColorStyles.manColor.withOpacity(0.15)
        : ColorStyles.womanColor.withOpacity(0.15);
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
          fontSize: iconSize * 0.5, // 아이콘 크기에 비례하는 폰트 크기
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
