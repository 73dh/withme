import '../core_presentation_import.dart';

class OverlaySnackBar extends StatelessWidget {
  final String message;

  const OverlaySnackBar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.deepOrangeAccent.withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
