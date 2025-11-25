import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import 'package:sign_language_app/shared/components/settings_bottom_sheets.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../../shared/mixins/settings.mixin.dart';
import '../../../presentation/shared/controllers/interpreter_profile.controller.dart';

class InterpreterSettingsController extends GetxController with SettingsMixin {
  final emailController = TextEditingController();
  final experienceController = TextEditingController();
  final certificationController = TextEditingController();
  final subjectController = TextEditingController();

  final RxString experience = 'Senior (5+ years)'.obs;
  final RxString certification = 'Ghana Sign Language Certified'.obs;
  final RxString displayEmail = ''.obs;
  final RxString displaySubject = ''.obs;

  final List<String> experienceLevels = [
    'Junior (1-2 years)',
    'Mid-level (3-4 years)',
    'Senior (5+ years)',
    'Expert (10+ years)',
  ];

  final List<String> certifications = [
    'Ghana Sign Language Certified',
    'International Sign Language Certified',
    'ASL Certified',
    'BSL Certified',
  ];

  @override
  void onInit() {
    super.onInit();
    initializeFirebaseStorage();
    _loadUserData();
    _loadProfileImageFromStorage();
  }

  Future<void> _loadUserData() async {
    try {
      final profileController = Get.find<InterpreterProfileController>();
      final user = profileController.profile.value;

      if (user != null) {
        await _loadFromFirestoreProfile(user);
      } else {
        await _loadFromSharedPreferences();
      }
    } catch (e) {
      await _loadFromSharedPreferences();
      print('Error loading user data from Firestore: $e');
    }
  }

  Future<void> _loadFromFirestoreProfile(dynamic user) async {
    _loadBasicInfo(user);
    _loadProfessionalInfo(user);
    _loadLanguagesInfo(user);
    _loadProfileImageUrl(user);
    userDocId.value = user.interpreterID;
  }

  void _loadBasicInfo(dynamic user) {
    fullNameController.text = user.displayName;
    displayName.value = user.displayName;
    emailController.text = user.email;
    displayEmail.value = user.email;
  }

  void _loadProfessionalInfo(dynamic user) {
    if (user.specializations.isNotEmpty) {
      experienceController.text = user.specializations.first;
      experience.value = user.specializations.first;
    } else {
      experienceController.text = 'Senior (5+ years)';
      experience.value = 'Senior (5+ years)';
    }

    certificationController.text = 'Ghana Sign Language Certified';
    certification.value = 'Ghana Sign Language Certified';

    // Load subject
    if (user.subject != null && user.subject!.isNotEmpty) {
      subjectController.text = user.subject!;
      displaySubject.value = user.subject!;
    }
  }

  void _loadLanguagesInfo(dynamic user) {
    if (user.languages.isNotEmpty) {
      languagesController.text = user.languages.join(', ');
    } else {
      languagesController.text = 'Ghanaian Sign Language';
    }
  }

  void _loadProfileImageUrl(dynamic user) {
    final remoteUrl = user.profilePictureUrl?.isNotEmpty == true
        ? user.profilePictureUrl
        : user.avatarUrl;

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      profileImageUrl.value = remoteUrl;
    }
  }

  Future<void> _loadFromSharedPreferences() async {
    try {
      await loadFromSharedPreferences(
        'interpreter_name',
        'userPhone',
        emailKey: 'interpreter_email',
        docIdKey: 'interpreter_id',
      );

      final prefs = await SharedPreferences.getInstance();
      _loadEmailFromPrefs(prefs);
      _setDefaultProfessionalValues();

      // Load subject from SharedPreferences
      final savedSubject = prefs.getString('interpreter_subject');
      if (savedSubject != null && savedSubject.isNotEmpty) {
        subjectController.text = savedSubject;
        displaySubject.value = savedSubject;
      }

      userDocId.value = prefs.getString('interpreter_id') ?? '';
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to load user data: ${e.toString()}',
      );
    }
  }

  void _loadEmailFromPrefs(SharedPreferences prefs) {
    final userEmail = prefs.getString('interpreter_email') ??
        prefs.getString('userEmail') ??
        '';
    emailController.text = userEmail;
    displayEmail.value = userEmail;
  }

  void _setDefaultProfessionalValues() {
    experienceController.text = 'Senior (5+ years)';
    experience.value = 'Senior (5+ years)';
    certificationController.text = 'Ghana Sign Language Certified';
    certification.value = 'Ghana Sign Language Certified';
    languagesController.text = 'Ghanaian Sign Language';
    subjectController.text = '';
    displaySubject.value = '';
  }

  Future<void> _loadProfileImageFromStorage() async {
    try {
      final profileController = Get.find<InterpreterProfileController>();

      // Set initial value if available
      final user = profileController.profile.value;
      if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
        profileImageUrl.value = user.avatarUrl!;
      }

      // Add reactive listener to keep profileImageUrl in sync
      ever(profileController.profile, (user) {
        if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
          profileImageUrl.value = user.avatarUrl!;
        }
      });
    } catch (e) {
      print('Failed to load profile image: $e');
    }
  }

  @override
  Future<void> pickProfileImage() async {
    await super.pickProfileImage();

    // Update localImagePath in profile controller for immediate UI update
    if (profileImage.value != null) {
      final profileController = Get.find<InterpreterProfileController>();
      profileController.localImagePath.value = profileImage.value!.path;
    }
  }

  @override
  Future<String> resolveUserIdentifier() async {
    try {
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

  @override
  Future<void> uploadProfileImageToFirebaseStorage(File imageFile) async {
    try {
      isUploadingImage.value = true;
      final interpreterId = await resolveUserIdentifier();
      final downloadUrl = await firebaseStorage.uploadProfileImage(
        imageFile: imageFile,
        userId: interpreterId,
        folder: 'profiles/interpreters',
      );

      if (downloadUrl != null) {
        await _handleImageUploadSuccess(downloadUrl);
      } else {
        _handleImageUploadFailure();
      }
    } catch (e) {
      _handleImageUploadError(e);
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _handleImageUploadSuccess(String downloadUrl) async {
    profileImageUrl.value = downloadUrl;

    final profileController = Get.find<InterpreterProfileController>();
    await profileController.updateProfile({
      'avatarUrl': downloadUrl,
    });

    if (profileController.profile.value != null) {
      profileController.profile.value =
          profileController.profile.value!.copyWith(
        avatarUrl: downloadUrl,
      );
    }

    profileController.localImagePath.value = '';
    await profileController.runProfileRefresh();

    profileImage.value = null;
    AppSnackbar.success(
      title: 'Success',
      message: 'Profile image updated successfully',
    );
  }

  void _handleImageUploadFailure() {
    AppSnackbar.warning(
      title: 'Upload Failed',
      message: 'Failed to upload image to cloud. Please try again.',
    );
  }

  void _handleImageUploadError(dynamic e) {
    AppSnackbar.error(
      title: 'Error',
      message: 'Failed to upload image: ${e.toString()}',
    );
  }

  void selectExperienceLevel() {
    SettingsBottomSheets.showExperienceLevelPicker(
      levels: experienceLevels,
      currentLevel: experience.value,
      onSelect: (level) {
        experience.value = level;
        experienceController.text = level;
      },
    );
  }

  void selectCertification() {
    SettingsBottomSheets.showCertificationPicker(
      certifications: certifications,
      currentCertification: certification.value,
      onSelect: (cert) {
        certification.value = cert;
        certificationController.text = cert;
      },
    );
  }

  Future<void> saveChangesAsync() async {
    try {
      isSaving.value = true;
      final updateData = _buildProfileUpdateData();

      // Save locally first (this always works)
      await _persistDataLocally();

      // Try to update Firestore with timeout
      await _updateFirestoreProfile(updateData).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Network request timed out. Please check your internet connection.',
          );
        },
      );

      AppSnackbar.success(
        title: 'Success',
        message: 'Profile updated successfully',
      );
    } on TimeoutException catch (e) {
      AppSnackbar.warning(
        title: 'Saved Locally',
        message:
            'Changes saved locally but could not sync to server. ${e.message}',
      );
    } catch (e) {
      // Check if it's a network error
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('network') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('resolve host') ||
          errorMessage.contains('unavailable')) {
        AppSnackbar.warning(
          title: 'Network Error',
          message:
              'Changes saved locally. Please check your internet connection to sync with server.',
        );
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Failed to save changes: ${e.toString()}',
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _buildProfileUpdateData() {
    final nameParts = parseFullName(fullNameController.text);
    return {
      'firstName': nameParts['firstName']!,
      'lastName': nameParts['lastName']!,
      'email': emailController.text,
      'languages': parseLanguages(),
      'specializations': [experience.value],
      'bio': null,
      'profilePictureUrl':
          profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
      'subject': subjectController.text.trim().isNotEmpty
          ? subjectController.text.trim()
          : null,
    };
  }

  Future<void> _persistDataLocally() async {
    await saveToSharedPreferences(
      nameKey: 'interpreter_name',
      phoneKey: 'userPhone',
      docIdKey: 'interpreter_id',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('interpreter_email', emailController.text);
    displayEmail.value = emailController.text;

    // Save subject to local storage
    if (subjectController.text.trim().isNotEmpty) {
      await prefs.setString(
          'interpreter_subject', subjectController.text.trim());
      displaySubject.value = subjectController.text.trim();
    }
  }

  Future<void> _updateFirestoreProfile(Map<String, dynamic> updateData) async {
    final profileController = Get.find<InterpreterProfileController>();
    await profileController.updateProfile(updateData);
  }

  Future<void> deleteAccount() async {
    showDeleteAccountDialog(() async {
      await performAccountDeletion('interpreters', Routes.INTERPRETER_SIGNIN);
    });
  }

  Future<void> logout() async {
    try {
      Get.deleteAll(force: true);
      await FirebaseAuth.instance.signOut();

      // Clear interpreter-specific cached data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('interpreter_name');
      await prefs.remove('interpreter_email');
      await prefs.remove('interpreter_id');
      await prefs.remove('current_profile_image_url');

      Get.offAllNamed(Routes.INTERPRETER_SIGNIN);
      AppSnackbar.success(
        title: 'Logged Out',
        message: 'You have been logged out successfully',
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to logout: ${e.toString()}',
      );
    }
  }

  @override
  void onClose() {
    disposeControllers();
    emailController.dispose();
    experienceController.dispose();
    certificationController.dispose();
    subjectController.dispose();
    super.onClose();
  }
}
