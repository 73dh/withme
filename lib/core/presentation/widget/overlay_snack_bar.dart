import '../core_presentation_import.dart';

class OverlaySnackBar extends StatelessWidget {
  final String message;
  final Color? backgroundColor; // 선택적 배경색
  final TextStyle? textStyle; // 선택적 텍스트 스타일

  const OverlaySnackBar({
    super.key,
    required this.message,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
            // M3 테마 색상
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style:
                textStyle ??
                textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
          ),
        ),
      ),
    );
  }
}
