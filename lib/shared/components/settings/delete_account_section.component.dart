import 'package:flutter/material.dart';

/// A reusable delete account section component used in settings screens.
class DeleteAccountSection extends StatelessWidget {
  final VoidCallback onDelete;
  final String title;
  final String description;
  final String buttonLabel;
  final bool isEnabled;

  const DeleteAccountSection({
    super.key,
    required this.onDelete,
    this.title = 'Delete Account',
    this.description =
        'Deleting your account will remove all of your activity and campaigns, and you will no longer be able to sign in with this account.',
    this.buttonLabel = 'Delete account',
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: isEnabled ? onDelete : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 0),
            foregroundColor: isEnabled ? Colors.red : Colors.grey,
            side: BorderSide(color: isEnabled ? Colors.red : Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            buttonLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
