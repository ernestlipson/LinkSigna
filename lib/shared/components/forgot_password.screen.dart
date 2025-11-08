import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/signup_logo.dart';

import '../../infrastructure/theme/app_theme.dart';
import '../../infrastructure/utils/app_strings.dart';
import '../controllers/forgot_password.controller.dart';
import 'app.button.dart';
import 'app.field.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCenterLogo(),
              SizedBox(height: 60),

              // Forgot Password title
              Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'WorkSans',
                ),
              ),
              SizedBox(height: 30),

              // Email field
              Obx(() => CustomTextFormField(
                    hintText: AppStrings.emailHint,
                    labelText: AppStrings.emailLabel,
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                    errorText: controller.isEmailValid.value
                        ? null
                        : controller.emailController.text.trim().isEmpty
                            ? AppStrings.requiredFieldError
                            : AppStrings.emailValidationError,
                    onChanged: (_) => controller.validateEmail(),
                  )),
              SizedBox(height: 24),

              // Send Code Button
              Obx(() => CustomButton(
                    text: "Send Code",
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      controller.sendVerificationCode();
                    },
                  )),
              SizedBox(height: 24),

              // Return to Login link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: "Return to ",
                      ),
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.back();
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
}
