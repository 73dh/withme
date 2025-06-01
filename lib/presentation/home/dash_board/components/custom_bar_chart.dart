import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../domain/domain_import.dart';

class CustomBarChart extends StatelessWidget {
  final Map<String, List<CustomerModel>> monthlyData;
  const CustomBarChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final stats = _convertToStats(monthlyData);
    final keys = stats.keys.toList()..sort();
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(keys.length, (i) {
            final key = keys[i];
            final data = stats[key]!;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data['prospect']!.toDouble(),
                  color: Colors.orange,
                  width: 8,
                ),
                BarChartRodData(
                  toY: data['contract']!.toDouble(),
                  color: Colors.blue,
                  width: 8,
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
                  return Text(keys[idx].substring(5)); // e.g., "2025-05" → "05"
                },
              ),
            ),
          ),
        ),
      ),
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
