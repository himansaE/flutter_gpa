import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'animated_blob.dart';

class GPACard extends StatelessWidget {
  final double gpa;

  const GPACard({super.key, required this.gpa});

  List<Color> _getGPAColors(double gpa) {
    if (gpa >= 3.5) {
      return [
        Colors.green.shade300,
        Colors.green.shade500,
        Colors.teal.shade300,
      ];
    }
    if (gpa >= 3.0) {
      return [
        Colors.blue.shade300,
        Colors.blue.shade500,
        Colors.indigo.shade300,
      ];
    }
    if (gpa >= 2.0) {
      return [
        Colors.orange.shade300,
        Colors.orange.shade500,
        Colors.deepOrange.shade300,
      ];
    }
    return [
      Colors.red.shade300,
      Colors.red.shade500,
      Colors.deepOrange.shade300,
    ];
  }

  String _getGPAStatus(double gpa) {
    if (gpa >= 3.5) return 'Excellent';
    if (gpa >= 3.0) return 'Good';
    if (gpa >= 2.0) return 'Satisfactory';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getGPAColors(gpa);
    final status = _getGPAStatus(gpa);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(
          color: colors[1].withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors[0].withOpacity(0.1),
                      colors[1].withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Animated blobs with larger size
            Positioned.fill(
              child: AnimatedBlob(
                colors: colors,
                size: 800,
              ),
            ),
            // Enhanced glass effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surface.withOpacity(0.8),
                        colorScheme.surface.withOpacity(0.2),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
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
                                  color: colors[1],
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
                      color: colors[1].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 16,
                          color: colors[1],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colors[1],
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
