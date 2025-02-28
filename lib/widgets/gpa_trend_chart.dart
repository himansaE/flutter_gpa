import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/course.dart';

class GPATrendChart extends StatelessWidget {
  final List<Course> courses;

  const GPATrendChart({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spots = _calculateGPATrend();

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('${value.toInt() + 1}'),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(value.toStringAsFixed(1)),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.5),
                  colorScheme.primary,
                ],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: 4,
        ),
      ),
    );
  }

  List<FlSpot> _calculateGPATrend() {
    final spots = <FlSpot>[];
    double totalPoints = 0;
    double totalCredits = 0;

    for (var i = 0; i < courses.length; i++) {
      final course = courses[i];
      totalPoints += course.gradePoints * course.credits;
      totalCredits += course.credits;
      spots.add(FlSpot(i.toDouble(), totalPoints / totalCredits));
    }

    return spots;
  }
}
