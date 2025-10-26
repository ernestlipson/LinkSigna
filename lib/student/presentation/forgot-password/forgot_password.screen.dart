import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../shared/components/app.button.dart';
import '../../../shared/components/app.field.dart';
import 'package:sign_language_app/infrastructure/utils/app.constants.dart';
import '../utils/screens.strings.dart';
import 'controllers/forgot_password.controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: AppConstants.toolbarHeightXS,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo section
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'WorkSans',
                      ),
                      children: [
                        TextSpan(
                          text: 'Link',
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextSpan(
                          text: 'Signa',
                          style: TextStyle(color: Color(0xFF9E1068)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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

              // Phone number field
              Obx(() {
                return CustomTextFormField(
                  hintText: ScreenStrings.phoneHint,
                  labelText: ScreenStrings.phoneLabel,
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10, // Limit to 10 digits
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  ],
                  prefix: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ).copyWith(
                      left: 8,
                    ),
                    child: Obx(() {
                      final flag =
                          controller.countryController.countryFlag.value;
                      final flagLoading =
                          controller.countryController.countryLoading.value;
                      return flagLoading
                          ? SizedBox.shrink()
                          : flag != null
                              ? Image.network(flag.png, width: 20, height: 20)
                              : SizedBox.shrink();
                    }),
                  ),
                  isRequired: true,
                  errorText: controller.isPhoneValid.value
                      ? null
                      : controller.phoneErrorMessage.value,
                );
              }),
              SizedBox(height: 16),

              // Description text
              Text(
                "We will send a 6-digit code to this number",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'WorkSans',
                ),
              ),
              SizedBox(height: 40),

              // Send Code Button
              Obx(() => CustomButton(
                    text: "Send Code",
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      controller.sendVerificationCode();
                    },
                    color: Color(0xFF9E1068),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
