import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/shared/components/app.button.dart';
import 'package:sign_language_app/shared/components/signup_logo.dart';
import 'controllers/interpreter_otp.controller.dart';

class InterpreterOtpScreen extends StatelessWidget {
  const InterpreterOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterpreterOtpController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const SignupLogo(),
              const SizedBox(height: 60),
              const Text(
                'Email Verification',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF232323),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                            text: 'We Have Sent a One-Time Password\nto '),
                        TextSpan(
                          text: controller.email.value,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 32),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: controller.focusedIndex.value == index
                            ? AppColors.primary
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: controller.otpControllers[index],
                      focusNode: controller.focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      onChanged: (value) =>
                          controller.onOtpChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't Receive the OTP? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Obx(() => GestureDetector(
                        onTap: controller.canResend.value
                            ? () => controller.resendOTP()
                            : null,
                        child: Text(
                          controller.canResend.value
                              ? 'Resend OTP'
                              : 'Resend OTP (${controller.resendTimer.value}s)',
                          style: TextStyle(
                            fontSize: 14,
                            color: controller.canResend.value
                                ? AppColors.primary
                                : Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: "Verify Code",
                onPressed: () => controller.verifyOTP(),
                isLoading: controller.isVerifyingOtp.value,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
