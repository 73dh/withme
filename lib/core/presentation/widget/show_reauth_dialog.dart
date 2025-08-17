import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
import 'package:flutter/material.dart';

Future<Map<String, String>?> showReauthDialog(
    BuildContext context, {
      required String email,
    }) async {
  final passwordController = TextEditingController();
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface, // 테마 적용
              border: Border.all(color: colorScheme.outline, width: 1.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '비밀번호를 입력하세요.',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                height(20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
                    height(10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        border: const UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
                height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'email': email.trim(),
                          'password': passwordController.text.trim(),
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('확인'),
                    ),
                    width(10),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outline),
                        minimumSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ],
                ),
                height(10),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
