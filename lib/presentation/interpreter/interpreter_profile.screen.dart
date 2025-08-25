import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/theme/app_theme.dart';
import '../components/payment_modal.component.dart';
import 'interpreter.screen.dart';

class InterpreterProfileScreen extends StatelessWidget {
  final InterpreterData interpreter;

  const InterpreterProfileScreen({
    super.key,
    required this.interpreter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.grey[700]),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Interpreter Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(interpreter.profileImage),
              ),
            ),
            SizedBox(height: 16),

            // Name
            Text(
              interpreter.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
                '${interpreter.experience} years in Sign Language interpretation',
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
                'Arlene is experienced in educational sign language interpretation and has worked with deaf students in universities.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
            Spacer(),

            // Proceed to Checkout Button
            Container(
              padding: EdgeInsets.only(bottom: 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => PaymentModalComponent.showPaymentModal(context,
                    interpreterName: interpreter.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Proceed to check out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
