import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/utils/app.constants.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import '../utils/screens.strings.dart';
import 'controllers/signup.controller.dart';

class SignupScreen extends GetView<SignupController> {
  SignupScreen({super.key});

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
                Container(
                  // height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.isPhoneValid.value
                          ? Colors.grey.shade300
                          : Colors.red,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      controller.phoneController.text =
                          number.phoneNumber ?? '';
                      controller.validatePhone();
                    },
                    onInputValidated: (bool value) {
                      controller.isPhoneValid.value = value;
                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(color: Colors.black),
                    initialValue: PhoneNumber(isoCode: 'GH'),
                    formatInput: true,
                    keyboardType: TextInputType.phone,
                    inputDecoration: InputDecoration(
                      labelText: ScreenStrings.phoneLabel,
                      hintText: ScreenStrings.phoneHint,
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
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
                      text: controller.isPhoneOtpLoading.value
                          ? 'Sending OTP...'
                          : ScreenStrings.signUpButton,
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
                              Get.offAndToNamed(
                                  Routes.LOGIN); // Navigate to login page
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
