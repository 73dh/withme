import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';

class NameField extends StatelessWidget {
  final bool isReadOnly;
  final TextEditingController nameController;

  // 🔹 추가: 스타일 옵션
  final TextStyle? textStyle;
  final Color? fillColor;

  const NameField({
    super.key,
    required this.isReadOnly,
    required this.nameController,
    this.textStyle,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultTextStyle = textStyle ?? Theme.of(context).textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    final background = fillColor ?? colorScheme.surfaceContainerLowest.withAlpha(20);

    return isReadOnly
        ? Row(
      children: [
        Text(
          nameController.text,
          style: defaultTextStyle,
        ),
      ],
    )
        : CustomTextFormField(
      controller: nameController,
      hintText: '이름',
      autoFocus: true,
      textStyle: defaultTextStyle,
      fillColor: background,
      onSaved: (text) => nameController.text = text.trim(),
    );
  }
}

//
// class NameField extends StatelessWidget {
//   final bool isReadOnly;
//   final TextEditingController nameController;
//
//   const NameField({
//     super.key,
//     required this.isReadOnly,
//     required this.nameController,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return isReadOnly
//         ? Row(children: [Text(nameController.text, style: Theme.of(context).textTheme.displayLarge)])
//         : CustomTextFormField(
//           controller: nameController,
//           hintText: '이름',
//           autoFocus: true,
//           onSaved: (text) => nameController.text = text.trim(),
//         );
//   }
// }
