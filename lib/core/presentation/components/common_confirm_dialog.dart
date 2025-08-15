import '../core_presentation_import.dart';
import '../core_presentation_import.dart';

class CommonConfirmDialog extends StatelessWidget {
  final String text;
  final List<TextSpan> textSpans;
  final String confirmButtonText;
  final String cancelButtonText;
  final Future<void> Function() onConfirm;

  const CommonConfirmDialog({
    super.key,
    required this.text,
    required this.textSpans,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      // backgroundColor: Colors.transparent,
      child: Container(
        // color: colorScheme.surface,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(textSpans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: textSpans),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel Button
                if (cancelButtonText.isNotEmpty)
                  FilledButton(
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.of(context).pop(false);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                    child: Text(cancelButtonText, style: textTheme.labelLarge),
                  ),
                const SizedBox(width: 12),
                // Confirm Button
                FilledButton(
                  onPressed: () async {
                    await onConfirm();
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    confirmButtonText,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
