import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import 'package:sign_language_app/shared/components/settings_bottom_sheets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/cloudinary.config.dart';
import '../../shared/controllers/user.controller.dart';
import '../../shared/controllers/student_user.controller.dart';
import '../../../../shared/mixins/settings.mixin.dart';

class SettingsController extends GetxController with SettingsMixin {
  final universityController = TextEditingController();
  final RxString universityLevel = 'TTU - Level 300'.obs;
  final List<int> availableLevels = [100, 200, 300, 400, 500];

  @override
  void onInit() {
    super.onInit();
    initializeCloudinaryService();
    _loadUserData();
    _loadExistingProfileImage();
  }

  void _loadExistingProfileImage() {
    if (!Get.isRegistered<UserController>()) return;

    final userController = Get.find<UserController>();
    if (userController.localImagePath.value.isEmpty) return;

    final file = File(userController.localImagePath.value);
    if (file.existsSync()) {
      profileImage.value = file;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _loadBasicUserInfo(prefs);
      _setDefaultValues();
      await _loadUserDocId(prefs);
      await _loadProfileImageUrl();
      await _discoverFirestoreDoc(prefs);
    } catch (e) {
      _setDefaultValues();
    }
  }

  Future<void> _loadBasicUserInfo(SharedPreferences prefs) async {
    final userName = prefs.getString('userName') ?? '';
    fullNameController.text = userName;
    displayName.value = userName;

    if (Get.isRegistered<UserController>()) {
      final userController = Get.find<UserController>();
      final user = userController.user.value;

      if (user?.name?.isNotEmpty == true) {
        fullNameController.text = user!.name!;
        displayName.value = user.name!;
      }
      if (user?.phone?.isNotEmpty == true) {
        phoneController.text = user!.phone!;
        displayPhone.value = user.phone!;
      }
    }

    final userPhone = prefs.getString('userPhone') ?? '';
    if (userPhone.isNotEmpty && phoneController.text.isEmpty) {
      phoneController.text = userPhone;
      displayPhone.value = userPhone;
    }
  }

  void _setDefaultValues() {
    if (fullNameController.text.isEmpty) {
      fullNameController.text = 'User';
      displayName.value = 'User';
    }
    if (phoneController.text.isEmpty) {
      phoneController.text = '';
      displayPhone.value = '';
    }
    universityController.text = 'TTU- Level 300';
    universityLevel.value = 'TTU - Level 300';
    languagesController.text = 'Ghanaian Sign Language';
  }

  Future<void> _loadUserDocId(SharedPreferences prefs) async {
    userDocId.value = prefs.getString('user_doc_id') ?? '';
  }

  Future<void> _discoverFirestoreDoc(SharedPreferences prefs) async {
    if (userDocId.value.isNotEmpty || phoneController.text.trim().isEmpty) {
      return;
    }

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

  @override
  Future<String> resolveUserIdentifier() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDocId = prefs.getString('student_user_doc_id');
      if (cachedDocId != null && cachedDocId.isNotEmpty) {
        return cachedDocId;
      }
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      if (authUid != null && authUid.isNotEmpty) {
        return authUid;
      }
      final legacy = prefs.getString('userName') ?? 'User';
      return legacy;
    } catch (_) {
      return FirebaseAuth.instance.currentUser?.uid ?? 'User';
    }
  }

  Future<void> _loadProfileImageUrl() async {
    try {
      final userId = await resolveUserIdentifier();
      await loadProfileImageUrl(userId, CloudinaryConfig.folderStudents);
      _updateUserControllerPhoto();
    } catch (e) {
      Get.log('Error loading profile image URL: $e');
    }
  }

  void _updateUserControllerPhoto() {
    if (profileImageUrl.value.isEmpty || !Get.isRegistered<UserController>()) {
      return;
    }

    final userController = Get.find<UserController>();
    userController.setUser(photo: profileImageUrl.value);
  }

  @override
  Future<void> pickProfileImage() async {
    await super.pickProfileImage();
    _updateLocalProfileImage();
  }

  void _updateLocalProfileImage() {
    if (profileImage.value == null || !Get.isRegistered<UserController>()) {
      return;
    }

    final userController = Get.find<UserController>();
    userController.setLocalProfileImage(profileImage.value!.path);
  }

  @override
  Future<void> uploadProfileImageToCloudinary(File imageFile) async {
    try {
      isUploadingImage.value = true;
      final userId = await resolveUserIdentifier();
      final downloadUrl = await cloudinary.uploadProfileImage(
        imageFile: imageFile,
        userId: userId,
        folder: CloudinaryConfig.folderStudents,
      );

      if (downloadUrl != null) {
        await _handleUploadSuccess(downloadUrl);
      } else {
        _handleUploadFailure();
      }
    } catch (e) {
      _handleUploadError(e);
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _handleUploadSuccess(String downloadUrl) async {
    profileImageUrl.value = downloadUrl;

    if (Get.isRegistered<UserController>()) {
      final userController = Get.find<UserController>();
      userController.setUser(photo: downloadUrl);
    }

    if (Get.isRegistered<StudentUserController>()) {
      final stuCtrl = Get.find<StudentUserController>();
      await stuCtrl.updateProfile({'avatarUrl': downloadUrl});
    }

    profileImage.value = null;
    AppSnackbar.success(
      title: 'Success',
      message: 'Profile image updated successfully!',
    );
    Get.log('Cloudinary upload success: $downloadUrl');
  }

  void _handleUploadFailure() {
    AppSnackbar.warning(
      title: 'Upload Failed',
      message: 'Failed to upload image to cloud. Please try again.',
    );
  }

  void _handleUploadError(dynamic e) {
    Get.log('Error uploading profile image: $e');
    AppSnackbar.error(
      title: 'Error',
      message: 'Failed to upload profile image: ${e.toString()}',
    );
    profileImage.value = null;
  }

  void editProfile() {
    AppSnackbar.info(
      title: 'Edit Profile',
      message: 'Edit profile functionality will be implemented',
    );
  }

  void selectUniversityLevel() {
    SettingsBottomSheets.showUniversityLevelPicker(
      levels: availableLevels,
      currentLevel: universityLevel.value,
      onSelect: _selectUniversityLevel,
    );
  }

  void _selectUniversityLevel(int level) {
    final universityName = _extractUniversityName();
    final newLevel = '$universityName - Level $level';

    universityLevel.value = newLevel;
    universityController.text = newLevel;

    AppSnackbar.success(
      title: 'Level Updated',
      message: 'University level updated to Level $level',
    );
  }

  String _extractUniversityName() {
    final currentText = universityLevel.value;
    if (currentText.contains('-')) {
      return currentText.split('-')[0].trim();
    }
    return 'TTU';
  }

  void saveChanges() {
    saveChangesAsync();
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
      'languages': parseLanguages(),
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

      final updateData = _buildUpdateData();
      await _updateUserProfile(updateData);
      await _persistChangesLocally();

      AppSnackbar.success(
        title: 'Saved',
        message: 'Profile updated successfully',
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Update Failed',
        message: 'Could not save changes: $e',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _buildUpdateData() {
    final nameParts = parseFullName(fullNameController.text);
    return {
      'firstname': nameParts['firstName']!,
      'lastname': nameParts['lastName']!,
      'phone': phoneController.text.trim(),
      'language': languagesController.text.trim(),
      'university_level': universityLevel.value,
      if (profileImageUrl.value.isNotEmpty) 'avatarUrl': profileImageUrl.value,
    };
  }

  Future<void> _updateUserProfile(Map<String, dynamic> updateData) async {
    if (Get.isRegistered<StudentUserController>()) {
      final stuCtrl = Get.find<StudentUserController>();
      await stuCtrl.updateProfile(updateData);
    } else if (userDocId.value.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocId.value)
          .set(updateData, SetOptions(merge: true));
    }
  }

  Future<void> _persistChangesLocally() async {
    await saveToSharedPreferences(
      nameKey: 'userName',
      phoneKey: 'userPhone',
      docIdKey: 'user_doc_id',
    );

    if (Get.isRegistered<UserController>()) {
      Get.find<UserController>().setUser(
        name: displayName.value,
        phone: displayPhone.value,
        photo: profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
      );
    }
  }

  void changePassword() {
    AppSnackbar.info(
      title: 'Change Password',
      message: 'Change password functionality will be implemented',
    );
  }

  void deleteAccount() {
    showDeleteAccountDialog(() {
      AppSnackbar.warning(
        title: 'Account Deleted',
        message: 'Your account has been deleted successfully',
      );
    });
  }

  @override
  void onClose() {
    disposeControllers();
    universityController.dispose();
    super.onClose();
  }
}
