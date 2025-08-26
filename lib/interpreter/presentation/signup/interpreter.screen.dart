import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';

import '../../../student/presentation/utils/screens.strings.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/theme/app_theme.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import 'controllers/interpreter.controller.dart';

class InterpreterSignupScreen extends GetView<InterpreterController> {
  const InterpreterSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is registered
    if (!Get.isRegistered<InterpreterController>()) {
      Get.put(InterpreterController());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: SvgPicture.asset(
                    "assets/icons/TravelIB.svg",
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Radio<String>(
                      value: 'student',
                      groupValue: 'interpreter',
                      onChanged: (_) {
                        // Switch back to student sign up
                        Get.offNamed(Routes.SIGNUP);
                      },
                      activeColor: primaryColor,
                    ),
                    const Text('Student'),
                  ]),
                  const SizedBox(width: 24),
                  Row(children: [
                    Radio<String>(
                      value: 'interpreter',
                      groupValue: 'interpreter',
                      onChanged: (_) {},
                      activeColor: primaryColor,
                    ),
                    const Text('Interpreter'),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                ScreenStrings.signUpTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 30),
              Obx(() => CustomTextFormField(
                    hintText: 'Enter your name',
                    labelText: 'Full name',
                    controller: controller.nameController,
                    isRequired: true,
                    errorText: controller.isNameValid.value
                        ? null
                        : 'This field is required',
                    onChanged: (_) => controller.validateName(),
                  )),
              const SizedBox(height: 8),
              Obx(() => CustomTextFormField(
                    hintText: 'Enter your email',
                    labelText: 'Email',
                    controller: controller.emailController,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    errorText: controller.isEmailValid.value
                        ? null
                        : 'Enter a valid email',
                    onChanged: (_) => controller.validateEmail(),
                  )),
              const SizedBox(height: 8),

              // Send OTP Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSendingOtp.value
                          ? null
                          : () => controller.sendOtp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: controller.isSendingOtp.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Send Verification Code',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  )),
              const SizedBox(height: 16),

              // OTP Input Field (only show after OTP is sent)
              Obx(() => controller.isOtpSent.value
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verification Code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit code',
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.isVerifyingOtp.value
                                    ? null
                                    : () => controller.verifyOtp(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: controller.isVerifyingOtp.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Verify Code',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: controller.isSendingOtp.value
                                  ? null
                                  : () => controller.resendOtp(),
                              child: controller.isSendingOtp.value
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.grey),
                                      ),
                                    )
                                  : Text(
                                      'Resend',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink()),

              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: controller.isTermsAccepted.value,
                        onChanged: (v) =>
                            controller.isTermsAccepted.value = v ?? false,
                        side: const BorderSide(color: Color(0xFFFFD6E7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'By signing up, you agree to LinkSigna Terms of Service and Privacy policy',
                        ),
                      )
                    ],
                  )),
              const SizedBox(height: 16),
              Center(
                child: Obx(() => CustomButton(
                      text: 'Sign Up',
                      isLoading: controller.isSubmitting.value,
                      onPressed: controller.isSubmitting.value
                          ? () {}
                          : () => controller.submit(),
                    )),
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.back(),
                      )
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
