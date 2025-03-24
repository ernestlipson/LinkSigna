import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../infrastructure/dal/services/google.signin.service.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/utils/app.constants.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import '../components/app.outline.button.dart';
import '../utils/screens.strings.dart'; // Import the strings file
import 'controllers/signup.controller.dart';

class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: AppConstants.toolbarHeightXS,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: SvgPicture.asset(
                  "assets/icons/TravelIB.svg",
                ),
              ),
              Column(
                spacing: 30,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ScreenStrings.signUpTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  // Name Field
                  Obx(() {
                    return CustomTextFormField(
                      hintText: ScreenStrings.nameHint,
                      labelText: ScreenStrings.nameLabel, // New: label text
                      controller: controller.nameController,
                      isRequired: true, // New: mark as required
                      errorText: controller.isNameValid.value
                          ? null
                          : ScreenStrings.requiredFieldError,
                    );
                  }),
                  // Phone Field (with optional prefix)
                  Obx(() {
                    return CustomTextFormField(
                      hintText: ScreenStrings.phoneHint,
                      labelText: ScreenStrings.phoneLabel, // New: label text
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ScreenStrings.ghanaFlagEmoji, // Ghana flag emoji
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      isRequired: true, // New: mark as required
                      errorText: controller.isPhoneValid.value
                          ? null
                          : ScreenStrings.requiredFieldError,
                    );
                  }),
                  // Password Field
                  Obx(() {
                    return CustomTextFormField(
                      hintText: ScreenStrings.passwordHint,
                      labelText: ScreenStrings.passwordLabel,
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible
                          .value, // Toggle based on visibility state
                      isRequired: true,
                      errorText: controller.isPasswordValid.value
                          ? null
                          : ScreenStrings.requiredFieldError,
                      suffix: IconButton(
                        onPressed: controller
                            .togglePasswordVisibility, // Use the controller method
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons
                                  .visibility_off // Show this when password is visible
                              : Icons
                                  .visibility, // Show this when password is hidden
                        ),
                      ),
                    );
                  }),
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            value: controller.isTermsAccepted.value,
                            onChanged: (bool? newValue) {
                              controller.isTermsAccepted.value =
                                  newValue ?? false;
                            },
                          )),
                      Expanded(
                        child: Text(ScreenStrings.termsAndPrivacy),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: ScreenStrings.signUpButton,
                    onPressed: () {
                      // Validate all fields at once
                      final isFormValid = controller.validateAll();
                      if (isFormValid) {
                        // All fields are valid
                        Get.snackbar('Success', ScreenStrings.allFieldsValid,
                            snackPosition: SnackPosition.BOTTOM);
                      } else {
                        // Some fields are invalid
                        Get.snackbar('Error', ScreenStrings.fillRequiredFields,
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                  Center(
                      child:
                          Text(ScreenStrings.orText)), // Center the "Or" text
                  GoogleSignInButton(
                    // text: "Sign Up with Google",
                    onPressed: () async {
                      try {
                        await GoogleSignInService.signInWithGoogle();
                        Get.snackbar(
                            'Google Sign Up', ScreenStrings.signUpSuccess,
                            snackPosition: SnackPosition.BOTTOM);
                      } catch (e) {
                        Get.snackbar('Google Sign Up',
                            '${ScreenStrings.signUpFailed}: $e',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: ScreenStrings.alreadyHaveAccount,
                        style: TextStyle(
                            color: Colors.black), // Default text style
                        children: [
                          TextSpan(
                            text: ScreenStrings.loginText,
                            style: TextStyle(
                                color: Color(0xFF9E1068)), // Colored text
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.offAndToNamed(
                                    Routes.LOGIN); // Navigate to login page
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
