import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/utils/app_strings.dart';

import '../../../../shared/components/settings/settings_screen_layout.component.dart';
import 'controllers/interpreter_settings.controller.dart';
import 'package:sign_language_app/shared/components/settings/profile_avatar_picker.dart';
import 'package:sign_language_app/shared/components/settings/settings_form_field.dart';
import 'package:sign_language_app/shared/components/settings/delete_account_section.component.dart';
import 'package:sign_language_app/shared/components/settings/save_changes_button.component.dart';
import 'package:sign_language_app/shared/components/settings/settings_section_header.component.dart';
import 'package:sign_language_app/shared/components/app.field.dart';

class InterpreterSettingsScreen extends GetView<InterpreterSettingsController> {
  const InterpreterSettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => InterpreterSettingsController());

    return SettingsScreenLayout(
      selectedTab: controller.selectedTab,
      buildProfileTab: _buildProfileTab,
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

          // Subject
          Obx(() => _buildFormField(
                'Subject',
                controller.subjectController,
                controller.displaySubject.value.isEmpty
                    ? 'Enter your subject'
                    : '',
                placeholder: 'e.g., Mathematics, Science, History',
              )),
          const SizedBox(height: 16),

          const SizedBox(height: 16),
          // Experience Level
          _buildExperienceLevelField(),

          const SizedBox(height: 20),

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
            isEnabled: false,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
}
