import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/settings/settings_screen_layout.component.dart';
import 'controllers/settings.controller.dart';
import 'package:sign_language_app/shared/components/settings/profile_avatar_picker.dart';
import 'package:sign_language_app/shared/components/settings/settings_form_field.dart';
import 'package:sign_language_app/shared/components/settings/delete_account_section.component.dart';
import 'package:sign_language_app/shared/components/settings/save_changes_button.component.dart';
import 'package:sign_language_app/shared/components/settings/settings_section_header.component.dart';
// import 'package:sign_language_app/shared/components/settings/empty_notifications_tab.component.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreenLayout(
      selectedTab: controller.selectedTab,
      buildProfileTab: _buildProfileTab,
      // buildNotificationsTab: _buildNotificationsTab,
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Center(
            child: Obx(() => ProfileAvatarPicker(
                  avatarWidget: controller.getProfileImageWidget(),
                  onTap: controller.pickProfileImage,
                  isUploading: controller.isUploadingImage.value,
                )),
          ),
          SizedBox(height: 24),
          SettingsSectionHeader(title: 'Basic Information'),
          SizedBox(height: 16),
          Obx(() => _buildFormField(
                'Full name',
                controller.fullNameController,
                controller.displayName.value.isEmpty
                    ? 'Enter your full name'
                    : controller.displayName.value,
              )),
          SizedBox(height: 16),
          _buildUniversityLevelField(),
          SizedBox(height: 16),
          _buildFormField(
            'Languages',
            controller.languagesController,
            'Ghanaian Sign Language',
          ),
          SizedBox(height: 24),
          SaveChangesButton(
            isSaving: controller.isSaving,
            onSave: () => controller.saveChangesAsync(),
          ),
          SizedBox(height: 32),
          DeleteAccountSection(
            onDelete: () => controller.deleteAccount(),
            isEnabled: false,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormField(
      String label, TextEditingController controller, String placeholder) {
    return SettingsFormField(
      label: label,
      controller: controller,
      placeholder: placeholder,
    );
  }

  Widget _buildUniversityLevelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'University & Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => controller.selectUniversityLevel(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                        controller.universityLevel.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      )),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
