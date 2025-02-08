import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'animated_blob.dart';
import 'grain_shader.dart';

class GPACard extends StatelessWidget {
  final double gpa;

  const GPACard({super.key, required this.gpa});

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 3.0) return Colors.blue;
    if (gpa >= 2.0) return Colors.orange;
    return Colors.red;
  }

  String _getGPAStatus(double gpa) {
    if (gpa >= 3.5) return 'Excellent';
    if (gpa >= 3.0) return 'Good';
    if (gpa >= 2.0) return 'Satisfactory';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getGPAColor(gpa);
    final status = _getGPAStatus(gpa);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Animated blobs
            Positioned.fill(
              child: AnimatedBlob(
                color: color.withOpacity(0.1),
                size: 300,
              ),
            ),
            // Grain effect
            Positioned.fill(
              child: CustomPaint(
                painter: GrainShader(
                  color: colorScheme.primary,
                  opacity: 0.05,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current GPA',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                  ).animate().fadeIn().slideY(begin: -0.2),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gpa.toStringAsFixed(2),
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                      ).animate().fadeIn().scale(),
                      const SizedBox(width: 4),
                      Text(
                        '/4.0',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                      ).animate().fadeIn().slideX(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
