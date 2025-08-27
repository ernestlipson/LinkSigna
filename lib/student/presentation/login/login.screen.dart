import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../infrastructure/utils/app.constants.dart';

import '../../infrastructure/navigation/routes.dart';
import '../components/app.button.dart';
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
                  Container(
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
                  // Password Field
                  // Obx(() {
                  //   return CustomTextFormField(
                  //     hintText: ScreenStrings.passwordHint,
                  //     labelText: ScreenStrings.passwordLabel,
                  //     controller: controller.passwordController,
                  //     obscureText: !controller.isPasswordVisible
                  //         .value, // Toggle based on visibility state
                  //     isRequired: true,
                  //     errorText: controller.isPasswordValid.value
                  //         ? null
                  //         : ScreenStrings.requiredFieldError,
                  //     suffix: IconButton(
                  //       onPressed: controller
                  //           .togglePasswordVisibility, // Use the controller method
                  //       icon: Icon(
                  //         controller.isPasswordVisible.value
                  //             ? Icons
                  //                 .visibility_off // Show this when password is visible
                  //             : Icons
                  //                 .visibility, // Show this when password is hidden
                  //         color: Colors.black.withAlpha(64),
                  //         size: 20,
                  //       ),
                  //     ),
                  //   );
                  // }),
                  // SizedBox(height: 10),
                  // //Add a Row containing a Remember me toggle and Forgot Password
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     // Remember Me Toggle
                  //     Row(
                  //       children: [
                  //         Obx(() => Checkbox(
                  //               side: BorderSide(color: Color(0xFFFFD6E7)),
                  //               shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(4.0),
                  //               ),
                  //               value: controller.isRememberMe.value,
                  //               onChanged: (bool? newValue) {
                  //                 controller.isRememberMe.value =
                  //                     newValue ?? false;
                  //               },
                  //             )),
                  //         Text(
                  //           ScreenStrings.rememberMe,
                  //           style: TextStyle(
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w400,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     // Forgot Password Link
                  //     GestureDetector(
                  //       onTap: () {
                  //         print("Navigating to forgot password screen");
                  //         Get.toNamed(Routes.FORGOT_PASSWORD);
                  //       },
                  //       child: Text(
                  //         ScreenStrings.forgotPassword,
                  //         style: TextStyle(
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w500,
                  //           color: Color(0xFF9E1068),
                  //           decoration: TextDecoration.underline,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 20),
                  Obx(() => CustomButton(
                        text: controller.isPhoneOtpLoading.value
                            ? "Sending OTP..."
                            : "Log In",
                        onPressed: controller.isPhoneOtpLoading.value
                            ? () {} // Disabled when loading
                            : () => controller.sendPhoneOTP(),
                      )),
                  SizedBox(height: 24),
                  // Center(child: Text("Or")), // Center the "Or" text
                  // SizedBox(height: 16),

                  // Google Sign In Button
                  // Obx(() => GoogleSignInButton(
                  //       onPressed: controller.isGoogleSignInLoading.value
                  //           ? null
                  //           : controller.signInWithGoogle,
                  //       isLoading: controller.isGoogleSignInLoading.value,
                  //     )),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: "Don't have an account? ",
                          ),
                          TextSpan(
                            text: "SignUp",
                            style: TextStyle(
                              color: Color(0xFF9E1068),
                              // decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(StudentRoutes.SIGNUP);
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
