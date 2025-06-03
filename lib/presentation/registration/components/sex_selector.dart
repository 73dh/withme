import 'package:flutter/material.dart';

class SexSelector extends StatelessWidget {
  final String? sex;
  final bool isReadOnly;
  final void Function(String?)? onChanged;
  const SexSelector({super.key, required this.sex, required this.isReadOnly, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
      ['남', '여'].map((label) {
        return RadioMenuButton<String>(
          value: label,
          groupValue: sex,
          onChanged:onChanged,
          child: Text(label == '남' ? '남성' : '여성'),
        );
      }).toList(),
    );
  }
}
