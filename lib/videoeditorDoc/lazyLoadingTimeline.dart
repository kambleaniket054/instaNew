import 'package:flutter/material.dart';
class LazyLoadingTimeline extends StatelessWidget {
  final double totalDuration; // Total video duration in seconds
  final double visibleDuration; // Duration visible on the screen at a time

  const LazyLoadingTimeline({super.key, 
    required this.totalDuration,
    this.visibleDuration = 10.0, // Default 10 seconds visible at a time
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: (totalDuration / visibleDuration).ceil(),
      itemBuilder: (context, index) {
        final start = index * visibleDuration;
        final end = start + visibleDuration > totalDuration
            ? totalDuration
            : start + visibleDuration;
        return Container(
          width: 1000, // Adjust width to represent the duration visually
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              "Time: ${start.toInt()}s - ${end.toInt()}s",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}