import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseStorageService extends GetxService {
  late final FirebaseStorage _storage;

  FirebaseStorageService() {
    _storage = FirebaseStorage.instance;
  }

  // Uploads a profile image to Firebase Storage and persists the URL locally for offline use.
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
    required String folder,
  }) async {
    try {
      // Create a reference to the storage location
      final storageRef = _storage.ref().child('$folder/${userId}_profile.jpg');

      // Upload the file
      final uploadTask = await storageRef.putFile(imageFile);

      // Get the download URL
      final url = await uploadTask.ref.getDownloadURL();

      // Persist the URL locally for offline use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_url_$userId', url);

      Get.log('Firebase Storage upload success: $url');
      return url;
    } on FirebaseException catch (e) {
      Get.log('Firebase Storage upload error: ${e.code} - ${e.message}');
      Get.snackbar(
        'Upload Failed',
        'Failed to upload profile image: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      Get.log('Firebase Storage upload error: $e');
      Get.snackbar(
        'Upload Failed',
        'Failed to upload profile image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Helper for parity with existing load logic (reads same key)
  Future<String?> getProfileImageUrl(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_url_$userId');
  }
}
