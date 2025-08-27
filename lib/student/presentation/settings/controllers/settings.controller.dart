import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../shared/controllers/user.controller.dart';
import '../../../infrastructure/services/firebase_storage_service.dart';

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
  final RxString profileImageUrl = ''.obs;
  final RxString displayName = ''.obs;
  final RxString displayPhone = ''.obs;
  final RxBool isUploadingImage = false.obs;
  final ImagePicker _picker = ImagePicker();

  // Firebase Storage Service
  late FirebaseStorageService _storageService;

  // Available languages list
  final List<String> availableLanguages = [
    'Ghanaian Sign Language',
  ];

  // Available university levels
  final List<int> availableLevels = [100, 200, 300, 400, 500];

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.put(FirebaseStorageService());
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user name from SharedPreferences (saved during signup)
      final userName = prefs.getString('userName') ?? '';
      fullNameController.text = userName;
      displayName.value = userName;

      // Try to get user data from UserController if available
      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        if (userController.user.value?.name?.isNotEmpty == true) {
          fullNameController.text = userController.user.value!.name!;
          displayName.value = userController.user.value!.name!;
        }
        if (userController.user.value?.phone?.isNotEmpty == true) {
          phoneController.text = userController.user.value!.phone!;
          displayPhone.value = userController.user.value!.phone!;
        }
      }

      // Load phone number from SharedPreferences if available
      final userPhone = prefs.getString('userPhone') ?? '';
      if (userPhone.isNotEmpty && phoneController.text.isEmpty) {
        phoneController.text = userPhone;
        displayPhone.value = userPhone;
      }

      // Set default values if no user data is found
      if (fullNameController.text.isEmpty) {
        fullNameController.text = 'User';
        displayName.value = 'User';
      }
      if (phoneController.text.isEmpty) {
        phoneController.text = '';
        displayPhone.value = '';
      }

      // Keep existing default values for other fields
      universityController.text = 'TTU- Level 300';
      universityLevel.value = 'TTU - Level 300';
      languagesController.text = 'Ghanaian Sign Language';

      // Load profile image URL from Firebase Storage
      await _loadProfileImageUrl();
    } catch (e) {
      // Fallback to default values on error
      fullNameController.text = 'User';
      displayName.value = 'User';
      phoneController.text = '';
      displayPhone.value = '';
      universityController.text = 'TTU- Level 300';
      universityLevel.value = 'TTU - Level 300';
      languagesController.text = 'Ghanaian Sign Language';
    }
  }

  /// Load profile image URL from Firebase Storage
  Future<void> _loadProfileImageUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('userName') ?? 'User';

      // Check if user has a profile image in Firebase Storage
      final imageUrl = await _storageService.getProfileImageUrl(userName);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        profileImageUrl.value = imageUrl;

        // Update UserController with loaded profile image URL
        if (Get.isRegistered<UserController>()) {
          final userController = Get.find<UserController>();
          userController.setUser(photo: imageUrl);
        }

        Get.log('Profile image URL loaded: $imageUrl');
      }
    } catch (e) {
      Get.log('Error loading profile image URL: $e');
    }
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
        // Set the local file for immediate UI update
        profileImage.value = File(image.path);

        // Show success message
        Get.snackbar(
          'Image Selected',
          'Profile image selected successfully! Uploading to cloud...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue[100],
          colorText: Colors.blue[900],
        );

        // Upload to Firebase Storage
        await _uploadProfileImageToFirebase(File(image.path));
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

  /// Upload profile image to Firebase Storage
  Future<void> _uploadProfileImageToFirebase(File imageFile) async {
    try {
      isUploadingImage.value = true;

      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('userName') ?? 'User';

      // Upload image to Firebase Storage (will auto-replace old image)
      final downloadUrl =
          await _storageService.uploadProfileImage(imageFile, userName);

      if (downloadUrl != null) {
        // Update the profile image URL
        profileImageUrl.value = downloadUrl;

        // Update UserController with new profile image URL
        if (Get.isRegistered<UserController>()) {
          final userController = Get.find<UserController>();
          userController.setUser(photo: downloadUrl);
        }

        // Clear the local file since we now have a cloud URL
        profileImage.value = null;

        Get.snackbar(
          'Success',
          'Profile image updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );

        Get.log('Profile image uploaded successfully: $downloadUrl');
      } else {
        // Keep the local file if upload failed
        Get.snackbar(
          'Upload Failed',
          'Failed to upload image to cloud. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
        );
      }
    } catch (e) {
      Get.log('Error uploading profile image: $e');
      Get.snackbar(
        'Error',
        'Failed to upload profile image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );

      // Ensure loader stops even on error
      profileImage.value = null;
    } finally {
      // Always stop the loader
      isUploadingImage.value = false;
    }
  }

  /// Get the current profile image widget
  Widget getProfileImageWidget() {
    if (profileImageUrl.value.isNotEmpty) {
      // Show cached network image from Firebase Storage
      return CachedNetworkImage(
        imageUrl: profileImageUrl.value,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 50,
          backgroundColor: Colors.pink[100],
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: 50,
          backgroundColor: Colors.pink[100],
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 50,
          backgroundColor: Colors.pink[100],
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
      );
    } else if (profileImage.value != null) {
      // Show local file image
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.pink[100],
        backgroundImage: FileImage(profileImage.value!),
      );
    } else {
      // Show default avatar
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.pink[100],
        child: Icon(Icons.person, size: 50, color: Colors.white),
      );
    }
  }

  /// Check if user has a profile image (either local or cloud)
  bool get hasProfileImage {
    return profileImageUrl.value.isNotEmpty || profileImage.value != null;
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
