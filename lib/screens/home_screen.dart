import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/gpa_provider.dart';
import '../models/course.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('GPA Calculator'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          Consumer<GPAProvider>(
            builder: (context, gpaProvider, child) {
              return SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? width * 0.1 : 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _GPACard(gpa: gpaProvider.gpa),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Courses',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        FilledButton.icon(
                          onPressed: () => _showAddCourseDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Course'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (gpaProvider.courses.isEmpty)
                      _EmptyState()
                    else
                      Column(
                        children: gpaProvider.courses
                            .map((course) => _CourseCard(
                                  course: course,
                                  onDelete: () =>
                                      gpaProvider.removeCourse(course),
                                ))
                            .toList(),
                      ).animate().fadeIn().slideX(),
                  ]),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    double credits = 0;
    String grade = 'A';
    final grades = [
      'A',
      'A-',
      'B+',
      'B',
      'B-',
      'C+',
      'C',
      'C-',
      'D+',
      'D',
      'F'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.book),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                  onSaved: (value) => name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Credits',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter credits';
                    final credits = double.tryParse(value);
                    if (credits == null || credits <= 0) {
                      return 'Enter valid credits';
                    }
                    return null;
                  },
                  onSaved: (value) => credits = double.parse(value ?? '0'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    prefixIcon: Icon(Icons.grade),
                  ),
                  value: grade,
                  items: grades
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => grade = value ?? 'A',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final course = Course(
                  name: name,
                  credits: credits,
                  grade: grade,
                );
                context.read<GPAProvider>().addCourse(course);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GPA Scale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('A  = 4.0', style: Theme.of(context).textTheme.bodyLarge),
            Text('A- = 3.7', style: Theme.of(context).textTheme.bodyLarge),
            Text('B+ = 3.3', style: Theme.of(context).textTheme.bodyLarge),
            // ...Add more grade scales
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _GPACard extends StatelessWidget {
  final double gpa;

  const _GPACard({required this.gpa});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(
                'Current GPA',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                gpa.toStringAsFixed(2),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onDelete;

  const _CourseCard({required this.course, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // For future edit functionality
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  course.grade,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${course.credits} credits · Grade: ${course.grade}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Course'),
                      content: Text('Delete ${course.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            onDelete();
                            Navigator.pop(context);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No courses yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first course to calculate GPA',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
