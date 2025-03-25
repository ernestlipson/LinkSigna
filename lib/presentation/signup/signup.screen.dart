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
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: SvgPicture.asset(
                  "assets/icons/TravelIB.svg",
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ScreenStrings.signUpTitle,
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
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
                  SizedBox(height: 10),
                  Obx(() {
                    return CustomTextFormField(
                      hintText: ScreenStrings.phoneHint,
                      labelText: ScreenStrings.phoneLabel, // New: label text
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ).copyWith(
                          left: 8,
                        ),
                        child: Obx(() {
                          final flag = controller.countryFlag.value;
                          final flagLoading = controller.countryLoading.value;
                          return flagLoading
                              ? SizedBox.shrink()
                              : flag != null
                                  ? Image.network(flag.png,
                                      width: 20, height: 20)
                                  : SizedBox.shrink();
                        }),
                      ),
                      isRequired: true, // New: mark as required
                      errorText: controller.isPhoneValid.value
                          ? null
                          : ScreenStrings.requiredFieldError,
                    );
                  }),
                  SizedBox(height: 10),
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
                          color: Colors.black.withAlpha(64),
                          size: 20,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            side: BorderSide(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            value: controller.isTermsAccepted.value,
                            onChanged: (bool? newValue) {
                              controller.isTermsAccepted.value =
                                  newValue ?? false;
                            },
                          )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9.0)
                            .copyWith(right: 12),
                        child: Text(
                          ScreenStrings.termsAndPrivacy,
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: ScreenStrings.signUpButton,
                    onPressed: () {
                      controller.signUp();
                    },
                  ),
                  SizedBox(height: 18),
                  Center(
                      child: Text(ScreenStrings.orText,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ))), // Center the "Or" text
                  SizedBox(height: 18),
                  GoogleSignInButton(
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
                  SizedBox(height: 30),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: ScreenStrings.alreadyHaveAccount,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400), // Default text style
                        children: [
                          TextSpan(
                            text: ScreenStrings.loginText,
                            style: TextStyle(
                                color: Color(0xFF9E1068),
                                fontFamily: "WorkSans"), // Colored text
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
