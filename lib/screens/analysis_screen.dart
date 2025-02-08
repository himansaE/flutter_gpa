import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/gpa_provider.dart';
import '../providers/grade_scale_provider.dart';
import '../models/course.dart';
import '../widgets/analysis_card.dart';
import '../widgets/gpa_trend_chart.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Analysis'),
      ),
      body: Consumer2<GPAProvider, GradeScaleProvider>(
        builder: (context, gpaProvider, gradeProvider, _) {
          if (gpaProvider.courses.isEmpty) {
            return const Center(
              child: Text('Add some courses to see analysis'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AnalysisCard(
                title: 'GPA Overview',
                icon: Icons.analytics_outlined,
                headerColor: _getGPAColor(gpaProvider.gpa),
                initiallyExpanded: true,
                child: Column(
                  children: [
                    _buildOverviewStats(context, gpaProvider),
                    const SizedBox(height: 24),
                    const Text('GPA Trend'),
                    GPATrendChart(courses: gpaProvider.courses),
                  ],
                ),
              ),
              AnalysisCard(
                title: 'Grade Distribution',
                icon: Icons.pie_chart, // Fixed icon name
                child: _buildGradeDistribution(context, gpaProvider),
              ),
              AnalysisCard(
                title: 'Credit Analysis',
                icon: Icons.credit_card_outlined,
                child: _buildCreditAnalysis(context, gpaProvider),
              ),
              AnalysisCard(
                title: 'Performance Insights',
                icon: Icons.lightbulb_outline,
                child: _buildPerformanceInsights(context, gpaProvider),
              ),
            ].animate(interval: 100.ms).fadeIn().slideX(),
          );
        },
      ),
    );
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 3.0) return Colors.blue;
    if (gpa >= 2.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildOverviewStats(BuildContext context, GPAProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalCredits =
        provider.courses.fold<double>(0, (sum, course) => sum + course.credits);
    final averageGrade = provider.gpa.toStringAsFixed(2);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatBox(
              title: 'Total Courses',
              value: '${provider.courses.length}',
              icon: Icons.book,
            ),
            _StatBox(
              title: 'Total Credits',
              value: totalCredits.toStringAsFixed(1),
              icon: Icons.credit_card,
            ),
            _StatBox(
              title: 'Average GPA',
              value: averageGrade,
              icon: Icons.grade,
              valueColor: _getGPAColor(provider.gpa),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradeDistribution(BuildContext context, GPAProvider provider) {
    final gradeMap = <String, int>{};
    for (var course in provider.courses) {
      gradeMap[course.grade] = (gradeMap[course.grade] ?? 0) + 1;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final sections = gradeMap.entries.map((e) {
      final value = e.value / provider.courses.length;
      return PieChartSectionData(
        color: colorScheme.primary.withOpacity(0.5 + (value * 0.5)),
        value: value * 100,
        title: '${e.key}\n${(value * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      );
    }).toList();

    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCreditAnalysis(BuildContext context, GPAProvider provider) {
    final creditsByGrade = <String, double>{};
    for (var course in provider.courses) {
      creditsByGrade[course.grade] =
          (creditsByGrade[course.grade] ?? 0) + course.credits;
    }

    return Column(
      children: [
        for (var entry in creditsByGrade.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: entry.value /
                        provider.courses.fold<double>(
                          0,
                          (sum, course) => sum + course.credits,
                        ),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.2),
                  ),
                ),
                const SizedBox(width: 16),
                Text('${entry.value} credits'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPerformanceInsights(BuildContext context, GPAProvider provider) {
    final bestCourse = provider.courses.reduce(
      (a, b) => a.gradePoints > b.gradePoints ? a : b,
    );
    final worstCourse = provider.courses.reduce(
      (a, b) => a.gradePoints < b.gradePoints ? a : b,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InsightItem(
          icon: Icons.trending_up,
          title: 'Best Performance',
          description: '${bestCourse.name} (${bestCourse.grade})',
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _InsightItem(
          icon: Icons.trending_down,
          title: 'Needs Improvement',
          description: '${worstCourse.name} (${worstCourse.grade})',
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _InsightItem(
          icon: Icons.insights,
          title: 'GPA Trend',
          description: provider.gpa > 3.0
              ? 'Strong academic performance!'
              : 'Consider seeking academic support',
          color: provider.gpa > 3.0 ? Colors.blue : Colors.red,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
