import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/utils/app.constants.dart';

import '../../infrastructure/navigation/routes.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import '../components/app.outline.button.dart';
import '../utils/screens.strings.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  // Name Field
                  SizedBox(height: 30),
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
                          final flag =
                              controller.countryController.countryFlag.value;
                          final flagLoading =
                              controller.countryController.countryLoading.value;
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
                  //Add a Row containing a Remember me toggle and Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember Me Toggle
                      Row(
                        children: [
                          Obx(() => Checkbox(
                                side: BorderSide(color: Color(0xFFFFD6E7)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                value: controller.isRememberMe.value,
                                onChanged: (bool? newValue) {
                                  controller.isRememberMe.value =
                                      newValue ?? false;
                                },
                              )),
                          Text(
                            ScreenStrings.rememberMe,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      // Forgot Password Link
                      GestureDetector(
                        onTap: () {
                          print("Navigating to forgot password screen");
                          Get.toNamed(Routes.FORGOT_PASSWORD);
                        },
                        child: Text(
                          ScreenStrings.forgotPassword,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9E1068),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: "Log In",
                    onPressed: () {
                      // Validate all fields at once
                      final isFormValid = controller.validateAll();
                      if (isFormValid) {
                        // All fields are valid
                        Get.snackbar('Success', 'All fields are valid!',
                            snackPosition: SnackPosition.BOTTOM);
                      } else {
                        // Some fields are invalid
                        Get.snackbar('Error', 'Please fill required fields',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                  Center(child: Text("Or")), // Center the "Or" text
                  GoogleSignInButton(
                    onPressed: () async {
                      await controller.signInWithGoogle();
                    },
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed('/login'); // Navigate to login page
                      },
                      child: Text("Already have an account? Login"),
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
