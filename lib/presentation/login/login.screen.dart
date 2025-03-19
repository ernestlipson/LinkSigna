import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../components/app.button.dart';
import '../components/app.field.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: SvgPicture.asset("assets/icons/TravelIB.svg"),
              ),
              // Name Field
              Obx(() {
                return CustomTextFormField(
                  hintText: 'Enter your name',
                  controller: controller.nameController,
                  errorText: controller.isNameValid.value
                      ? null
                      : 'This field is required',
                  // Validate on change or on submit
                  // For real-time, do it onChanged:
                  // onChanged is not in CustomTextFormField,
                  // but you can add a listener to the controller:
                );
              }),
              const SizedBox(height: 16),

              // Phone Field (with optional prefix)
              Obx(() {
                return CustomTextFormField(
                  hintText: 'Enter Phone Number',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  prefix: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '🇬🇭', // Ghana flag emoji
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  errorText: controller.isPhoneValid.value
                      ? null
                      : 'This field is required',
                );
              }),
              const SizedBox(height: 16),

              // Password Field
              // We'll add a suffix icon for toggling visibility in a separate approach
              Obx(() {
                return CustomTextFormField(
                  hintText: 'Enter your password',
                  controller: controller.passwordController,
                  obscureText: true,
                  errorText: controller.isPasswordValid.value
                      ? null
                      : 'This field is required',
                );
              }),
              const SizedBox(height: 24),

              CustomButton(
                text: "Login",
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
            ],
          ),
        ),
      ),
    );
  }
}
