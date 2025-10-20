import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../shared/components/app.button.dart';
import '../../../shared/components/app.field.dart';
import '../../infrastructure/theme/app_theme.dart';
import '../utils/screens.strings.dart';
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
            SvgPicture.asset(
              "assets/icons/TravelIB.svg",
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'student',
                          groupValue: controller.selectedUserType.value,
                          onChanged: (String? value) {
                            controller.selectedUserType.value = value!;
                          },
                          activeColor: AppColors.primary,
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
                            Get.offAllNamed('/interpreter/signup');
                          },
                          activeColor: AppColors.primary,
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
                      obscureText: true,
                      errorText: controller.isPasswordValid.value
                          ? null
                          : ScreenStrings.requiredFieldError,
                      onChanged: (value) => controller.validatePassword(),
                    )),
                SizedBox(height: 10),
                Obx(() => _buildUniversityField()),
                SizedBox(height: 10),

                // Obx(() => CustomTextFormField(
                //       hintText: ScreenStrings.phoneHint,
                //       labelText: ScreenStrings.phoneLabel,
                //       controller: controller.phoneController,
                //       isRequired: true,
                //       keyboardType: TextInputType.phone,
                //       errorText: controller.isPhoneValid.value
                //           ? null
                //           : controller.phoneController.text.trim().isEmpty
                //               ? ScreenStrings.requiredFieldError
                //               : ScreenStrings.phoneValidationError,
                //       onChanged: (_) => controller.validatePhone(),
                //       prefix: Obx(() => controller.isLoadingFlag.value
                //           ? Container(
                //               padding: const EdgeInsets.all(12.0),
                //               width: 10,
                //               height: 10,
                //               child: CircularProgressIndicator(
                //                 strokeWidth: 2,
                //                 valueColor: AlwaysStoppedAnimation<Color>(
                //                     const Color.fromARGB(255, 206, 186, 198)),
                //               ),
                //             )
                //           : controller.countryFlagUrl.value.isNotEmpty
                //               ? Padding(
                //                   padding: const EdgeInsets.all(10.0),
                //                   child: Image.network(
                //                     controller.countryFlagUrl.value,
                //                     width: 16,
                //                     height: 16,
                //                     errorBuilder: (context, error, stackTrace) {
                //                       return Text('🇬🇭');
                //                     },
                //                   ),
                //                 )
                //               : Text('🇬🇭')),
                //     )),
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

  Widget _buildUniversityField() {
    return SizedBox(
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'University ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          GestureDetector(
            onTap: () => _showUniversityBottomSheet(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.isUniversityValid.value
                      ? Colors.grey[300]!
                      : Colors.red,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.selectedUniversity.value.isEmpty
                            ? ScreenStrings.universityHint
                            : controller.selectedUniversity.value,
                        style: TextStyle(
                          color: controller.selectedUniversity.value.isEmpty
                              ? Colors.grey[600]
                              : Colors.black,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUniversityBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            // Title
            Text(
              'Select University',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ...controller.universities.map((university) => Obx(
                  () => _buildUniversityListItem(university),
                )),
            SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildUniversityListItem(String university) {
    final isSelected = controller.selectedUniversity.value == university;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFFFF0F5) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[200]!,
          width: isSelected ? 1 : 0.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          university,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () {
          controller.selectUniversity(university);
          Get.back();
        },
      ),
    );
  }
}
