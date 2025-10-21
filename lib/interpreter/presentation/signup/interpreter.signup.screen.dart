import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/signup_logo.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../shared/components/app.field.dart';
import '../../../shared/components/university_dropdown.dart';
import '../../../shared/components/user_type_selector.dart';
import '../../../student/presentation/utils/screens.strings.dart';
import '../../infrastructure/theme/app_theme.dart';
import '../../../shared/components/app.button.dart';
import 'controllers/signup.int.controller.dart';

class InterpreterSignupScreen extends GetView<InterpreterSignupController> {
  const InterpreterSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const SignupLogo(),
              const SizedBox(height: 20),
              UserTypeSelector(
                selectedType: 'interpreter',
                onTypeChanged: (String value) {
                  if (value == 'student') {
                    Get.offNamed('/student/signup');
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                ScreenStrings.signUpTitle,
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Obx(() => CustomTextFormField(
                    hintText: ScreenStrings.nameHint,
                    labelText: ScreenStrings.nameLabel,
                    controller: controller.nameController,
                    isRequired: true,
                    errorText: controller.isNameValid.value
                        ? null
                        : ScreenStrings.requiredFieldError,
                    onChanged: (_) => controller.validateName(),
                  )),
              const SizedBox(height: 10),
              Obx(() => CustomTextFormField(
                    hintText: 'student@ttu.edu.gh',
                    labelText: ScreenStrings.emailLabel,
                    controller: controller.emailController,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    errorText: controller.isEmailValid.value
                        ? null
                        : ScreenStrings.emailValidationError,
                    onChanged: (_) => controller.validateEmail(),
                  )),
              const SizedBox(height: 10),
              Obx(() => CustomTextFormField(
                    hintText: ScreenStrings.passwordHint,
                    labelText: ScreenStrings.passwordLabel,
                    controller: controller.passwordController,
                    isRequired: true,
                    obscureText: !controller.isPasswordVisible.value,
                    errorText: controller.isPasswordValid.value
                        ? null
                        : ScreenStrings.passwordValidationError,
                    onChanged: (_) => controller.validatePassword(),
                    suffix: GestureDetector(
                      onTap: () => controller.isPasswordVisible.value =
                          !controller.isPasswordVisible.value,
                      child: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              UniversityDropdown(
                selectedUniversity: controller.selectedUniversity,
                isUniversityValid: controller.isUniversityValid,
                universities: controller.universities,
                onUniversitySelected: controller.selectUniversity,
                placeholder: ScreenStrings.universityHint,
              ),
              const SizedBox(height: 10),
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Text(
                            ScreenStrings.termsAndPrivacy,
                          ),
                        ),
                      )
                    ],
                  )),
              const SizedBox(height: 20),
              Obx(() => CustomButton(
                    text: ScreenStrings.signUpButton,
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.isSubmitting.value
                        ? () {}
                        : () => controller.submit(),
                  )),
              const SizedBox(height: 30),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: ScreenStrings.alreadyHaveAccount,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: ScreenStrings.loginText,
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
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
