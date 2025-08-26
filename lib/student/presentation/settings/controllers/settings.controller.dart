import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsController extends GetxController {
  // Tab selection
  final RxInt selectedTab = 0.obs;

  // Form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final universityController = TextEditingController();
  final languagesController = TextEditingController();

  // Observable variables for reactive UI
  final RxString universityLevel = 'TTU - Level 300'.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // Available languages list
  final List<String> availableLanguages = [
    'Ghanaian Sign Language',
    // 'American Sign Language (ASL)',
    // 'British Sign Language (BSL)',
    // 'Australian Sign Language (Auslan)',
    // 'French Sign Language (LSF)',
    // 'German Sign Language (DGS)',
    // 'Japanese Sign Language (JSL)',
    // 'Chinese Sign Language (CSL)',
    // 'Korean Sign Language (KSL)',
    // 'Brazilian Sign Language (Libras)',
    // 'Mexican Sign Language (LSM)',
    // 'Spanish Sign Language (LSE)',
    // 'Italian Sign Language (LIS)',
    // 'Dutch Sign Language (NGT)',
    // 'Swedish Sign Language (STS)',
    // 'Norwegian Sign Language (NTS)',
    // 'Danish Sign Language (DTS)',
    // 'Finnish Sign Language (FinSL)',
    // 'Russian Sign Language (RSL)',
    // 'Polish Sign Language (PJM)',
  ];

  // Available university levels
  final List<int> availableLevels = [100, 200, 300, 400, 500];

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
    universityLevel.value = 'TTU - Level 300';
    languagesController.text = 'Ghanaian Sign Language';
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        profileImage.value = File(image.path);
        Get.snackbar(
          'Success',
          'Profile image updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void editProfile() {
    Get.snackbar(
      'Edit Profile',
      'Edit profile functionality will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addLanguage() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Language list
            Container(
              height: 100, // Fixed height for the list
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: availableLanguages.length,
                itemBuilder: (context, index) {
                  final language = availableLanguages[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    title: Text(
                      language,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: languagesController.text.contains(language)
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      _selectLanguage(language);
                      Get.back();
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void selectUniversityLevel() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Select University Level',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Level list
            Container(
              height: 300, // Fixed height for the list
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: availableLevels.length,
                itemBuilder: (context, index) {
                  final level = availableLevels[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    title: Text(
                      'Level $level',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      _getLevelDescription(level),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: universityLevel.value.contains('Level $level')
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      _selectUniversityLevel(level);
                      Get.back();
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 100:
        return 'First Year - Foundation courses';
      case 200:
        return 'Second Year - Core courses';
      case 300:
        return 'Third Year - Advanced courses';
      case 400:
        return 'Fourth Year - Specialization';
      case 500:
        return 'Final Year - Research & Thesis';
      default:
        return '';
    }
  }

  void _selectUniversityLevel(int level) {
    // Extract university name from current text (assuming format: "University - Level X")
    final currentText = universityLevel.value;
    String universityName = 'TTU';

    if (currentText.contains('-')) {
      universityName = currentText.split('-')[0].trim();
    }

    // Update both observable and controller
    universityLevel.value = '$universityName - Level $level';
    universityController.text = '$universityName - Level $level';

    Get.snackbar(
      'Level Updated',
      'University level updated to Level $level',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
    );
  }

  void _selectLanguage(String language) {
    final currentLanguages = languagesController.text;

    if (currentLanguages.isEmpty) {
      languagesController.text = language;
    } else if (currentLanguages.contains(language)) {
      // Remove language if already selected
      final languages = currentLanguages.split(', ');
      languages.remove(language);
      languagesController.text = languages.join(', ');
    } else {
      // Add new language
      languagesController.text = '$currentLanguages, $language';
    }

    Get.snackbar(
      'Language Updated',
      'Language selection updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
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
