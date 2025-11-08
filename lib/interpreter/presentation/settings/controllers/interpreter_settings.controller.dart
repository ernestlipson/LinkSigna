import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import 'package:sign_language_app/shared/components/settings_bottom_sheets.dart';

import '../../../../infrastructure/navigation/routes.dart';
import '../../../presentation/shared/controllers/interpreter_profile.controller.dart';
import '../../../../shared/mixins/settings.mixin.dart';

class InterpreterSettingsController extends GetxController with SettingsMixin {
  final emailController = TextEditingController();
  final experienceController = TextEditingController();
  final certificationController = TextEditingController();

  final RxString experience = 'Senior (5+ years)'.obs;
  final RxString certification = 'Ghana Sign Language Certified'.obs;
  final RxString displayEmail = ''.obs;

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
    initializeCloudinaryService();
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

    phoneController.text = user.phone ?? '';
    displayPhone.value = user.phone ?? '';
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
  }

  void _loadLanguagesInfo(dynamic user) {
    if (user.languages.isNotEmpty) {
      languagesController.text = user.languages.join(', ');
    } else {
      languagesController.text = 'Ghanaian Sign Language';
    }
  }

  void _loadProfileImageUrl(dynamic user) {
    if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
      profileImageUrl.value = user.profilePictureUrl!;
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
  }

  Future<void> _loadProfileImageFromStorage() async {
    try {
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
  Future<void> uploadProfileImageToCloudinary(File imageFile) async {
    try {
      isUploadingImage.value = true;
      final interpreterId = await resolveUserIdentifier();
      final downloadUrl = await cloudinary.uploadProfileImage(
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
      'profilePictureUrl': downloadUrl,
    });

    // Update the profile value immediately for reactive UI using copyWith
    if (profileController.profile.value != null) {
      profileController.profile.value =
          profileController.profile.value!.copyWith(
        profilePictureUrl: downloadUrl,
      );
    }

    // Clear local image path since we now have the network URL
    profileController.localImagePath.value = '';

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
      await _persistDataLocally();
      await _updateFirestoreProfile(updateData);

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

  Map<String, dynamic> _buildProfileUpdateData() {
    final nameParts = parseFullName(fullNameController.text);
    return {
      'firstName': nameParts['firstName']!,
      'lastName': nameParts['lastName']!,
      'email': emailController.text,
      'phone': phoneController.text.isNotEmpty ? phoneController.text : null,
      'languages': parseLanguages(),
      'specializations': [experience.value],
      'bio': null,
      'profilePictureUrl':
          profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
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
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.INTERPRETER_SIGNIN);
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
    super.onClose();
  }
}
