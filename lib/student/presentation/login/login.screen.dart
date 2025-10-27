import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../shared/components/app.button.dart';
import '../../../shared/components/app.field.dart';
import 'package:sign_language_app/infrastructure/utils/screen_strings.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: SvgPicture.asset(
                  "assets/icons/TravelIB.svg",
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Email Field
                  Obx(() => CustomTextFormField(
                        hintText: "ama@gmail.com",
                        labelText: "University Email (.gh only)",
                        controller: controller.emailController,
                        isRequired: true,
                        keyboardType: TextInputType.emailAddress,
                        errorText: controller.isEmailValid.value
                            ? null
                            : controller.emailController.text.trim().isEmpty
                                ? ScreenStrings.requiredFieldError
                                : ScreenStrings.emailValidationError,
                        onChanged: (value) => controller.validateEmail(),
                      )),
                  SizedBox(height: 16),

                  // Password Field
                  Obx(() => CustomTextFormField(
                        hintText: ScreenStrings.passwordHint,
                        labelText: ScreenStrings.passwordLabel,
                        controller: controller.passwordController,
                        isRequired: true,
                        obscureText: !controller.isPasswordVisible.value,
                        errorText: controller.isPasswordValid.value
                            ? null
                            : controller.passwordController.text.trim().isEmpty
                                ? ScreenStrings.requiredFieldError
                                : ScreenStrings.passwordValidationError,
                        onChanged: (value) => controller.validatePassword(),
                        suffix: GestureDetector(
                          onTap: () => controller.togglePasswordVisibility(),
                          child: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey[600],
                          ),
                        ),
                      )),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Obx(() => Switch(
                            value: controller.isRememberMe.value,
                            onChanged: (value) {
                              controller.isRememberMe.value = value;
                            },
                            activeColor: AppColors.primary,
                            activeTrackColor:
                                AppColors.primary.withOpacity(0.2),
                          )),
                      Text(
                        ScreenStrings.rememberMe,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => controller.sendPasswordReset(),
                        child: Text(
                          ScreenStrings.forgotPassword,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Login Button
                  Obx(() => CustomButton(
                        isLoading: controller.isLoading.value,
                        text: "Log in",
                        onPressed: controller.isLoading.value
                            ? () {}
                            : () => controller.login(),
                      )),
                  SizedBox(height: 24),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: "Don't have an account? ",
                          ),
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.offAndToNamed(Routes.STUDENT_SIGNUP);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
