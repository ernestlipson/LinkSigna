import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

// Removed intl_phone_number_input in favor of CustomTextFormField for consistency
import '../../../infrastructure/navigation/routes.dart';
import '../components/app.button.dart';
import '../components/app.field.dart';
import '../utils/screens.strings.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
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
                        prefix: controller.isLoadingFlag.value
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color.fromARGB(
                                            255, 206, 186, 198)),
                                  ),
                                ),
                              )
                            : controller.countryFlagUrl.value.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.network(
                                      controller.countryFlagUrl.value,
                                      width: 16,
                                      height: 16,
                                      errorBuilder: (context, error, stack) {
                                        return const Text('🇬🇭');
                                      },
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text('🇬🇭'),
                                  ),
                      )),
                  SizedBox(height: 10),

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
                                Get.offAndToNamed(Routes.STUDENT_SIGNUP);
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
