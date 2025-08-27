import '../core_presentation_import.dart';

class SexIcon extends StatelessWidget {
  final double size;
  final String sex;
  final String backgroundImagePath;

  const SexIcon({
    super.key,
    this.size = 37,
    required this.sex,
    required this.backgroundImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipOval(
      child: Image.asset(
        backgroundImagePath,
        fit: BoxFit.cover,
        width: size,
        height: size,
        color: getSexIconColor(sex, colorScheme).withValues(alpha: 0.6),
      ),
    );
  }
}
