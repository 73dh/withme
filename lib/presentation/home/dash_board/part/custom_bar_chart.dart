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

    // y축 최대값 계산 (차트 스케일 맞춤용)
    final maxY =
        stats.values
            .expand((map) => map.values)
            .fold<int>(0, (prev, element) => element > prev ? element : prev)
            .toDouble();

    // y축 숫자 리스트 (0부터 maxY까지 정수단위)
    final yLabels = List.generate(maxY.toInt() + 1, (index) => index);

    return LayoutBuilder(
      builder: (context, constraint) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());

        return SizedBox(
          height: 280,
          child: Row(
            children: [
              // 고정 y축 영역
              SizedBox(
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      yLabels.reversed
                          .map(
                            (y) => Text(
                              y.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),

              // 차트 + 스크롤 영역
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: SizedBox(
                        width: keys.length * 60,
                        height: 280,
                        child: BarChart(
                          BarChartData(
                            maxY: maxY + 1,
                            // 약간 여유 줌
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
                                        child: Text(keys[idx].substring(5)),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ), // y축 직접 구현했으니 숨김
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.grey),
                                bottom: BorderSide(color: Colors.grey),
                              ),
                            ),
                            barTouchData: BarTouchData(enabled: false),
                          ),
                        ),
                      ),
                    ),
                    if (showLeftArrow)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: ArrowIndicator(isRight: false),
                        // child: _arrowOverlay(isLeft: true),
                      ),
                    if (showRightArrow)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: ArrowIndicator(isRight: true),
                        // child: _arrowOverlay(isLeft: false),
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
