import 'package:flutter/material.dart';
import 'package:withme/core/presentation/widget/show_overlay_snack_bar.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/domain/model/todo_model.dart';

import '../core_presentation_import.dart';

enum TodoDialogType { add, edit, complete }

Future<TodoModel?> showAddOrEditTodoDialog(
    BuildContext context, {
      TodoModel? currentTodo,
      TodoDialogType type = TodoDialogType.add,
    }) async {
  final controller = TextEditingController(text: currentTodo?.content ?? '');
  DateTime selectedDate = currentTodo?.dueDate ?? DateTime.now();

  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final isEditMode = currentTodo != null;
  final confirmText = switch (type) {
    TodoDialogType.add => '할일 추가',
    TodoDialogType.edit => '수정',
    TodoDialogType.complete => '완료',
  };

  Widget _buildTextField() => TextField(
    controller: controller,
    cursorColor: colorScheme.primary,
    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
    decoration: InputDecoration(
      labelText: confirmText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    ),
  );

  Widget _buildDatePicker() => Row(
    children: [
      Text('날짜:', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
      const SizedBox(width: 6),
      Text(
        selectedDate.formattedBirth,
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
      ),
      const Spacer(),
      TextButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) => Theme(data: theme.copyWith(colorScheme: colorScheme), child: child!),
          );
          if (picked != null) {
            selectedDate = picked;
            (context as Element).markNeedsBuild();
          }
        },
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
        child: const Text('날짜 선택'),
      ),
    ],
  );

  Widget _buildActionButton({required String label, required VoidCallback onPressed, Color? bg, Color? fg}) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg ?? colorScheme.primary,
        foregroundColor: fg ?? colorScheme.onPrimary,
        minimumSize: const Size(80, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  return await showDialog<TodoModel>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  Text(
                    confirmText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(),
                  const SizedBox(height: 12),
                  _buildDatePicker(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  label: '취소',
                  bg: colorScheme.surfaceContainerHighest,
                  fg: colorScheme.onSurfaceVariant,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                _buildActionButton(
                  label: confirmText,
                  onPressed: () {
                    final todoText = controller.text.trim();
                    if (todoText.isEmpty) {
                      showOverlaySnackBar(context, '할 일을 입력하세요');
                      return;
                    }
                    final newTodo = isEditMode
                        ? currentTodo.copyWith(content: todoText, dueDate: selectedDate)
                        : TodoModel(content: todoText, dueDate: selectedDate);
                    Navigator.of(context).pop(newTodo);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
