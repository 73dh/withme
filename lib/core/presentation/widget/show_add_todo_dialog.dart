import 'package:withme/domain/model/todo_model.dart';

import '../core_presentation_import.dart';

void showAddTodoDialog(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  DateTime selectedDate = DateTime.now();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('할 일 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: '할 일 내용'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('날짜: '),
                Text(
                  _formatDate(selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                    }
                  },
                  child: const Text('날짜 선택'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final todoText = controller.text.trim();
              if (todoText.isNotEmpty) {
                final newTodo = TodoModel(content: todoText, dueDate: selectedDate);

                // TODO: 실제 저장 로직 (ViewModel 등으로 전달)
                debugPrint('추가됨: ${newTodo.content} @ ${newTodo.dueDate}');
              }
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      );
    },
  );
}

String _formatDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}