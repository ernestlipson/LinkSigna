import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/utils/app.constants.dart';

import '../../infrastructure/dal/services/google.signin.service.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import '../components/app.outline.button.dart';
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
                spacing: 30,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  // Name Field
                  Obx(() {
                    return CustomTextFormField(
                      hintText: 'Enter your name',
                      labelText: 'Name', // New: label text
                      controller: controller.nameController,
                      isRequired: true, // New: mark as required
                      errorText: controller.isNameValid.value
                          ? null
                          : 'This field is required',
                    );
                  }),
                  // Phone Field (with optional prefix)
                  Obx(() {
                    return CustomTextFormField(
                      hintText: 'Enter Phone Number',
                      labelText: 'Phone Number', // New: label text
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      prefix: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '🇬🇭', // Ghana flag emoji
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      isRequired: true, // New: mark as required
                      errorText: controller.isPhoneValid.value
                          ? null
                          : 'This field is required',
                    );
                  }),
                  // Password Field
                  Obx(() {
                    return CustomTextFormField(
                      hintText: 'Enter your password',
                      labelText: 'Password',
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible
                          .value, // Toggle based on visibility state
                      isRequired: true,
                      errorText: controller.isPasswordValid.value
                          ? null
                          : 'This field is required',
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
                        child: Text(
                            'By signing up, you agree to LinkSigna Terms of Service and Privacy policy'),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: "Sign up",
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
