import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/gpa_provider.dart';
import '../providers/grade_scale_provider.dart';
import '../models/course.dart';

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

          final coursesByGrade = _groupCoursesByGrade(gpaProvider.courses);
          final totalCredits = gpaProvider.courses
              .fold<double>(0, (sum, course) => sum + course.credits);
          final highestGrade = gradeProvider.scales.first;
          final potentialGPA =
              _calculatePotentialGPA(gpaProvider.courses, highestGrade.grade);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatCard(
                        title: 'Overview',
                        children: [
                          _StatItem(
                            label: 'Current GPA',
                            value: gpaProvider.gpa.toStringAsFixed(2),
                          ),
                          _StatItem(
                            label: 'Total Credits',
                            value: totalCredits.toString(),
                          ),
                          _StatItem(
                            label: 'Total Courses',
                            value: gpaProvider.courses.length.toString(),
                          ),
                          _StatItem(
                            label: 'Potential GPA',
                            value: potentialGPA.toStringAsFixed(2),
                            subtitle:
                                'If all remaining courses are grade ${highestGrade.grade}',
                          ),
                        ],
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),
                      _StatCard(
                        title: 'Grade Distribution',
                        children: coursesByGrade.entries.map((entry) {
                          final percentage = (entry.value.length /
                                  gpaProvider.courses.length) *
                              100;
                          return _StatItem(
                            label: 'Grade ${entry.key}',
                            value:
                                '${entry.value.length} (${percentage.toStringAsFixed(1)}%)',
                            subtitle:
                                '${entry.value.fold<double>(0, (sum, course) => sum + course.credits)} credits',
                          );
                        }).toList(),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),
                      _StatCard(
                        title: 'Course Analysis',
                        children: [
                          _StatItem(
                            label: 'Highest Grade',
                            value: _findHighestGradeCourse(gpaProvider.courses)
                                    ?.name ??
                                '-',
                            subtitle: 'Best performing course',
                          ),
                          _StatItem(
                            label: 'Lowest Grade',
                            value: _findLowestGradeCourse(gpaProvider.courses)
                                    ?.name ??
                                '-',
                            subtitle: 'Course needing most attention',
                          ),
                          _StatItem(
                            label: 'Average Credits',
                            value: (totalCredits / gpaProvider.courses.length)
                                .toStringAsFixed(1),
                            subtitle: 'Credits per course',
                          ),
                        ],
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 16),
                      _StatCard(
                        title: 'Recommendations',
                        children: [
                          _RecommendationItem(
                            icon: Icons.trending_up,
                            title: 'GPA Improvement',
                            description: _getGPAImprovement(
                                gpaProvider.gpa, potentialGPA),
                          ),
                          _RecommendationItem(
                            icon: Icons.school,
                            title: 'Academic Standing',
                            description: _getAcademicStanding(gpaProvider.gpa),
                          ),
                        ],
                      ).animate().fadeIn().slideX(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Course>> _groupCoursesByGrade(List<Course> courses) {
    final map = <String, List<Course>>{};
    for (final course in courses) {
      if (!map.containsKey(course.grade)) {
        map[course.grade] = [];
      }
      map[course.grade]!.add(course);
    }
    return map;
  }

  double _calculatePotentialGPA(List<Course> courses, String highestGrade) {
    final totalCredits =
        courses.fold<double>(0, (sum, course) => sum + course.credits);
    final currentPoints = courses.fold<double>(
        0, (sum, course) => sum + (course.gradePoints * course.credits));

    return currentPoints / totalCredits;
  }

  Course? _findHighestGradeCourse(List<Course> courses) {
    if (courses.isEmpty) return null;
    return courses.reduce((a, b) => a.gradePoints > b.gradePoints ? a : b);
  }

  Course? _findLowestGradeCourse(List<Course> courses) {
    if (courses.isEmpty) return null;
    return courses.reduce((a, b) => a.gradePoints < b.gradePoints ? a : b);
  }

  String _getGPAImprovement(double currentGPA, double potentialGPA) {
    final difference = potentialGPA - currentGPA;
    if (difference <= 0) {
      return 'You\'re doing great! Keep up the good work.';
    }
    return 'You can improve your GPA by up to ${difference.toStringAsFixed(2)} points.';
  }

  String _getAcademicStanding(double gpa) {
    if (gpa >= 3.5) {
      return 'Dean\'s List - Excellent academic standing!';
    } else if (gpa >= 3.0) {
      return 'Good academic standing';
    } else if (gpa >= 2.0) {
      return 'Satisfactory academic standing';
    } else {
      return 'Academic probation - Consider seeking academic support';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _StatCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const _StatItem({
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _RecommendationItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
