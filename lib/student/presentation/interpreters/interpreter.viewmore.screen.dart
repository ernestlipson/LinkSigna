import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/theme/app_theme.dart';
import '../../../shared/components/payment_modal.component.dart';
import '../../../shared/components/app.button.dart';
import '../../../domain/users/user.model.dart';

class InterpreterViewMoreScreen extends StatelessWidget {
  final User interpreter;
  final VoidCallback? onBack;

  const InterpreterViewMoreScreen({
    super.key,
    required this.interpreter,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom back button header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack ?? () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.arrow_back, color: Colors.grey[700], size: 20),
                ),
              ),
              SizedBox(width: 16),
              Text(
                'Interpreter Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: _buildProfileContent(context),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Column(
      children: [
        // Profile Picture
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: interpreter.avatarUrl != null &&
                    interpreter.avatarUrl!.isNotEmpty
                ? NetworkImage(interpreter.avatarUrl!)
                : null,
            backgroundColor: Colors.grey[200],
            child:
                interpreter.avatarUrl == null || interpreter.avatarUrl!.isEmpty
                    ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                    : null,
          ),
        ),
        SizedBox(height: 18),

        // Name
        Text(
          interpreter.fullName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        interpreter.email != null
            ? Text(
                interpreter.email!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              )
            : SizedBox.shrink(),

        SizedBox(height: 32),

        // Experience Section
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${interpreter.years ?? 0} years in Sign Language interpretation',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(height: 24),

        // Bio Section
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Bio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            interpreter.bio ??
                'This interpreter is experienced in educational sign language interpretation and has worked with deaf students in universities.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 40),

        Container(
          padding: EdgeInsets.only(bottom: 20),
          width: double.infinity,
          child: CustomButton(
            text: 'Proceed to check out',
            onPressed: () => PaymentModalComponent.showPaymentModal(context,
                interpreterName: interpreter.fullName),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
