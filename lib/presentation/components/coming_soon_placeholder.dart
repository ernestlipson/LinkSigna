import 'package:flutter/material.dart';
import 'package:sign_language_app/infrastructure/utils/app_icons.dart';

class ComingSoonPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? illustration;
  final double illustrationHeight;

  const ComingSoonPlaceholder({
    super.key,
    this.title = 'Coming Soon',
    this.subtitle = 'Feature still in development.',
    this.illustration,
    this.illustrationHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration ?? AppIcons.amico(height: illustrationHeight),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF232B38),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF5A6271),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
