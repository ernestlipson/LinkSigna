import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/theme/app_theme.dart';
import '../../../shared/components/app.button.dart';
import '../../../shared/components/app.field.dart';
import '../../../shared/components/signup_logo.dart';
import '../../../shared/components/university_dropdown.dart';
import '../../../shared/components/user_type_selector.dart';
import 'package:sign_language_app/infrastructure/utils/screen_strings.dart';
import 'controllers/signup.controller.dart';

class StudentSignupScreen extends GetView<SignupController> {
  const StudentSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SignupLogo(),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => UserTypeSelector(
                      selectedType: controller.selectedUserType.value,
                      onTypeChanged: (String value) {
                        controller.selectedUserType.value = value;
                        if (value == 'interpreter') {
                          Get.offAllNamed('/interpreter/signup');
                        }
                      },
                    )),
                SizedBox(height: 20),
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
                    labelText: ScreenStrings.nameLabel,
                    controller: controller.nameController,
                    isRequired: true,
                    errorText: controller.isNameValid.value
                        ? null
                        : ScreenStrings.requiredFieldError,
                    onChanged: (value) => controller.validateName(),
                  );
                }),
                SizedBox(height: 10),
                Obx(() => CustomTextFormField(
                      hintText: ScreenStrings.emailHint,
                      labelText: ScreenStrings.emailLabel,
                      controller: controller.emailController,
                      isRequired: true,
                      keyboardType: TextInputType.emailAddress,
                      errorText: controller.isEmailValid.value
                          ? null
                          : ScreenStrings.requiredFieldError,
                      onChanged: (value) => controller.validateEmail(),
                    )),
                SizedBox(height: 10),
                Obx(() => CustomTextFormField(
                      hintText: ScreenStrings.passwordHint,
                      labelText: ScreenStrings.passwordLabel,
                      controller: controller.passwordController,
                      isRequired: true,
                      obscureText: !controller.isPasswordVisible.value,
                      errorText: controller.isPasswordValid.value
                          ? null
                          : ScreenStrings.requiredFieldError,
                      onChanged: (value) => controller.validatePassword(),
                      suffix: GestureDetector(
                        onTap: () => controller.togglePasswordVisibility(),
                        child: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                      ),
                    )),
                SizedBox(height: 10),
                UniversityDropdown(
                  selectedUniversity: controller.selectedUniversity,
                  isUniversityValid: controller.isUniversityValid,
                  universities: controller.universities,
                  onUniversitySelected: controller.selectUniversity,
                  placeholder: ScreenStrings.universityHint,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Obx(() => Checkbox(
                          side: BorderSide(color: Color(0xFFFFD6E7)),
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
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Text(
                        ScreenStrings.termsAndPrivacy,
                      ),
                    )),
                  ],
                ),
                SizedBox(height: 20),
                Obx(() => CustomButton(
                      isLoading: controller.isPhoneOtpLoading.value,
                      text: ScreenStrings.signUpButton,
                      onPressed: controller.isPhoneOtpLoading.value
                          ? () {}
                          : () => controller.signUp(),
                    )),
                SizedBox(height: 30),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: ScreenStrings.alreadyHaveAccount,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                      children: [
                        TextSpan(
                          text: ScreenStrings.loginText,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.offAndToNamed(
                                Routes.STUDENT_LOGIN,
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 70),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
