import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class AnalysisCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? headerColor;
  final IconData icon;
  final bool initiallyExpanded;

  const AnalysisCard({
    super.key,
    required this.title,
    required this.child,
    required this.icon,
    this.headerColor,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = headerColor ?? colorScheme.primary;
    final backgroundColor = headerColor?.withOpacity(0.1) ??
        colorScheme.primaryContainer.withOpacity(0.1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpandablePanel(
        theme: ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          hasIcon: false,
          iconColor: iconColor,
          iconPadding: EdgeInsets.zero,
        ),
        header: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ExpandableIcon(
                theme: ExpandableThemeData(
                  expandIcon: Icons.keyboard_arrow_down_rounded,
                  collapseIcon: Icons.keyboard_arrow_up_rounded,
                  iconColor: iconColor,
                  iconSize: 28,
                  iconRotationAngle: math.pi,
                  iconPadding: EdgeInsets.zero,
                  hasIcon: false,
                ),
              ),
            ],
          ),
        ),
        collapsed: const SizedBox(),
        expanded: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ).animate().fadeIn().slideY(begin: -0.1),
      ),
    );
  }
}
