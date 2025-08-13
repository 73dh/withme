import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';

class NameField extends StatelessWidget {
  final bool isReadOnly;
  final TextEditingController nameController;

  const NameField({
    super.key,
    required this.isReadOnly,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return isReadOnly
        ? Row(children: [Text(nameController.text, style: Theme.of(context).textTheme.displayLarge)])
        : CustomTextFormField(
          controller: nameController,
          hintText: '이름',
          autoFocus: true,
          onSaved: (text) => nameController.text = text.trim(),
        );
  }
}
