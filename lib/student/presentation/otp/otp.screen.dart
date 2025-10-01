import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/signup_logo.dart';

import '../../../shared/components/app.button.dart';
import 'controllers/otp.controller.dart';

class OtpScreen extends GetView<OtpController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, // Hide default appbar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SignupLogo(),
              const SizedBox(height: 60),
              const Text(
                'Verification Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF232323),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                    'Enter the 6-digit code sent to ${controller.destination}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF232323),
                    ),
                  )),
              const SizedBox(height: 32),
              // OTP Input Fields (6 separate boxes)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 48,
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: controller.focusedIndex.value == index
                            ? const Color(0xFF9C0057)
                            : Colors.black54,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: controller.otpControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) =>
                          controller.onOtpChanged(index, value),
                      focusNode: controller.focusNodes[index],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't Receive the OTP? ",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  Obx(() => controller.canResend.value
                      ? GestureDetector(
                          onTap: controller.isResendingOtp.value
                              ? null
                              : controller.resendOTP,
                          child: Text(
                            controller.isResendingOtp.value
                                ? 'Resending...'
                                : 'Resend OTP',
                            style: TextStyle(
                              fontSize: 15,
                              color: controller.isResendingOtp.value
                                  ? Colors.grey
                                  : Color(0xFF9E1068),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Text(
                          'Resend in ${controller.resendTimer.value}s',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                ],
              ),
              const SizedBox(height: 32),

              Obx(() => CustomButton(
                    text: "Verify Code",
                    isLoading: controller.isVerifyingOtp.value,
                    onPressed: () => controller.verifyOTP(),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
