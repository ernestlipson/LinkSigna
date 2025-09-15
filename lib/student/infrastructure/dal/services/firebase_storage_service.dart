import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseStorageService extends GetxService {
  // Storage reference for student profile images
  final Reference _studentProfileRef =
      FirebaseStorage.instance.ref().child('students').child('profile_images');

  /// Upload profile image for a student
  /// Returns the download URL if successful, null otherwise
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Create a consistent filename using userId (no timestamp) to allow overwriting
      final String fileName = '${userId}_profile.jpg';
      final Reference imageRef = _studentProfileRef.child(fileName);

      // Upload the file, this will automatically overwrite any existing image
      final UploadTask uploadTask = imageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save the download URL to SharedPreferences for offline access
      await _saveProfileImageUrl(userId, downloadUrl);

      Get.log('Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      Get.log('Error uploading profile image: $e');
      Get.snackbar(
        'Upload Failed',
        'Failed to upload profile image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        colorText: Get.theme.colorScheme.error,
      );
      return null;
    }
  }

  /// Download profile image for a student
  /// Returns the image data if successful, null otherwise
  Future<Uint8List?> downloadProfileImage(String imageUrl) async {
    try {
      final Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      final Uint8List? imageData = await imageRef.getData();
      return imageData;
    } catch (e) {
      Get.log('Error downloading profile image: $e');
      return null;
    }
  }

  /// Get profile image URL for a student from SharedPreferences
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_image_url_$userId');
    } catch (e) {
      Get.log('Error getting profile image URL: $e');
      return null;
    }
  }

  /// Save profile image URL to SharedPreferences
  Future<void> _saveProfileImageUrl(String userId, String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_url_$userId', imageUrl);
    } catch (e) {
      Get.log('Error saving profile image URL: $e');
    }
  }

  /// Delete profile image for a student
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      final Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await imageRef.delete();

      // Remove from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs
          .remove('profile_image_url_${_extractUserIdFromUrl(imageUrl)}');

      Get.log('Profile image deleted successfully');
      return true;
    } catch (e) {
      Get.log('Error deleting profile image: $e');
      return false;
    }
  }

  /// Extract user ID from image URL
  String _extractUserIdFromUrl(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        if (fileName.contains('_')) {
          return fileName.split('_').first;
        }
      }
    } catch (e) {
      Get.log('Error extracting user ID from URL: $e');
    }
    return '';
  }

  /// Check if user has a profile image
  Future<bool> hasProfileImage(String userId) async {
    try {
      final imageUrl = await getProfileImageUrl(userId);
      return imageUrl != null && imageUrl.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get storage usage statistics (for monitoring)
  Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      // This is a basic implementation - Firebase Storage doesn't provide
      // direct usage statistics through the client SDK
      // You would need to implement this through Cloud Functions or admin SDK
      return {
        'status': 'available',
        'message': 'Storage usage monitoring requires backend implementation',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
}
