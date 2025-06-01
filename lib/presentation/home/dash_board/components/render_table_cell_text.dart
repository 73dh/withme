import 'package:flutter/material.dart';

class RenderTableCellText extends StatelessWidget {
  final String text;
  final bool isHeader;

  const RenderTableCellText(this.text, {super.key, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      alignment: Alignment.center,
      color: isHeader ? Colors.transparent : null,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
          color: Colors.black87,
        ),
      ),
    );
  }
}
