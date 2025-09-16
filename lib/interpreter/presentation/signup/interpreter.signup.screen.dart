import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../student/presentation/utils/screens.strings.dart';
import '../../infrastructure/theme/app_theme.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import 'controllers/signup.int.controller.dart';

class InterpreterSignupScreen extends GetView<InterpreterSignupController> {
  const InterpreterSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is registered
    if (!Get.isRegistered<InterpreterSignupController>()) {
      Get.put(InterpreterSignupController());
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
                        Get.offNamed('/student/signup');
                      },
                      activeColor: AppColors.primary,
                    ),
                    const Text('Student'),
                  ]),
                  const SizedBox(width: 24),
                  Row(children: [
                    Radio<String>(
                      value: 'interpreter',
                      groupValue: 'interpreter',
                      onChanged: (_) {},
                      activeColor: AppColors.primary,
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
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              Get.offAndToNamed(Routes.INTERPRETER_SIGNIN),
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
