import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

/// TextTheme의 fontSize를 보여주는 팝업 위젯
class TextThemeFontSizePopup extends StatelessWidget {
  final TextTheme textTheme;

  const TextThemeFontSizePopup({super.key, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Map<String, TextStyle?> styles = {
      '홍길동 displayLarge': textTheme.displayLarge,
      '홍길동 displayMedium': textTheme.displayMedium,
      '홍길동 displaySmall': textTheme.displaySmall,
      '홍길동 headlineLarge': textTheme.headlineLarge,
      '홍길동 headlineMedium': textTheme.headlineMedium,
      '홍길동 headlineSmall': textTheme.headlineSmall,
      '홍길동 titleLarge': textTheme.titleLarge,
      '홍길동 titleMedium': textTheme.titleMedium,
      '홍길동 titleSmall': textTheme.titleSmall,
      '홍길동 bodyLarge': textTheme.bodyLarge,
      '홍길동 bodyMedium': textTheme.bodyMedium,
      '홍길동 bodySmall': textTheme.bodySmall,
      '홍길동 labelLarge': textTheme.labelLarge,
      '홍길동 labelMedium': textTheme.labelMedium,
      '홍길동 labelSmall': textTheme.labelSmall,
    };

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        'TextTheme Font Sizes',
        style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: styles.entries.map((entry) {
            final style = entry.value?.copyWith(color: colorScheme.onSurface) ??
                TextStyle(color: colorScheme.onSurface);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${entry.key}: ${style.fontSize ?? 'null'}',
                style: style,
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
