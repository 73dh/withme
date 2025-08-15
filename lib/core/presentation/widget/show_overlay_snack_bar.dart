import '../core_presentation_import.dart';
import 'overlay_snack_bar.dart';
import '../core_presentation_import.dart';
import 'overlay_snack_bar.dart';

void showOverlaySnackBar(
    BuildContext context,
    String message, {
      Duration duration = const Duration(seconds: 2),
      Color? backgroundColor, // 선택적 배경색
      Color? textColor,       // 선택적 텍스트 색
    }) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: OverlaySnackBar(
            message: message,
            backgroundColor: backgroundColor ?? colorScheme.errorContainer, // M3 surfaceVariant → surfaceContainerHighest
            textStyle: textTheme.bodyMedium?.copyWith(
              color: textColor ?? colorScheme.onSurface,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(duration, () {
    entry.remove();
  });
}
