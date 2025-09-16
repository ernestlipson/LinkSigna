import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
import '../../../../domain/users/interpreter_user.model.dart';

class InterpreterProfileController extends GetxController {
  final InterpreterUserFirestoreService _firestoreService =
      Get.find<InterpreterUserFirestoreService>();
  final Rx<InterpreterUser?> profile = Rx<InterpreterUser?>(null);
  final RxString interpreterId = RxString('');
  StreamSubscription? _profileSub;

  @override
  void onInit() {
    super.onInit();
    loadProfileFromCache();
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    super.onClose();
  }

  /// Load profile from cached data on app startup
  Future<void> loadProfileFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedId = prefs.getString('interpreter_id');
      final cachedEmail = prefs.getString('interpreter_email');

      if (cachedId != null && cachedId.isNotEmpty) {
        await loadProfileById(cachedId);
      } else if (cachedEmail != null && cachedEmail.isNotEmpty) {
        await loadProfileByEmail(cachedEmail);
      }
    } catch (e) {
      Get.log('Error loading profile from cache: $e');
    }
  }

  /// Load profile by interpreter ID
  Future<void> loadProfileById(String id) async {
    try {
      final user = await _firestoreService.getById(id);
      if (user != null) {
        profile.value = user;
        interpreterId.value = id;
        _listenToProfile(id);
        await _cacheUserData(user);
      }
    } catch (e) {
      Get.log('Error loading profile by ID: $e');
    }
  }

  /// Load profile by email (fallback)
  Future<void> loadProfileByEmail(String email) async {
    try {
      final user = await _firestoreService.findByEmail(email);
      if (user != null) {
        profile.value = user;
        interpreterId.value = user.interpreterID;
        _listenToProfile(user.interpreterID);
        await _cacheUserData(user);
      }
    } catch (e) {
      Get.log('Error loading profile by email: $e');
    }
  }

  /// Set profile data directly (used after login/signup)
  void setProfile(InterpreterUser user) {
    profile.value = user;
    interpreterId.value = user.interpreterID;
    _listenToProfile(user.interpreterID);
    _cacheUserData(user);
  }

  /// Listen to real-time updates
  void _listenToProfile(String id) {
    _profileSub?.cancel();
    _profileSub = _firestoreService.stream(id).listen((user) {
      if (user != null) {
        profile.value = user;
        _cacheUserData(user);
      }
    });
  }

  /// Update profile fields
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      if (interpreterId.value.isNotEmpty) {
        await _firestoreService.updateFields(interpreterId.value, data);
      }
    } catch (e) {
      Get.log('Error updating profile: $e');
      rethrow;
    }
  }

  /// Update availability status
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      if (interpreterId.value.isNotEmpty) {
        await _firestoreService.updateAvailability(
            interpreterId.value, isAvailable);
      }
    } catch (e) {
      Get.log('Error updating availability: $e');
      rethrow;
    }
  }

  /// Cache user data locally for redundancy
  Future<void> _cacheUserData(InterpreterUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('interpreter_id', user.interpreterID);
      await prefs.setString('interpreter_email', user.email);
      await prefs.setString('interpreter_name', user.displayName);
      await prefs.setBool('interpreter_logged_in', true);
    } catch (e) {
      Get.log('Error caching user data: $e');
    }
  }

  /// Get cached interpreter ID
  static Future<String?> getCachedInterpreterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('interpreter_id');
  }

  /// Clear cached data (for logout)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('interpreter_id');
      await prefs.remove('interpreter_email');
      await prefs.remove('interpreter_name');
      await prefs.setBool('interpreter_logged_in', false);

      profile.value = null;
      interpreterId.value = '';
      _profileSub?.cancel();
    } catch (e) {
      Get.log('Error clearing cache: $e');
    }
  }
}
