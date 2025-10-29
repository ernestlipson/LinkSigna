import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import 'package:sign_language_app/shared/components/app_bottom_sheet.component.dart';
import 'package:sign_language_app/shared/components/app_dialog.component.dart';
import 'package:sign_language_app/shared/components/profile_image.widget.dart';

import '../../infrastructure/dal/services/cloudinary.service.dart';

mixin SettingsMixin on GetxController {
  final RxInt selectedTab = 0.obs;

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final languagesController = TextEditingController();

  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;
  final RxString displayName = ''.obs;
  final RxString displayPhone = ''.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isSaving = false.obs;
  final RxString userDocId = ''.obs;

  final ImagePicker picker = ImagePicker();
  late CloudinaryService cloudinary;

  final List<String> availableLanguages = [
    'Ghanaian Sign Language',
    'American Sign Language (ASL)',
    'British Sign Language (BSL)',
    'International Sign',
  ];

  void initializeCloudinaryService() {
    cloudinary = Get.put(CloudinaryService());
  }

  Widget getProfileImageWidget() {
    return ProfileImageWidget(
      imageUrl: profileImageUrl.value.isNotEmpty ? profileImageUrl.value : null,
      imageFile: profileImage.value,
      radius: 50,
      backgroundColor: Colors.pink[100],
    );
  }

  bool get hasProfileImage {
    return profileImageUrl.value.isNotEmpty || profileImage.value != null;
  }

  Future<void> pickProfileImage() async {
    try {
      final image = await _selectImageFromGallery();
      if (image != null) {
        await _handleImageSelection(image);
      }
    } catch (e) {
      _handleImagePickError(e);
    }
  }

  Future<XFile?> _selectImageFromGallery() async {
    return await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
  }

  Future<void> _handleImageSelection(XFile image) async {
    profileImage.value = File(image.path);
    _showImageSelectedNotification();
    await uploadProfileImageToCloudinary(File(image.path));
  }

  void _showImageSelectedNotification() {
    AppSnackbar.info(
      title: 'Image Selected',
      message: 'Profile image selected successfully! Uploading to cloud...',
    );
  }

  void _handleImagePickError(dynamic e) {
    AppSnackbar.error(
      title: 'Error',
      message: 'Failed to pick image: ${e.toString()}',
    );
  }

  Future<void> uploadProfileImageToCloudinary(File imageFile) async {
    throw UnimplementedError('Override this method in child class');
  }

  Future<String> resolveUserIdentifier() async {
    throw UnimplementedError('Override this method in child class');
  }

  Future<void> loadProfileImageUrl(String userId, String folder) async {
    try {
      final imageUrl = await cloudinary.getProfileImageUrl(userId);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        profileImageUrl.value = imageUrl;
        Get.log('Profile image URL loaded: $imageUrl');
      }
    } catch (e) {
      Get.log('Error loading profile image URL: $e');
    }
  }

  void addLanguage() {
    AppBottomSheet.showList(
      title: 'Select Language',
      maxHeight: 260,
      items: _buildLanguageItems(),
    );
  }

  List<Widget> _buildLanguageItems() {
    return availableLanguages.map((language) {
      final isSelected = _isLanguageSelected(language);
      return _buildLanguageItem(language, isSelected);
    }).toList();
  }

  bool _isLanguageSelected(String language) {
    return languagesController.text.contains(language);
  }

  Widget _buildLanguageItem(String language, bool isSelected) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(
        language,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () => _handleLanguageSelection(language),
    );
  }

  void _handleLanguageSelection(String language) {
    selectLanguage(language);
    Get.back();
  }

  void selectLanguage(String language) {
    final currentLanguages = languagesController.text;

    if (currentLanguages.isEmpty) {
      _setLanguage(language);
    } else if (currentLanguages.contains(language)) {
      _removeLanguage(language, currentLanguages);
    } else {
      _addLanguage(language, currentLanguages);
    }

    _showLanguageUpdateNotification();
  }

  void _setLanguage(String language) {
    languagesController.text = language;
  }

  void _removeLanguage(String language, String currentLanguages) {
    final languages = currentLanguages.split(', ');
    languages.remove(language);
    languagesController.text = languages.join(', ');
  }

  void _addLanguage(String language, String currentLanguages) {
    languagesController.text = '$currentLanguages, $language';
  }

  void _showLanguageUpdateNotification() {
    AppSnackbar.success(
      title: 'Language Updated',
      message: 'Language selection updated successfully',
    );
  }

  List<String> parseLanguages() {
    final raw = languagesController.text.trim();
    if (raw.isEmpty) return [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Map<String, String> parseFullName(String fullName) {
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    return {'firstName': firstName, 'lastName': lastName};
  }

  Future<void> showDeleteAccountDialog(VoidCallback onConfirm) async {
    AppDialog.showConfirmation(
      title: 'Delete Account',
      message:
          'Are you sure you want to delete your account? This action cannot be undone.',
      cancelLabel: 'Cancel',
      confirmLabel: 'Delete',
      confirmColor: Colors.red,
      barrierDismissible: false,
      onConfirm: onConfirm,
    );
  }

  Future<void> performAccountDeletion(
      String collectionName, String navigateToRoute) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _deleteUserData(collectionName, user.uid);
      await _deleteAuthAccount(user);
      await _clearLocalData();
      _showAccountDeletedNotification();
      _navigateToSignIn(navigateToRoute);
    } catch (e) {
      _handleAccountDeletionError(e);
    }
  }

  Future<void> _deleteUserData(String collectionName, String userId) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(userId)
        .delete();
  }

  Future<void> _deleteAuthAccount(User user) async {
    await user.delete();
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void _showAccountDeletedNotification() {
    AppSnackbar.success(
      title: 'Account Deleted',
      message: 'Your account has been successfully deleted',
    );
  }

  void _navigateToSignIn(String navigateToRoute) {
    Get.offAllNamed(navigateToRoute);
  }

  void _handleAccountDeletionError(dynamic e) {
    AppSnackbar.error(
      title: 'Error',
      message: 'Failed to delete account: ${e.toString()}',
    );
  }

  void disposeControllers() {
    fullNameController.dispose();
    phoneController.dispose();
    languagesController.dispose();
  }

  Future<void> saveToSharedPreferences({
    required String nameKey,
    required String phoneKey,
    String? docIdKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveBasicData(prefs, nameKey, phoneKey);
    await _saveDocId(prefs, docIdKey);
    _updateDisplayValues();
  }

  Future<void> _saveBasicData(
      SharedPreferences prefs, String nameKey, String phoneKey) async {
    await prefs.setString(nameKey, fullNameController.text.trim());
    if (phoneController.text.isNotEmpty) {
      await prefs.setString(phoneKey, phoneController.text.trim());
    }
  }

  Future<void> _saveDocId(SharedPreferences prefs, String? docIdKey) async {
    if (docIdKey != null && userDocId.value.isNotEmpty) {
      await prefs.setString(docIdKey, userDocId.value);
    }
  }

  void _updateDisplayValues() {
    displayName.value = fullNameController.text.trim();
    displayPhone.value = phoneController.text.trim();
  }

  Future<void> loadFromSharedPreferences(
    String nameKey,
    String phoneKey, {
    String? emailKey,
    String? docIdKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _loadNameFromPrefs(prefs, nameKey);
      _loadPhoneFromPrefs(prefs, phoneKey);
      _loadDocIdFromPrefs(prefs, docIdKey);
    } catch (e) {
      Get.log('Error loading from SharedPreferences: $e');
    }
  }

  void _loadNameFromPrefs(SharedPreferences prefs, String nameKey) {
    final userName = prefs.getString(nameKey) ?? '';
    fullNameController.text = userName;
    displayName.value = userName;
  }

  void _loadPhoneFromPrefs(SharedPreferences prefs, String phoneKey) {
    final userPhone = prefs.getString(phoneKey) ?? '';
    if (userPhone.isNotEmpty) {
      phoneController.text = userPhone;
      displayPhone.value = userPhone;
    }
  }

  void _loadDocIdFromPrefs(SharedPreferences prefs, String? docIdKey) {
    if (docIdKey != null) {
      userDocId.value = prefs.getString(docIdKey) ?? '';
    }
  }
}
