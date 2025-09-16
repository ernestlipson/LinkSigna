import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import 'controllers/signin.controller.dart';

class InterpreterSignInScreen extends StatelessWidget {
  const InterpreterSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterpreterSigninController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // LinkSigna Logo
              _buildLogo(),
              const SizedBox(height: 60),

              // Log In Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'WorkSans',
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Email Field
              Obx(() => CustomTextFormField(
                    labelText: "Email",
                    hintText: "Enter your email",
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    onChanged: (_) => controller.validateEmail(),
                    errorText: controller.isEmailValid.value
                        ? null
                        : "Please enter a valid email address",
                  )),
              const SizedBox(height: 30),

              // Log In Button
              Obx(() => CustomButton(
                    text: controller.isSubmitting.value
                        ? "Sending OTP..."
                        : "Log In",
                    onPressed: controller.isSubmitting.value
                        ? () {}
                        : () => controller.submit(),
                  )),
              const SizedBox(height: 30),

              // Sign Up Link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      // fontSize: 16,
                      color: Colors.black87,
                      // fontFamily: 'WorkSans',
                    ),
                    children: [
                      TextSpan(
                        text: "Don't have an account? ",
                      ),
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: AppColors.primary, // Magenta color
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.offAndToNamed(Routes.INTERPRETER_SIGNUP);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Link",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2196F3), // Blue color
            fontFamily: 'WorkSans',
          ),
        ),
        Text(
          "Signa",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary, // Magenta color
            fontFamily: 'WorkSans',
          ),
        ),
      ],
    );
  }
}
