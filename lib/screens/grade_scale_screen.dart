import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/grade_scale_provider.dart';
import '../models/grade_scale.dart';

class GradeScaleScreen extends StatelessWidget {
  const GradeScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Scale Settings'),
      ),
      body: Consumer<GradeScaleProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grade Scale Configuration',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Configure your institution\'s grading scale here. These settings will be used to calculate your GPA.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().slideX(),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final scale = provider.scales[index];
                    return _GradeScaleItem(
                      scale: scale,
                      onEdit: () => _showEditDialog(context, provider, scale),
                      onDelete: () =>
                          _showDeleteDialog(context, provider, scale),
                    ).animate().fadeIn(delay: (50 * index).ms).slideX();
                  },
                  childCount: provider.scales.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        label: const Text('Add Grade'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String grade = '';
    double points = 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Grade Scale'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Grade (e.g., A+, B-, etc.)',
                  prefixIcon: Icon(Icons.grade),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter a grade' : null,
                onSaved: (value) => grade = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Points (e.g., 4.0)',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter points';
                  final points = double.tryParse(value);
                  if (points == null || points < 0) {
                    return 'Enter valid points';
                  }
                  return null;
                },
                onSaved: (value) => points = double.parse(value ?? '0'),
              ),
            ],
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
                context.read<GradeScaleProvider>().addScale(grade, points);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, GradeScaleProvider provider, GradeScale scale) {
    final formKey = GlobalKey<FormState>();
    String grade = scale.grade;
    double points = scale.points;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Grade Scale'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: grade,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  prefixIcon: Icon(Icons.grade),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter a grade' : null,
                onSaved: (value) => grade = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: points.toString(),
                decoration: const InputDecoration(
                  labelText: 'Points',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter points';
                  final points = double.tryParse(value);
                  if (points == null || points < 0) {
                    return 'Enter valid points';
                  }
                  return null;
                },
                onSaved: (value) => points = double.parse(value ?? '0'),
              ),
            ],
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
                provider.updateScale(scale, grade, points);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, GradeScaleProvider provider, GradeScale scale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade Scale'),
        content: Text('Are you sure you want to delete ${scale.grade}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.removeScale(scale);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _GradeScaleItem extends StatelessWidget {
  final GradeScale scale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GradeScaleItem({
    required this.scale,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            scale.grade,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(scale.grade),
        subtitle: Text('${scale.points} points'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
