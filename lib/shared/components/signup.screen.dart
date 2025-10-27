import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/theme/app_theme.dart';
import '../../infrastructure/utils/screen_strings.dart';
import 'app.button.dart';
import 'app.field.dart';
import 'signup_logo.dart';
import 'university_dropdown.dart';
import 'user_type_selector.dart';

class SharedSignUpScreen extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final RxBool isNameValid;
  final RxBool isEmailValid;
  final RxBool isPasswordValid;
  final RxBool isUniversityValid;
  final RxBool isTermsAccepted;

  final RxBool isPasswordVisible;
  final RxBool isSubmitting;

  final RxString selectedUniversity;
  final List<String> universities;
  final Function(String) onUniversitySelected;

  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPasswordChanged;

  final VoidCallback onSubmit;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback? onLoginNavigate;

  final bool showUserTypeSelector;
  final RxString? selectedUserType;
  final ValueChanged<String>? onUserTypeChanged;

  final String signUpTitle;
  final String signUpButtonText;
  final String loginRoute;
  final String nameErrorText;
  final String emailErrorText;
  final String passwordErrorText;
  final String emailHint;
  final String universityPlaceholder;

  const SharedSignUpScreen({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isNameValid,
    required this.isEmailValid,
    required this.isPasswordValid,
    required this.isUniversityValid,
    required this.isTermsAccepted,
    required this.isPasswordVisible,
    required this.isSubmitting,
    required this.selectedUniversity,
    required this.universities,
    required this.onUniversitySelected,
    required this.onSubmit,
    required this.onTogglePasswordVisibility,
    required this.loginRoute,
    this.onNameChanged,
    this.onEmailChanged,
    this.onPasswordChanged,
    this.onLoginNavigate,
    this.showUserTypeSelector = false,
    this.selectedUserType,
    this.onUserTypeChanged,
    this.signUpTitle = ScreenStrings.signUpTitle,
    this.signUpButtonText = ScreenStrings.signUpButton,
    this.nameErrorText = ScreenStrings.requiredFieldError,
    this.emailErrorText = ScreenStrings.requiredFieldError,
    this.passwordErrorText = ScreenStrings.requiredFieldError,
    this.emailHint = ScreenStrings.emailHint,
    this.universityPlaceholder = ScreenStrings.universityHint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SignupLogo(),
              const SizedBox(height: 20),
              if (showUserTypeSelector &&
                  selectedUserType != null &&
                  onUserTypeChanged != null)
                Obx(() => UserTypeSelector(
                      selectedType: selectedUserType!.value,
                      onTypeChanged: onUserTypeChanged!,
                    )),
              if (showUserTypeSelector) const SizedBox(height: 20),
              Text(
                signUpTitle,
                style: const TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Obx(() => CustomTextFormField(
                    hintText: ScreenStrings.nameHint,
                    labelText: ScreenStrings.nameLabel,
                    controller: nameController,
                    isRequired: true,
                    errorText: isNameValid.value ? null : nameErrorText,
                    onChanged: onNameChanged,
                  )),
              const SizedBox(height: 10),
              Obx(() => CustomTextFormField(
                    hintText: emailHint,
                    labelText: ScreenStrings.emailLabel,
                    controller: emailController,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    errorText: isEmailValid.value ? null : emailErrorText,
                    onChanged: onEmailChanged,
                  )),
              const SizedBox(height: 10),
              Obx(() => CustomTextFormField(
                    hintText: ScreenStrings.passwordHint,
                    labelText: ScreenStrings.passwordLabel,
                    controller: passwordController,
                    isRequired: true,
                    obscureText: !isPasswordVisible.value,
                    errorText: isPasswordValid.value ? null : passwordErrorText,
                    onChanged: onPasswordChanged,
                    suffix: GestureDetector(
                      onTap: onTogglePasswordVisibility,
                      child: Icon(
                        isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              UniversityDropdown(
                selectedUniversity: selectedUniversity,
                isUniversityValid: isUniversityValid,
                universities: universities,
                onUniversitySelected: (value) {
                  onUniversitySelected(value);
                },
                placeholder: universityPlaceholder,
              ),
              const SizedBox(height: 10),
              Obx(() => Row(
                    children: [
                      Checkbox(
                        side: const BorderSide(color: Color(0xFFFFD6E7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        value: isTermsAccepted.value,
                        onChanged: (bool? newValue) {
                          isTermsAccepted.value = newValue ?? false;
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Text(
                            ScreenStrings.termsAndPrivacy,
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 20),
              Obx(() => CustomButton(
                    isLoading: isSubmitting.value,
                    text: signUpButtonText,
                    onPressed: isSubmitting.value ? () {} : onSubmit,
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
                          ..onTap = () {
                            if (onLoginNavigate != null) {
                              onLoginNavigate!();
                            } else {
                              Get.offAndToNamed(loginRoute);
                            }
                          },
                      ),
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
