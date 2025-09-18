import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/cloudinary.config.dart';

class CloudinaryService extends GetxService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName,
      CloudinaryConfig.unsignedPreset,
      cache: false,
    );
  }

  // Uploads a profile image and persists the URL locally for offline use.
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
    required String folder,
  }) async {
    try {
      final res = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          publicId: '${userId}_profile', // consistent overwrite behavior
        ),
      );

      final url = res.secureUrl;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_url_$userId', url);

      Get.log('Cloudinary upload success: $url');
      return url;
    } catch (e) {
      Get.log('Cloudinary upload error: $e');
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
