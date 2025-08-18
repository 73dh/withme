import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/arrow_indicator.dart';

import '../../../../domain/domain_import.dart';

class CustomBarChart extends StatefulWidget {
  final Map<String, List<CustomerModel>> monthlyData;
  final Color? prospectBarColor;
  final Color? contractBarColor;
  final TextStyle? labelStyle;

  const CustomBarChart({
    super.key,
    required this.monthlyData,
    this.prospectBarColor,
    this.contractBarColor,
    this.labelStyle,
  });

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  final ScrollController _scrollController = ScrollController();
  bool showLeftArrow = false;
  bool showRightArrow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
  }

  void _updateArrows() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    setState(() {
      showLeftArrow = offset > 10;
      showRightArrow = offset < maxScroll - 10;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, Map<String, int>> _convertToStats(
    Map<String, List<CustomerModel>> monthlyData,
  ) {
    final Map<String, Map<String, int>> stats = {};
    for (final entry in monthlyData.entries) {
      final month = entry.key;
      final customers = entry.value;
      final prospectCount = customers.where((c) => c.policies.isEmpty).length;
      final contractCount = customers.fold(
        0,
        (sum, c) => sum + c.policies.length,
      );
      stats[month] = {'prospect': prospectCount, 'contract': contractCount};
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final stats = _convertToStats(widget.monthlyData);
    final keys = stats.keys.toList()..sort();

    final maxY =
        stats.values
            .expand((map) => map.values)
            .fold<int>(0, (prev, e) => e > prev ? e : prev)
            .toDouble();

    final prospectColor =
        widget.prospectBarColor ?? colorScheme.primary.withValues(alpha: 0.8);
    final contractColor =
        widget.contractBarColor ?? colorScheme.secondary.withValues(alpha: 0.8);
    final labelStyle =
        widget.labelStyle ??
        textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface,);

    return SizedBox(
      height: 300,
      child: Row(
        children: [
          // Y축 레이블
          SizedBox(
            width: 28,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final step = (maxY / 4).ceil();
                return Text('${step * (4 - i)}', style: labelStyle);
              }),
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: SizedBox(
                    width: keys.length * 60,
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY + 2,
                        barGroups: List.generate(keys.length, (i) {
                          final key = keys[i];
                          final data = stats[key]!;

                          return BarChartGroupData(
                            x: i,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(
                                toY: data['prospect']!.toDouble(),
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                                color: prospectColor,
                              ),
                              BarChartRodData(
                                toY: data['contract']!.toDouble(),
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                                color: contractColor,
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= 0 && idx < keys.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        keys[idx].substring(5),
                                        style: labelStyle,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                        ),
                        gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: colorScheme.outline.withValues(alpha: 0.3),
                                strokeWidth: 0.5,
                              ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(color: colorScheme.outline),
                            bottom: BorderSide(color: colorScheme.outline),
                          ),
                        ),
                        barTouchData: const BarTouchData(enabled: false),
                      ),
                    ),
                  ),
                ),
                if (showLeftArrow)
                  const Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: ArrowIndicator(isRight: false),
                  ),
                if (showRightArrow)
                  const Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: ArrowIndicator(isRight: true),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
