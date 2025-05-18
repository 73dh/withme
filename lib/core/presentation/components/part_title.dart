import 'package:flutter/material.dart';

import '../../ui/text_style/text_styles.dart';

class PartTitle extends StatelessWidget {
  final String text;

  const PartTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            text,
            style: TextStyles.bold14.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
