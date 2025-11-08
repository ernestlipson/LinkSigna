import 'package:flutter/material.dart';

/// A reusable empty state for notifications tab in settings screens.
class EmptyNotificationsTab extends StatelessWidget {
  final String message;

  const EmptyNotificationsTab({
    super.key,
    this.message = 'No notifications yet',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
