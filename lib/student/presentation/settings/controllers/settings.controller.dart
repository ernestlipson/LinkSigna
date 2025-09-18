import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/cloudinary.config.dart';
import '../../../../infrastructure/dal/services/cloudinary.service.dart';
import '../../shared/controllers/user.controller.dart';
import '../../shared/controllers/student_user.controller.dart';

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
  final RxBool isSaving = false.obs;
  final RxString userDocId = ''.obs;
  final ImagePicker _picker = ImagePicker();

  // Cloudinary Service
  late CloudinaryService _cloudinary;

  // Available languages list
  final List<String> availableLanguages = [
    'Ghanaian Sign Language',
  ];

  // Available university levels
  final List<int> availableLevels = [100, 200, 300, 400, 500];

  @override
  void onInit() {
    super.onInit();
    _cloudinary = Get.put(CloudinaryService());
    _loadUserData();
    _loadExistingProfileImage(); // Add this
  }

  void _loadExistingProfileImage() {
    // Load existing profile image if user has one
    if (Get.isRegistered<UserController>()) {
      final userController = Get.find<UserController>();
      if (userController.localImagePath.value.isNotEmpty) {
        final file = File(userController.localImagePath.value);
        if (file.existsSync()) {
          profileImage.value = file;
        }
      }
    }
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

      // Load existing stored Firestore doc id if any
      userDocId.value = prefs.getString('user_doc_id') ?? '';

      // Load profile image URL from Firebase Storage
      await _loadProfileImageUrl();

      // Attempt to discover Firestore doc if unknown and we have a phone
      if (userDocId.value.isEmpty && phoneController.text.trim().isNotEmpty) {
        try {
          final q = await FirebaseFirestore.instance
              .collection('users')
              .where('phone', isEqualTo: phoneController.text.trim())
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) {
            userDocId.value = q.docs.first.id;
            await prefs.setString('user_doc_id', userDocId.value);
          }
        } catch (e) {
          Get.log('Error locating user doc by phone: $e');
        }
      }
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

  Future<String> _resolveUserIdentifier() async {
    try {
      // Prefer cached Firestore student doc id
      final prefs = await SharedPreferences.getInstance();
      final cachedDocId = prefs.getString('student_user_doc_id');
      if (cachedDocId != null && cachedDocId.isNotEmpty) {
        return cachedDocId;
      }
      // Fallback to Firebase Auth UID
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      if (authUid != null && authUid.isNotEmpty) {
        return authUid;
      }
      // Last resort: userName from prefs (legacy), ensures consistent publicId
      final legacy = prefs.getString('userName') ?? 'User';
      return legacy;
    } catch (_) {
      return FirebaseAuth.instance.currentUser?.uid ?? 'User';
    }
  }

  /// Load profile image URL from Cloudinary (via local cache)
  Future<void> _loadProfileImageUrl() async {
    try {
      final userId = await _resolveUserIdentifier();

      final imageUrl = await _cloudinary.getProfileImageUrl(userId);
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

        // Update UserController with new profile image path
        if (Get.isRegistered<UserController>()) {
          final userController = Get.find<UserController>();
          userController.setLocalProfileImage(image.path);
        }

        // Show success message
        Get.snackbar(
          'Image Selected',
          'Profile image selected successfully! Uploading to cloud...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue[100],
          colorText: Colors.blue[900],
        );

        // Upload to Cloudinary
        await _uploadProfileImageToCloudinary(File(image.path));
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

  /// Upload profile image to Cloudinary and update Firestore
  Future<void> _uploadProfileImageToCloudinary(File imageFile) async {
    try {
      isUploadingImage.value = true;

      final userId = await _resolveUserIdentifier();

      // Upload image to Cloudinary (overwrites by publicId)
      final downloadUrl = await _cloudinary.uploadProfileImage(
        imageFile: imageFile,
        userId: userId,
        folder: CloudinaryConfig.folderStudents,
      );

      if (downloadUrl != null) {
        // Update the profile image URL in UI
        profileImageUrl.value = downloadUrl;

        // Update UserController with new profile image URL
        if (Get.isRegistered<UserController>()) {
          final userController = Get.find<UserController>();
          userController.setUser(photo: downloadUrl);
        }

        // Update Firestore student document via controller (avatarUrl)
        if (Get.isRegistered<StudentUserController>()) {
          final stuCtrl = Get.find<StudentUserController>();
          await stuCtrl.updateProfile({'avatarUrl': downloadUrl});
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

        Get.log('Cloudinary upload success: $downloadUrl');
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
            SizedBox(
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
            SizedBox(
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
    // Legacy no-op replaced by Firestore version below (kept for potential backward compatibility call sites)
    saveChangesAsync();
  }

  List<String> _parseLanguages() {
    final raw = languagesController.text.trim();
    if (raw.isEmpty) return [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> _ensureUserDocExists() async {
    if (userDocId.value.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final col = FirebaseFirestore.instance.collection('users');
    final id = const Uuid().v4();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    await col.doc(id).set({
      'displayName': fullNameController.text.trim(),
      'phone': phoneController.text.trim(),
      'languages': _parseLanguages(),
      'universityLevel': universityLevel.value,
      'photoUrl': profileImageUrl.value,
      'role': 'student',
      'authUid': authUid,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
    userDocId.value = id;
    await prefs.setString('user_doc_id', id);
  }

  Future<void> saveChangesAsync() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      await _ensureUserDocExists();
      if (userDocId.value.isEmpty) {
        throw 'Unable to resolve user document.';
      }
      // Map to StudentUser schema
      final nameParts = fullNameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      final updateData = {
        'firstname': firstName,
        'lastname': lastName,
        'phone': phoneController.text.trim(),
        'language': languagesController.text.trim(),
        'university_level': universityLevel.value,
        if (profileImageUrl.value.isNotEmpty)
          'avatarUrl': profileImageUrl.value,
      };

      // Prefer updating via StudentUserController to ensure consistency
      if (Get.isRegistered<StudentUserController>()) {
        final stuCtrl = Get.find<StudentUserController>();
        await stuCtrl.updateProfile(updateData);
      } else if (userDocId.value.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocId.value)
            .set(updateData, SetOptions(merge: true));
      }

      // Persist locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', fullNameController.text.trim());
      await prefs.setString('userPhone', phoneController.text.trim());
      if (userDocId.value.isNotEmpty) {
        await prefs.setString('user_doc_id', userDocId.value);
      }

      displayName.value = fullNameController.text.trim();
      displayPhone.value = phoneController.text.trim();
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().setUser(
          name: displayName.value,
          phone: displayPhone.value,
          photo:
              profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
        );
      }

      Get.snackbar(
        'Saved',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        'Could not save changes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isSaving.value = false;
    }
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
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    universityController.dispose();
    languagesController.dispose();
    super.onClose();
  }
}
