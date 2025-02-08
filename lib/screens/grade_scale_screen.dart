import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/grade_scale_provider.dart';
import '../models/grade_scale.dart';

class GradeScaleScreen extends StatelessWidget {
  const GradeScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final provider = context.read<GradeScaleProvider>();
        if (!provider.isLocked) {
          provider.setLocked(true);
        }
        return true;
      },
      child: Consumer<GradeScaleProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Grade Scale Settings'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (!provider.isLocked) {
                    provider.setLocked(true);
                  }
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    provider.isLocked
                        ? Icons.lock_outlined
                        : Icons.lock_open_outlined,
                    color: provider.isLocked ? Colors.orange : null,
                  ),
                  onPressed: () => _handleLockToggle(context, provider),
                ),
              ],
            ),
            body: provider.isLocked
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outlined,
                          size: 48,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Grade Scale is Locked',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unlock to make changes',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () => _handleLockToggle(context, provider),
                          icon: const Icon(Icons.lock_open),
                          label: const Text('Unlock'),
                        ),
                      ],
                    ).animate().fadeIn(),
                  )
                : CustomScrollView(
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Configure your institution\'s grading scale here. These settings will be used to calculate your GPA.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
                              onEdit: () =>
                                  _showEditDialog(context, provider, scale),
                              onDelete: () =>
                                  _showDeleteDialog(context, provider, scale),
                            ).animate().fadeIn(delay: (50 * index).ms).slideX();
                          },
                          childCount: provider.scales.length,
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: provider.isLocked
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _showAddDialog(context),
                    label: const Text('Add Grade'),
                    icon: const Icon(Icons.add),
                  ),
          );
        },
      ),
    );
  }

  void _handleLockToggle(BuildContext context, GradeScaleProvider provider) {
    if (provider.isLocked) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unlock Grade Scale'),
          content: const Text(
            'Are you sure you want to unlock the grade scale? This will allow modifications to the grading system.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                provider.toggleLock();
                Navigator.pop(context);
              },
              child: const Text('Unlock'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lock Grade Scale'),
          content: const Text(
            'Are you sure you want to lock the grade scale? This will prevent any modifications to the grading system.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                provider.toggleLock();
                Navigator.pop(context);
              },
              child: const Text('Lock'),
            ),
          ],
        ),
      );
    }
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
