import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> data;
  final String period;

  const ExpenseChart({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: _createSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _createSections() {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      final value = entry.value;
      final total = data.values.reduce((a, b) => a + b);
      final percentage = (value / total) * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: data.entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                color: Colors.blue,
              ),
              const SizedBox(width: 4),
              Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
            ],
          );
        }).toList(),
      ),
    );
  }
}