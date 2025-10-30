import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../infrastructure/theme/app_theme.dart';
import '../../../../shared/components/settings/settings_screen_layout.component.dart';
import 'controllers/interpreter_settings.controller.dart';
import 'package:sign_language_app/shared/components/settings/profile_avatar_picker.dart';
import 'package:sign_language_app/shared/components/settings/settings_form_field.dart';
import 'package:sign_language_app/shared/components/settings/phone_number_field.dart';
import 'package:sign_language_app/shared/components/settings/delete_account_section.component.dart';
import 'package:sign_language_app/shared/components/settings/save_changes_button.component.dart';
import 'package:sign_language_app/shared/components/settings/settings_section_header.component.dart';
import 'package:sign_language_app/shared/components/settings/empty_notifications_tab.component.dart';
import 'package:sign_language_app/shared/components/settings/settings_outlined_button.component.dart';

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
                placeholder: 'Enter your email',
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

          // Logout
          SettingsOutlinedButton(
            onPressed: () => controller.logout(),
            label: 'Logout',
            color: AppColors.primary,
          ),

          const SizedBox(height: 40),

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
        Text(
          'Professional Experience',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        // Multiline text field for entering professional experience
        TextField(
          controller: controller.experienceController,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: controller.experienceController.text.isEmpty
                ? 'Describe your professional experience'
                : controller.experienceController.text,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceYearsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Years in Sign Language',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.certificationController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: controller.certificationController.text.isEmpty
                ? 'Enter years of experience'
                : controller.certificationController.text,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixText: 'yrs',
          ),
        ),
      ],
    );
  }
}
