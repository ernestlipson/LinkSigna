import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class LoadFlagAnimation extends StatelessWidget {
  const LoadFlagAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      interval: const Duration(seconds: 1),
      color: Colors.grey[300]!,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
