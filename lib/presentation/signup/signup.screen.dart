import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
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
                Obx(() {
                  return CustomTextFormField(
                    hintText: ScreenStrings.phoneHint,
                    labelText: ScreenStrings.phoneLabel,
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
                                ? Image.network(flag.png, width: 20, height: 20)
                                : SizedBox.shrink();
                      }),
                    ),
                    isRequired: true,
                    errorText: controller.isPhoneValid.value
                        ? null
                        : ScreenStrings.requiredFieldError,
                    onChanged: (value) => controller.validatePhone(),
                  );
                }),
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
                // SizedBox(height: 18),
                // Center(
                //     child: Text(ScreenStrings.orText,
                //         style: TextStyle(
                //           fontWeight: FontWeight.w500,
                //         ))), // Center the "Or" text
                // SizedBox(height: 18),
                // GoogleSignInButton(
                //   onPressed: controller.isGoogleSignInLoading.value
                //       ? null
                //       : controller.signInWithGoogle,
                //   isLoading: controller.isGoogleSignInLoading.value,
                // ),
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
