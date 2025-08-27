import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../infrastructure/theme/app_theme.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/utils/app.constants.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import '../utils/screens.strings.dart';
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
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: SvgPicture.asset(
                "assets/icons/TravelIB.svg",
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio buttons for user type selection
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'student',
                          groupValue: controller.selectedUserType.value,
                          onChanged: (String? value) {
                            controller.selectedUserType.value = value!;
                          },
                          activeColor: primaryColor,
                        ),
                        Text(
                          'Student',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                controller.selectedUserType.value == 'student'
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 30),
                        Radio<String>(
                          value: 'interpreter',
                          groupValue: controller.selectedUserType.value,
                          onChanged: (String? value) {
                            controller.selectedUserType.value = value!;
                            // Immediately navigate to interpreter sign-up flow
                            Get.offAllNamed('/interpreter/signup');
                          },
                          activeColor: primaryColor,
                        ),
                        Text(
                          'Interpreter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: controller.selectedUserType.value ==
                                    'interpreter'
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
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
                      hintText: ScreenStrings.phoneHint,
                      labelText: ScreenStrings.phoneLabel,
                      controller: controller.phoneController,
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      errorText: controller.isPhoneValid.value
                          ? null
                          : controller.phoneController.text.trim().isEmpty
                              ? ScreenStrings.requiredFieldError
                              : ScreenStrings.phoneValidationError,
                      onChanged: (_) => controller.validatePhone(),
                      prefix: Obx(() => controller.isLoadingFlag.value
                          ? Container(
                              padding: const EdgeInsets.all(12.0),
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color.fromARGB(255, 206, 186, 198)),
                              ),
                            )
                          : controller.countryFlagUrl.value.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.network(
                                    controller.countryFlagUrl.value,
                                    width: 16,
                                    height: 16,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text('🇬🇭');
                                    },
                                  ),
                                )
                              : Text('🇬🇭')),
                    )),
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
                          ? null
                          : () => controller.signUp(),
                    )),
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
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ), // Colored text
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.offAndToNamed(StudentRoutes
                                  .LOGIN); // Navigate to login page
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
