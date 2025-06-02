import 'package:flutter/material.dart';

import '../../../../core/ui/core_ui_import.dart';

class RenderTableCellText extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool? isBarProspect;
  final bool? isBarContract;

  const RenderTableCellText(
    this.text, {
    super.key,
    this.isHeader = false,
    this.isBarProspect,
    this.isBarContract,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
          color:
              isBarProspect == true
                  ? ColorStyles.barChartProspectColor
                  : isBarContract == true
                  ? ColorStyles.barChartContractColor
                  : Colors.black87,
        ),
      ),
    );
  }
}
