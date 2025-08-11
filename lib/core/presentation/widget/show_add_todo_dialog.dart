import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/todo_model.dart';

import '../core_presentation_import.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/todo_model.dart';
import '../core_presentation_import.dart';
enum TodoDialogType { add, edit, complete }
Future<TodoModel?> showAddOrEditTodoDialog(
    BuildContext context, {
      TodoModel? currentTodo,
      TodoDialogType type = TodoDialogType.add,
    }) async {
  final TextEditingController controller =
  TextEditingController(text: currentTodo?.content ?? '');
  DateTime selectedDate = currentTodo?.dueDate ?? DateTime.now();

  final isEditMode = currentTodo != null;
  final confirmText = () {
    switch (type) {
      case TodoDialogType.add:
        return '추가';
      case TodoDialogType.edit:
        return '수정';
      case TodoDialogType.complete:
        return '완료';
    }
  }();
  return await showDialog<TodoModel>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade500, width: 1.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 12.0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          // isEditMode ? '할 일 수정' : '할 일 추가',
                         confirmText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: controller,
                          decoration:  InputDecoration(
                            labelText: '$confirmText 내용',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('날짜:'),
                            const SizedBox(width: 6),
                            Text(
                              selectedDate.formattedBirth,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (picked != null) {
                                  selectedDate = picked;
                                  // UI 갱신
                                  (dialogContext as Element).markNeedsBuild();
                                }
                              },
                              child: const Text('날짜 선택'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: const Size(80, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () {
                          final todoText = controller.text.trim();
                          if (todoText.isNotEmpty) {
                            final newTodo = isEditMode
                                ? currentTodo.copyWith(
                              content: todoText,
                              dueDate: selectedDate,
                            )
                                : TodoModel(
                              content: todoText,
                              dueDate: selectedDate,
                            );

                            Navigator.of(dialogContext).pop(newTodo);
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(80, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // child: Text(isEditMode ? '수정' : '추가'),
                        child: Text(confirmText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

//
// Future<TodoModel?> showAddTodoDialog(BuildContext context) async {
//   final TextEditingController controller = TextEditingController();
//   DateTime selectedDate = DateTime.now();
//
//   return await showDialog(
//     context: context,
//     builder: (dialogContext) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         child: Stack(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 border: Border.all(color: Colors.grey.shade500, width: 1.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 20.0,
//                       horizontal: 12.0,
//                     ),
//                     child: Column(
//                       children: [
//                         const Text(
//                           '할 일 추가',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         TextField(
//                           controller: controller,
//                           decoration: const InputDecoration(
//                             labelText: '할 일 내용',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             const Text('날짜:'),
//                             const SizedBox(width: 6),
//                             Text(
//                               selectedDate.formattedBirth,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const Spacer(),
//                             TextButton(
//                               onPressed: () async {
//                                 final picked = await showDatePicker(
//                                   context: dialogContext,
//                                   initialDate: selectedDate,
//                                   firstDate: DateTime.now().subtract(
//                                     const Duration(days: 365),
//                                   ),
//                                   lastDate: DateTime.now().add(
//                                     const Duration(days: 365),
//                                   ),
//                                 );
//                                 if (picked != null) {
//                                   selectedDate = picked;
//                                   // rebuild to reflect new date
//                                   (dialogContext as Element).markNeedsBuild();
//                                 }
//                               },
//                               child: const Text('날짜 선택'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       FilledButton(
//                         onPressed: () => Navigator.of(dialogContext).pop(),
//                         style: FilledButton.styleFrom(
//                           backgroundColor: Colors.grey,
//                           minimumSize: const Size(80, 40),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text('취소'),
//                       ),
//                       const SizedBox(width: 10),
//                       FilledButton(
//                         onPressed: () {
//                           final todoText = controller.text.trim();
//                           if (todoText.isNotEmpty) {
//                             final newTodo = TodoModel(
//                               content: todoText,
//                               dueDate: selectedDate,
//                             );
//
//                             // TODO: 실제 저장 로직
//                             debugPrint(
//                               '추가됨: ${newTodo.content} @ ${newTodo.dueDate}',
//                             );
//
//                             Navigator.of(dialogContext).pop(newTodo);
//                           }
//                         },
//                         style: FilledButton.styleFrom(
//                           minimumSize: const Size(80, 40),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text('추가'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
