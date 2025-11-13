import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/utils/app_strings.dart';

import '../../../../shared/components/settings/settings_screen_layout.component.dart';
import 'controllers/interpreter_settings.controller.dart';
import 'package:sign_language_app/shared/components/settings/profile_avatar_picker.dart';
import 'package:sign_language_app/shared/components/settings/settings_form_field.dart';
import 'package:sign_language_app/shared/components/settings/phone_number_field.dart';
import 'package:sign_language_app/shared/components/settings/delete_account_section.component.dart';
import 'package:sign_language_app/shared/components/settings/save_changes_button.component.dart';
import 'package:sign_language_app/shared/components/settings/settings_section_header.component.dart';
import 'package:sign_language_app/shared/components/settings/empty_notifications_tab.component.dart';
import 'package:sign_language_app/shared/components/app.field.dart';

class InterpreterSettingsScreen extends GetView<InterpreterSettingsController> {
  final bool showBackButton;

  const InterpreterSettingsScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => InterpreterSettingsController());

    return SettingsScreenLayout(
      selectedTab: controller.selectedTab,
      buildProfileTab: _buildProfileTab,
      buildNotificationsTab: _buildNotificationsTab,
      useSafeArea: true,
      appBar: showBackButton ? _buildBackAppBar() : null,
    );
  }

  PreferredSizeWidget _buildBackAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Settings',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Profile Picture
          Center(
            child: Obx(() => ProfileAvatarPicker(
                  avatarWidget: controller.getProfileImageWidget(),
                  onTap: controller.pickProfileImage,
                  isUploading: controller.isUploadingImage.value,
                )),
          ),
          const SizedBox(height: 24),

          // Basic Information Section
          const SettingsSectionHeader(title: 'Basic Information'),
          const SizedBox(height: 16),

          // Full Name
          Obx(() => _buildFormField(
                'Full name',
                controller.fullNameController,
                controller.displayName.value.isEmpty
                    ? 'Enter your full name'
                    : '',
                placeholder: 'Enter your full name',
              )),
          const SizedBox(height: 16),

          // Email
          Obx(() => _buildFormField(
                'Email',
                controller.emailController,
                controller.displayEmail.value.isEmpty ? 'Enter your email' : '',
                placeholder: AppStrings.emailHint,
              )),
          const SizedBox(height: 16),

          // Phone Number
          _buildPhoneNumberField(),
          const SizedBox(height: 16),
          // Experience Level
          _buildExperienceLevelField(),
          const SizedBox(height: 16),

          // Certification
          _buildExperienceYearsField(),

          const SizedBox(height: 24),

          // Save Changes Button
          SaveChangesButton(
            isSaving: controller.isSaving,
            onSave: () => controller.saveChangesAsync(),
          ),
          const SizedBox(height: 20),

          // Delete Account Section
          DeleteAccountSection(
            onDelete: () => controller.deleteAccount(),
            description:
                'Deleting your account will remove all of your activity and sessions, and you will no longer be able to sign in with this account.',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return const EmptyNotificationsTab();
  }

  Widget _buildFormField(
      String label, TextEditingController controller, String displayText,
      {String? placeholder}) {
    return SettingsFormField(
      label: label,
      controller: controller,
      placeholder: placeholder ?? displayText,
    );
  }

  Widget _buildPhoneNumberField() {
    return Obx(() => PhoneNumberField(
          phoneController: controller.phoneController,
          displayPhone: controller.displayPhone.value,
        ));
  }

  Widget _buildExperienceLevelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          labelText: 'Professional Experience',
          hintText: 'Describe your professional experience',
          controller: controller.experienceController,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }

  Widget _buildExperienceYearsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          labelText: 'Years in Sign Language',
          hintText: 'Enter years of experience',
          controller: controller.certificationController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          suffix: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              widthFactor: 1,
              child: Text(
                'yrs',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
