import 'package:flutter/material.dart';

import '../../ui/text_style/text_styles.dart';

class PartTitle extends StatelessWidget {
  final String text;
  final double padding ;

  const PartTitle({super.key, required this.text, this.padding = 6});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding:  EdgeInsets.symmetric(vertical: padding),
          child: Text(
            text,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
