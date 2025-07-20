import '../core_presentation_import.dart';
import 'overlay_snack_bar.dart';

void showOverlaySnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);

  final entry = OverlayEntry(builder: (_) => OverlaySnackBar(message: message));

  overlay.insert(entry);

  Future.delayed(duration, () {
    entry.remove();
  });
}
