import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../infrastructure/theme/app_theme.dart';
import '../../infrastructure/utils/app_strings.dart';
import 'app.button.dart';
import 'app.field.dart';

class SharedSignInScreen extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController? passwordController;
  final RxBool isEmailValid;
  final RxBool? isPasswordValid;
  final RxBool? isPasswordVisible;
  final RxBool? isRememberMe;
  final RxBool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback? onTogglePasswordVisibility;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onEmailChanged;
  final VoidCallback? onPasswordChanged;
  final String signUpRoute;
  final String submitButtonText;
  final String loadingButtonText;
  final bool showPasswordField;

  const SharedSignInScreen({
    super.key,
    required this.emailController,
    this.passwordController,
    required this.isEmailValid,
    this.isPasswordValid,
    this.isPasswordVisible,
    this.isRememberMe,
    required this.isSubmitting,
    required this.onSubmit,
    this.onTogglePasswordVisibility,
    this.onForgotPassword,
    this.onEmailChanged,
    this.onPasswordChanged,
    required this.signUpRoute,
    this.submitButtonText = "Log in",
    this.loadingButtonText = "Signing In...",
    this.showPasswordField = true,
  });

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
              SizedBox(height: 30),
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
                        labelText: "University Email (.gh only)",
                        hintText: "ama@gmail.com",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        onChanged: (_) => onEmailChanged?.call(),
                        errorText: isEmailValid.value
                            ? null
                            : emailController.text.trim().isEmpty
                                ? AppStrings.requiredFieldError
                                : AppStrings.emailValidationError,
                      )),
                  SizedBox(height: 16),

                  // Password Field (conditionally shown)
                  if (showPasswordField && passwordController != null) ...[
                    Obx(() => CustomTextFormField(
                          hintText: AppStrings.passwordHint,
                          labelText: AppStrings.passwordLabel,
                          controller: passwordController,
                          isRequired: true,
                          obscureText: isPasswordVisible != null
                              ? !isPasswordVisible!.value
                              : true,
                          errorText: isPasswordValid?.value ?? true
                              ? null
                              : passwordController!.text.trim().isEmpty
                                  ? AppStrings.requiredFieldError
                                  : AppStrings.passwordValidationError,
                          onChanged: (_) => onPasswordChanged?.call(),
                          suffix: onTogglePasswordVisibility != null
                              ? GestureDetector(
                                  onTap: onTogglePasswordVisibility,
                                  child: Icon(
                                    isPasswordVisible?.value ?? false
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey[600],
                                  ),
                                )
                              : Icon(
                                  Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                ),
                        )),
                    SizedBox(height: 16),

                    // Remember me and Forgot Password
                    Row(
                      children: [
                        if (isRememberMe != null)
                          Obx(() => Switch(
                                value: isRememberMe!.value,
                                onChanged: (value) {
                                  isRememberMe!.value = value;
                                },
                                activeColor: AppColors.primary,
                                activeTrackColor:
                                    AppColors.primary.withOpacity(0.2),
                              ))
                        else
                          Switch(
                            value: false,
                            onChanged: (value) {},
                            activeColor: AppColors.primary,
                            activeTrackColor:
                                AppColors.primary.withOpacity(0.2),
                          ),
                        Text(
                          AppStrings.rememberMe,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: onForgotPassword ?? () {},
                          child: Text(
                            AppStrings.forgotPassword,
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
                  ] else
                    SizedBox(height: 8),

                  // Log In Button
                  Obx(() => CustomButton(
                        text: isSubmitting.value
                            ? loadingButtonText
                            : submitButtonText,
                        isLoading: isSubmitting.value,
                        onPressed: isSubmitting.value ? () {} : onSubmit,
                      )),
                  SizedBox(height: 24),

                  // Sign Up Link
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
                                Get.offAndToNamed(signUpRoute);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
