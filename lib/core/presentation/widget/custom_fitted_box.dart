import '../core_presentation_import.dart';

class CustomFittedBox extends StatelessWidget {
  final String text;
  const CustomFittedBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return FittedBox(child: Text(text, textAlign: TextAlign.center));
  }
}
