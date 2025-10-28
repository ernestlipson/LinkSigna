import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import 'package:sign_language_app/shared/components/app_bottom_sheet.component.dart';
import 'package:sign_language_app/shared/components/app_dialog.component.dart';

import '../../../../infrastructure/dal/services/cloudinary.service.dart';
import '../../../../config/cloudinary.config.dart';
import '../../../../infrastructure/navigation/routes.dart';
import '../../../presentation/shared/controllers/interpreter_profile.controller.dart';

class InterpreterSettingsController extends GetxController {
  // Tab selection
  final RxInt selectedTab = 0.obs;

  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
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
  final RxString displayEmail = ''.obs;
  final RxString displayPhone = ''.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isSaving = false.obs;
  final RxString userDocId = ''.obs;
  final ImagePicker _picker = ImagePicker();

  // Cloudinary Service
  late CloudinaryService _cloudinary;

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
    _cloudinary = Get.put(CloudinaryService());
    _loadUserData();
    _loadProfileImageFromStorage();
  }

  Future<void> _loadUserData() async {
    try {
      // Get the profile controller to access Firestore data
      final profileController = Get.find<InterpreterProfileController>();
      final user = profileController.profile.value;

      if (user != null) {
        // Load data from Firestore user profile
        fullNameController.text = user.displayName;
        displayName.value = user.displayName;

        emailController.text = user.email;
        displayEmail.value = user.email;

        phoneController.text = user.phone ?? '';
        displayPhone.value = user.phone ?? '';

        // Set professional information with defaults
        if (user.specializations.isNotEmpty) {
          experienceController.text = user.specializations.first;
          experience.value = user.specializations.first;
        } else {
          experienceController.text = 'Senior (5+ years)';
          experience.value = 'Senior (5+ years)';
        }

        certificationController.text = 'Ghana Sign Language Certified';
        certification.value = 'Ghana Sign Language Certified';

        // Set languages
        if (user.languages.isNotEmpty) {
          languagesController.text = user.languages.join(', ');
        } else {
          languagesController.text = 'Ghanaian Sign Language';
        }

        // Set profile image URL if available
        if (user.profilePictureUrl != null &&
            user.profilePictureUrl!.isNotEmpty) {
          profileImageUrl.value = user.profilePictureUrl!;
        }

        // Store interpreter ID for future updates
        userDocId.value = user.interpreterID;
      } else {
        // Fallback to SharedPreferences if Firestore data not available
        await _loadFromSharedPreferences();
      }
    } catch (e) {
      // Fallback to SharedPreferences if there's an error
      await _loadFromSharedPreferences();
      print('Error loading user data from Firestore: $e');
    }
  }

  Future<void> _loadFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user name from SharedPreferences (saved during signup)
      final userName = prefs.getString('interpreter_name') ??
          prefs.getString('userName') ??
          '';
      fullNameController.text = userName;
      displayName.value = userName;

      // Load email from SharedPreferences if available
      final userEmail = prefs.getString('interpreter_email') ??
          prefs.getString('userEmail') ??
          '';
      emailController.text = userEmail;
      displayEmail.value = userEmail;

      // Load phone number from SharedPreferences if available
      final userPhone = prefs.getString('userPhone') ?? '';
      if (userPhone.isNotEmpty) {
        phoneController.text = userPhone;
        displayPhone.value = userPhone;
      }

      // Set default values if no user data is found
      if (fullNameController.text.isEmpty) {
        fullNameController.text = '';
        displayName.value = '';
      }

      // Set default values for interpreter-specific fields
      experienceController.text = 'Senior (5+ years)';
      experience.value = 'Senior (5+ years)';
      certificationController.text = 'Ghana Sign Language Certified';
      certification.value = 'Ghana Sign Language Certified';
      languagesController.text = 'Ghanaian Sign Language';

      // Load existing stored Firestore doc id if any
      userDocId.value = prefs.getString('interpreter_id') ?? '';
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to load user data: ${e.toString()}',
      );
    }
  }

  Future<void> _loadProfileImageFromStorage() async {
    try {
      // Load profile image from InterpreterProfileController first
      final profileController = Get.find<InterpreterProfileController>();
      final user = profileController.profile.value;

      if (user?.profilePictureUrl != null &&
          user!.profilePictureUrl!.isNotEmpty) {
        profileImageUrl.value = user.profilePictureUrl!;
      }
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
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  Future<String> _resolveInterpreterIdentifier() async {
    try {
      // Prefer controller id, fallback to SharedPreferences, then Firebase Auth UID
      final profileController = Get.find<InterpreterProfileController>();
      final idFromCtrl = profileController.interpreterId.value;
      if (idFromCtrl.isNotEmpty) return idFromCtrl;

      final prefs = await SharedPreferences.getInstance();
      final cachedId = prefs.getString('interpreter_id');
      if (cachedId != null && cachedId.isNotEmpty) return cachedId;

      final authUid = FirebaseAuth.instance.currentUser?.uid;
      if (authUid != null && authUid.isNotEmpty) return authUid;

      return 'interpreter';
    } catch (_) {
      return 'interpreter';
    }
  }

  Future<void> _uploadProfileImage() async {
    if (profileImage.value == null) return;

    try {
      isUploadingImage.value = true;

      final interpreterId = await _resolveInterpreterIdentifier();
      final file = profileImage.value!;

      final downloadUrl = await _cloudinary.uploadProfileImage(
        imageFile: file,
        userId: interpreterId,
        folder: CloudinaryConfig.folderInterpreters,
      );

      if (downloadUrl != null) {
        profileImageUrl.value = downloadUrl;

        // Update Firestore via profile controller
        final profileController = Get.find<InterpreterProfileController>();
        await profileController.updateProfile({
          'profilePictureUrl': downloadUrl,
        });

        // Clear local file after success
        profileImage.value = null;

        AppSnackbar.success(
          title: 'Success',
          message: 'Profile image updated successfully',
        );
      } else {
        AppSnackbar.warning(
          title: 'Upload Failed',
          message: 'Failed to upload image to cloud. Please try again.',
        );
      }
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to upload image: ${e.toString()}',
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  void selectExperienceLevel() {
    AppBottomSheet.showList(
      title: 'Select Experience Level',
      items: experienceLevels.map((level) {
        final isSelected = experience.value == level;
        return ListTile(
          title: Text(level),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            experience.value = level;
            experienceController.text = level;
            Get.back();
          },
        );
      }).toList(),
    );
  }

  void selectCertification() {
    AppBottomSheet.showList(
      title: 'Select Certification',
      items: certifications.map((cert) {
        final isSelected = certification.value == cert;
        return ListTile(
          title: Text(cert),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            certification.value = cert;
            certificationController.text = cert;
            Get.back();
          },
        );
      }).toList(),
    );
  }

  void addLanguage() {
    AppBottomSheet.showList(
      title: 'Add Language',
      maxHeight: 260,
      items: availableLanguages.map((language) {
        final isSelected = languagesController.text.contains(language);
        return ListTile(
          title: Text(language),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            final currentLanguages = languagesController.text;
            if (!currentLanguages.contains(language)) {
              languagesController.text = currentLanguages.isNotEmpty
                  ? '$currentLanguages, $language'
                  : language;
            }
            Get.back();
          },
        );
      }).toList(),
    );
  }

  Future<void> saveChangesAsync() async {
    try {
      isSaving.value = true;

      // Parse the name into first and last name
      final nameParts = fullNameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      // Parse languages
      final languagesList = languagesController.text
          .split(',')
          .map((lang) => lang.trim())
          .where((lang) => lang.isNotEmpty)
          .toList();

      // Parse specializations (using experience as specialization for now)
      final specializationsList = [experience.value];

      final prefs = await SharedPreferences.getInstance();

      // Save to SharedPreferences
      await prefs.setString('interpreter_name', fullNameController.text);
      await prefs.setString('interpreter_email', emailController.text);
      if (phoneController.text.isNotEmpty) {
        await prefs.setString('userPhone', phoneController.text);
      }

      // Update display values
      displayName.value = fullNameController.text;
      displayEmail.value = emailController.text;
      displayPhone.value = phoneController.text;

      // Get the profile controller and update Firestore
      final profileController = Get.find<InterpreterProfileController>();

      // Prepare update data
      final updateData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': emailController.text,
        'phone': phoneController.text.isNotEmpty ? phoneController.text : null,
        'languages': languagesList,
        'specializations': specializationsList,
        'bio': null, // Can be added later when bio field is implemented
        'profilePictureUrl':
            profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
      };

      // Update via profile controller
      await profileController.updateProfile(updateData);

      AppSnackbar.success(
        title: 'Success',
        message: 'Profile updated successfully',
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to save changes: ${e.toString()}',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAccount() async {
    AppDialog.showConfirmation(
      title: 'Delete Account',
      message:
          'Are you sure you want to delete your account? This action cannot be undone.',
      cancelLabel: 'Cancel',
      confirmLabel: 'Delete',
      confirmColor: Colors.red,
      barrierDismissible: false,
      onConfirm: () async {
        await _performAccountDeletion();
      },
    );
  }

  // Logout
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.INTERPRETER_SIGNIN);
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to logout: ${e.toString()}',
      );
    }
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

      // Note: Cloudinary asset deletion requires server-side API. Skipping client-side delete.

      // Delete Firebase Auth account
      await user.delete();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      AppSnackbar.success(
        title: 'Account Deleted',
        message: 'Your account has been successfully deleted',
      );

      // Navigate to login/signup screen
      Get.offAllNamed(Routes.initialRoute);
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to delete account: ${e.toString()}',
      );
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    experienceController.dispose();
    languagesController.dispose();
    certificationController.dispose();
    super.onClose();
  }
}
