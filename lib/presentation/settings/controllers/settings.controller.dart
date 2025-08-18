import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SettingsController extends GetxController {
  // Tab selection
  final RxInt selectedTab = 0.obs;

  // Form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final universityController = TextEditingController();
  final languagesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    // Load user data into form fields
    fullNameController.text = 'Sarah Johnson';
    phoneController.text = '023 4432 2224';
    universityController.text = 'TTU- Level 300';
    languagesController.text = 'Ghanaian Sign Language';
  }

  void editProfile() {
    Get.snackbar(
      'Edit Profile',
      'Edit profile functionality will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addLanguage() {
    Get.snackbar(
      'Add Language',
      'Add language functionality will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveChanges() {
    Get.snackbar(
      'Success',
      'Changes saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
    );
  }

  void changePassword() {
    Get.snackbar(
      'Change Password',
      'Change password functionality will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Account'),
        content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Account Deleted',
                'Your account has been deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[100],
                colorText: Colors.red[900],
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    universityController.dispose();
    languagesController.dispose();
    super.onClose();
  }
}
