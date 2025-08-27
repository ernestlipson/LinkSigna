import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/theme/app_theme.dart';
import 'controllers/settings.controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Navigation Tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // Content based on selected tab
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
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primaryColor : Colors.transparent,
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
            color: isSelected ? primaryColor : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
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
                      backgroundColor: primaryColor,
                      child: Icon(
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
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Basic Information Section
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),

          // Full Name
          Obx(() => _buildFormField(
                'Full name',
                controller.fullNameController,
                controller.displayName.value.isEmpty
                    ? 'Enter your full name'
                    : controller.displayName.value,
              )),
          SizedBox(height: 16),

          // Phone Number
          _buildPhoneNumberField(),
          SizedBox(height: 16),

          // University & Level
          _buildUniversityLevelField(),
          SizedBox(height: 16),

          // Languages
          _buildFormField(
            'Languages',
            controller.languagesController,
            'Ghanaian Sign Language',
          ),
          SizedBox(height: 12),

          // Add Language Button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => controller.addLanguage(),
              icon: Icon(Icons.add, color: primaryColor, size: 20),
              label: Text(
                'Add Language',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Save Changes Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => controller.saveChanges(),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 0),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 32),

          // Delete Account Section
          Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Deleting your account will remove all of your activity and campaigns, and you will no longer be able to sign in with this account.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => controller.deleteAccount(),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 0),
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Delete account',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 20),
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
        SizedBox(height: 8),
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
              borderSide: BorderSide(color: primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller.phoneController,
              decoration: InputDecoration(
                hintText: controller.displayPhone.value.isEmpty
                    ? 'Enter your phone number'
                    : controller.displayPhone.value,
                prefixIcon: Container(
                  margin: EdgeInsets.all(8),
                  width: 24,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    image: DecorationImage(
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
                  borderSide: BorderSide(color: primaryColor),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )),
      ],
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
