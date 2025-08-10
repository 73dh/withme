import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/arrow_indicator.dart';

import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';

class CustomBarChart extends StatefulWidget {
  final Map<String, List<CustomerModel>> monthlyData;

  const CustomBarChart({super.key, required this.monthlyData});

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

  @override
  Widget build(BuildContext context) {
    final stats = _convertToStats(widget.monthlyData);
    final keys = stats.keys.toList()..sort();

    final maxY =
        stats.values
            .expand((map) => map.values)
            .fold<int>(0, (prev, element) => element > prev ? element : prev)
            .toDouble();

    // 간소화된 y축 레이블 (5개로 제한)
    final step = (maxY / 4).ceil(); // 최대 5개
    final yLabels =
        List.generate(5, (i) => step * i).toSet().toList()
          ..sort((a, b) => b.compareTo(a)); // 높은 수부터 내림차순

    return LayoutBuilder(
      builder: (context, constraint) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());

        return SizedBox(
          height: 300, // 세로 크기 줄임
          child: Row(
            children: [
              // 좁아진 y축
              SizedBox(
                width: 24,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      yLabels
                          .map(
                            (y) => Text(
                              y.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),

              // 차트
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: SizedBox(
                        width: keys.length * 60,
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            maxY: maxY + 1,
                            barGroups: List.generate(keys.length, (i) {
                              final key = keys[i];
                              final data = stats[key]!;
                              return BarChartGroupData(
                                x: i,
                                barsSpace: 4,
                                barRods: [
                                  BarChartRodData(
                                    toY: data['prospect']!.toDouble(),
                                    color: ColorStyles.barChartProspectColor,
                                    width: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  BarChartRodData(
                                    toY: data['contract']!.toDouble(),
                                    color: ColorStyles.barChartContractColor,
                                    width: 8,
                                    borderRadius: BorderRadius.circular(4),
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
                                        child: Text(
                                          keys[idx].substring(5),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: true),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.grey),
                                bottom: BorderSide(color: Colors.grey),
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
      },
    );
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
}
