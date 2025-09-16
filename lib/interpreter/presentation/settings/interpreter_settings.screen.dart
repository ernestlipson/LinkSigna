import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../infrastructure/theme/app_theme.dart';
import 'controllers/interpreter_settings.controller.dart';

class InterpreterSettingsScreen extends GetView<InterpreterSettingsController> {
  const InterpreterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => InterpreterSettingsController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => _buildTab(
                        'Profile',
                        controller.selectedTab.value == 0,
                        () => controller.selectedTab.value = 0,
                      )),
                ),
                Expanded(
                  child: Obx(() => _buildTab(
                        'Notifications',
                        controller.selectedTab.value == 1,
                        () => controller.selectedTab.value = 1,
                      )),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => controller.selectedTab.value == 0
                ? _buildProfileTab()
                : _buildNotificationsTab()),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          ),
        ),
      ),
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
            child: GestureDetector(
              onTap: () => controller.pickProfileImage(),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Profile Image with Firebase Storage support
                  Obx(() => controller.getProfileImageWidget()),

                  // Camera icon overlay
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Upload progress indicator
                  if (controller.isUploadingImage.value)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Basic Information Section
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Full Name
          Obx(() => _buildFormField(
                'Full name',
                controller.fullNameController,
                controller.displayName.value.isEmpty
                    ? 'Enter your full name'
                    : controller.displayName.value,
              )),
          const SizedBox(height: 16),

          // Phone Number
          _buildPhoneNumberField(),
          const SizedBox(height: 16),

          // Professional Information Section
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Experience Level
          _buildExperienceLevelField(),
          const SizedBox(height: 16),

          // Certification
          _buildCertificationField(),
          const SizedBox(height: 16),

          // Languages
          _buildFormField(
            'Languages',
            controller.languagesController,
            'Ghanaian Sign Language',
          ),
          const SizedBox(height: 12),

          // Add Language Button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => controller.addLanguage(),
              icon: const Icon(Icons.add, color: AppColors.primary, size: 20),
              label: const Text(
                'Add Language',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Changes Button
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : () => controller.saveChangesAsync(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 0),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                )),
          ),
          const SizedBox(height: 32),

          // Delete Account Section
          const Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deleting your account will remove all of your activity and sessions, and you will no longer be able to sign in with this account.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => controller.deleteAccount(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 0),
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Delete account',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Center(
      child: Text(
        'No notifications yet',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildFormField(
      String label, TextEditingController controller, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
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

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller.phoneController,
              decoration: InputDecoration(
                hintText: controller.displayPhone.value.isEmpty
                    ? 'Enter your phone number'
                    : controller.displayPhone.value,
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  width: 24,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://flagcdn.com/w40/gh.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
            )),
      ],
    );
  }

  Widget _buildExperienceLevelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => controller.selectExperienceLevel(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                        controller.experience.value,
                        style: const TextStyle(
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

  Widget _buildCertificationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certification',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => controller.selectCertification(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                        controller.certification.value,
                        style: const TextStyle(
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
