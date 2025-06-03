import 'package:flutter/material.dart';

import '../../../core/presentation/core_presentation_import.dart';

class NameField extends StatelessWidget {
  final bool isReadOnly;
  final TextEditingController nameController;
  const NameField({super.key, required this.isReadOnly, required this.nameController});

  @override
  Widget build(BuildContext context) {
      return isReadOnly
        ? Text('고객명: ${nameController.text}')
        : Expanded(
      child: CustomTextFormField(
        controller: nameController,
        hintText: '이름',
        autoFocus: true,
        validator: (text) => text.isEmpty ? '이름을 입력하세요' : null,
        onSaved: (text) => nameController.text = text.trim(),
      ),
    );
  }
}
