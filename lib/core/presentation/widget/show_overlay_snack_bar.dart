import '../core_presentation_import.dart';
import 'overlay_snack_bar.dart';

void showOverlaySnackBar(
    BuildContext context,
    String message, {
      Duration duration = const Duration(seconds: 2),
    }) {
  final overlay = Overlay.of(context, rootOverlay: true);

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 5,
      child: Material(
        color: Colors.transparent,
        child: Center(child: OverlaySnackBar(message: message)),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(duration, () {
    entry.remove();
  });
}

