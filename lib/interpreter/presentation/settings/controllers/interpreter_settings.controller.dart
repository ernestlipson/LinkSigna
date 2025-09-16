import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../student/infrastructure/dal/services/firebase_storage_service.dart';

class InterpreterSettingsController extends GetxController {
  // Tab selection
  final RxInt selectedTab = 0.obs;

  // Form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final experienceController = TextEditingController();
  final languagesController = TextEditingController();
  final certificationController = TextEditingController();

  // Observable variables for reactive UI
  final RxString experience = 'Senior (5+ years)'.obs;
  final RxString certification = 'Ghana Sign Language Certified'.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;
  final RxString displayName = ''.obs;
  final RxString displayPhone = ''.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isSaving = false.obs;
  final RxString userDocId = ''.obs;
  final ImagePicker _picker = ImagePicker();

  // Firebase Storage Service
  late FirebaseStorageService _storageService;

  // Available experience levels
  final List<String> experienceLevels = [
    'Junior (1-2 years)',
    'Mid-level (3-4 years)',
    'Senior (5+ years)',
    'Expert (10+ years)',
  ];

  // Available certifications
  final List<String> certifications = [
    'Ghana Sign Language Certified',
    'International Sign Language Certified',
    'ASL Certified',
    'BSL Certified',
  ];

  // Available languages list
  final List<String> availableLanguages = [
    'Ghanaian Sign Language',
    'American Sign Language (ASL)',
    'British Sign Language (BSL)',
    'International Sign',
  ];

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

      // Load phone number from SharedPreferences if available
      final userPhone = prefs.getString('userPhone') ?? '';
      if (userPhone.isNotEmpty) {
        phoneController.text = userPhone;
        displayPhone.value = userPhone;
      }

      // Set default values if no user data is found
      if (fullNameController.text.isEmpty) {
        fullNameController.text = 'Interpreter';
        displayName.value = 'Interpreter';
      }

      // Set default values for interpreter-specific fields
      experienceController.text = 'Senior (5+ years)';
      experience.value = 'Senior (5+ years)';
      certificationController.text = 'Ghana Sign Language Certified';
      certification.value = 'Ghana Sign Language Certified';
      languagesController.text = 'Ghanaian Sign Language';

      // Load existing stored Firestore doc id if any
      userDocId.value = prefs.getString('interpreter_doc_id') ?? '';

      // Load profile image URL from Firebase Storage
      await _loadProfileImageFromStorage();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: ${e.toString()}');
    }
  }

  Future<void> _loadProfileImageFromStorage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   final url = await _storageService.getProfileImageUrl(user.uid);
      //   if (url.isNotEmpty) {
      //     profileImageUrl.value = url;
      //   }
      // }
    } catch (e) {
      print('Failed to load profile image: $e');
    }
  }

  Widget getProfileImageWidget() {
    if (profileImage.value != null) {
      // Show local file while uploading
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(profileImage.value!),
      );
    } else if (profileImageUrl.value.isNotEmpty) {
      // Show cached network image
      return CircleAvatar(
        radius: 50,
        backgroundImage: CachedNetworkImageProvider(profileImageUrl.value),
      );
    } else {
      // Show default avatar
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person,
          size: 50,
          color: Colors.grey[400],
        ),
      );
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        await _uploadProfileImage();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (profileImage.value == null) return;

    try {
      isUploadingImage.value = true;
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // final imageUrl = await _storageService.uploadProfileImage(
        //   user.uid,
        //   profileImage.value!,
        // );
        //
        // if (imageUrl.isNotEmpty) {
        //   profileImageUrl.value = imageUrl;
        //   Get.snackbar('Success', 'Profile image updated successfully');
        // }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: ${e.toString()}');
    } finally {
      isUploadingImage.value = false;
    }
  }

  void selectExperienceLevel() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Select Experience Level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...experienceLevels.map((level) => ListTile(
                  title: Text(level),
                  onTap: () {
                    experience.value = level;
                    experienceController.text = level;
                    Get.back();
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void selectCertification() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Select Certification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...certifications.map((cert) => ListTile(
                  title: Text(cert),
                  onTap: () {
                    certification.value = cert;
                    certificationController.text = cert;
                    Get.back();
                  },
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void addLanguage() {
    Get.dialog(
      AlertDialog(
        title: const Text('Add Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableLanguages
              .map((language) => ListTile(
                    title: Text(language),
                    onTap: () {
                      String currentLanguages = languagesController.text;
                      if (!currentLanguages.contains(language)) {
                        if (currentLanguages.isNotEmpty) {
                          languagesController.text =
                              '$currentLanguages, $language';
                        } else {
                          languagesController.text = language;
                        }
                      }
                      Get.back();
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> saveChangesAsync() async {
    try {
      isSaving.value = true;

      final prefs = await SharedPreferences.getInstance();

      // Save to SharedPreferences
      await prefs.setString('userName', fullNameController.text);
      if (phoneController.text.isNotEmpty) {
        await prefs.setString('userPhone', phoneController.text);
      }

      // Update display values
      displayName.value = fullNameController.text;
      displayPhone.value = phoneController.text;

      // Save to Firestore
      await _saveToFirestore();

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save changes: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _saveToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc =
          FirebaseFirestore.instance.collection('interpreters').doc(user.uid);

      final userData = {
        'name': fullNameController.text,
        'phone': phoneController.text,
        'experience': experience.value,
        'certification': certification.value,
        'languages': languagesController.text,
        'profileImageUrl': profileImageUrl.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await userDoc.set(userData, SetOptions(merge: true));

      // Save document ID for future reference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('interpreter_doc_id', user.uid);
      userDocId.value = user.uid;
    } catch (e) {
      throw Exception('Failed to save to Firestore: $e');
    }
  }

  Future<void> deleteAccount() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performAccountDeletion();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('interpreters')
          .doc(user.uid)
          .delete();

      // Delete profile image from Storage
      await _storageService.deleteProfileImage(user.uid);

      // Delete Firebase Auth account
      await user.delete();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Get.snackbar(
        'Account Deleted',
        'Your account has been successfully deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to login/signup screen
      Get.offAllNamed('/initial');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    experienceController.dispose();
    languagesController.dispose();
    certificationController.dispose();
    super.onClose();
  }
}
