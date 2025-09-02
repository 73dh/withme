import 'package:flutter/material.dart';

import '../../../../core/domain/enum/payment_status.dart';
import '../../../../core/domain/enum/policy_state.dart';
import '../../../../core/utils/check_payment_status.dart';
import '../../../../core/utils/extension/number_format.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';
import '../components/render_table_cell_text.dart';

class PaymentSummaryTable extends StatelessWidget {
  final double cellWidth;
  final List<CustomerModel> customers;
  final TextStyle? textStyle;
  final Color? cellColor;

  const PaymentSummaryTable({
    super.key,
    required this.cellWidth,
    required this.customers,
    this.textStyle,
    this.cellColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final stats = _PaymentStats();

    for (final customer in customers) {
      for (final policy in customer.policies) {
        // ✅ policyState가 "정상"인 경우만 계산
        if (policy.policyState != PolicyStatus.keep.label) continue;
        final status = checkPaymentStatus(policy);
        final isMonthly = policy.paymentMethod == "월납"; // TODO: 실제 필드명 확인
        final premium =
            int.tryParse(policy.premium.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        if (isMonthly) {
          if (status == PaymentStatus.paid) {
            stats.monthlyPaidCount++;
            stats.monthlyPaidPremium += premium;
          } else if (status == PaymentStatus.paying) {
            stats.monthlyPayingCount++;
            stats.monthlyPayingPremium += premium;
          }
        } else {
          if (status == PaymentStatus.paid) {
            stats.singlePaidCount++;
            stats.singlePaidPremium += premium;
          } else if (status == PaymentStatus.paying) {
            stats.singlePayingCount++;
            stats.singlePayingPremium += premium;
          }
        }
      }
    }

    final headerColor = colorScheme.primaryContainer;
    final headerTextStyle = (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    final rowColor = colorScheme.surface.withValues(alpha: 0.8);
    final defaultTextStyle = textStyle ?? theme.textTheme.bodyMedium;

    String formatWon(int value) => "${numFormatter.format(value)}원";

    final rows = <TableRow>[
      TableRow(
        decoration: BoxDecoration(color: headerColor),
        children: [
          RenderTableCellText('구분', isHeader: true, style: headerTextStyle),
          RenderTableCellText('납입중', isHeader: true, style: headerTextStyle),
          RenderTableCellText('납입완료', isHeader: true, style: headerTextStyle),
        ],
      ),
      TableRow(
        decoration: BoxDecoration(color: rowColor),
        children: [
          RenderTableCellText('월납(건수)', style: defaultTextStyle),
          RenderTableCellText(
            '${stats.monthlyPayingCount}건',
            style: defaultTextStyle,
          ),
          RenderTableCellText(
            '${stats.monthlyPaidCount}건',
            style: defaultTextStyle,
          ),
        ],
      ),
      TableRow(
        decoration: BoxDecoration(color: rowColor),
        children: [
          RenderTableCellText('월납(보험료)', style: defaultTextStyle),
          RenderTableCellText(
            formatWon(stats.monthlyPayingPremium),
            style: defaultTextStyle,
          ),
          RenderTableCellText(
            formatWon(stats.monthlyPaidPremium),
            style: defaultTextStyle,
          ),
        ],
      ),
      TableRow(
        decoration: BoxDecoration(color: rowColor),
        children: [
          RenderTableCellText('일시납(건수)', style: defaultTextStyle),
          RenderTableCellText(
            '${stats.singlePayingCount}건',
            style: defaultTextStyle,
          ),
          RenderTableCellText(
            '${stats.singlePaidCount}건',
            style: defaultTextStyle,
          ),
        ],
      ),
      TableRow(
        decoration: BoxDecoration(color: rowColor),
        children: [
          RenderTableCellText('일시납(보험료)', style: defaultTextStyle),
          RenderTableCellText(
            formatWon(stats.singlePayingPremium),
            style: defaultTextStyle,
          ),
          RenderTableCellText(
            formatWon(stats.singlePaidPremium),
            style: defaultTextStyle,
          ),
        ],
      ),
    ];

    return RenderTable(
      columnWidths: {
        0: FixedColumnWidth(cellWidth * 1.5),
        1: FixedColumnWidth(cellWidth),
        2: FixedColumnWidth(cellWidth),
      },
      tableRows: rows,
    );
  }
}

class _PaymentStats {
  int monthlyPayingCount = 0;
  int monthlyPaidCount = 0;
  int monthlyPayingPremium = 0;
  int monthlyPaidPremium = 0;

  int singlePayingCount = 0;
  int singlePaidCount = 0;
  int singlePayingPremium = 0;
  int singlePaidPremium = 0;
}
