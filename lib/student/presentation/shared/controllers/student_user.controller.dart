import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/users/user.model.dart';
import '../../../../infrastructure/dal/services/user.firestore.service.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class StudentUserController extends GetxController {
  final current = Rxn<User>();
  final loading = false.obs;
  final error = RxnString();
  final RxString localImagePath = ''.obs;
  StreamSubscription? _sub;
  final _auth = FirebaseAuth.instance;
  late UserFirestoreService _service;
  static const _prefsDocKey = 'student_user_doc_id';
  static const _localImageKey = 'local_profile_image';
  String? _docId;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<UserFirestoreService>();
    _loadLocalImagePath();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    _docId = prefs.getString(_prefsDocKey);

    // First try: Use cached document ID
    if (_docId != null) {
      _subscribe(_docId!);
      return;
    }

    // Second try: Find by authUid
    final byAuth = await _service.findByAuthUid(authUser.uid);
    if (byAuth != null && byAuth.isStudent) {
      _docId = byAuth.uid;
      await prefs.setString(_prefsDocKey, _docId!);
      _subscribe(_docId!);
      current.value = byAuth; // Set immediately
      return;
    }

    // Third try: Find by phone
    final phone = authUser.phoneNumber;
    if (phone != null && phone.isNotEmpty) {
      final byPhone = await _service.findByPhone(phone);
      if (byPhone != null && byPhone.isStudent) {
        _docId = byPhone.uid;
        await prefs.setString(_prefsDocKey, _docId!);
        _subscribe(_docId!);
        current.value = byPhone; // Set immediately
        return;
      }
    }

    // Fourth try: Find by email
    final email = authUser.email;
    if (email != null && email.isNotEmpty) {
      final byEmail = await _service.findByEmail(email);
      if (byEmail != null && byEmail.isStudent) {
        _docId = byEmail.uid;
        await prefs.setString(_prefsDocKey, _docId!);
        _subscribe(_docId!);
        current.value = byEmail; // Set immediately
        return;
      }
    }

    Get.log('Warning: No student profile found for authenticated user');
  }

  void _subscribe(String docId) {
    _sub?.cancel();
    _sub = _service.stream(docId).listen((profile) {
      current.value = profile;
    }, onError: (e) => error.value = e.toString());
  }

  Future<void> ensureProfileExists({
    required String displayName,
    required String phone,
    String? email,
    String? universityLevel,
    String? language,
    String? bio,
  }) async {
    final authUser = _auth.currentUser;
    if (authUser == null) return;
    loading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_docId != null) {
        await _service.updateFields(_docId!, {
          'displayName': displayName,
          'phone': phone,
          if (email != null) 'email': email,
          if (universityLevel != null) 'university_level': universityLevel,
          if (language != null) 'language': language,
          if (bio != null) 'bio': bio,
        });
        return;
      }

      final created = await _service.getOrCreateStudent(
        authUid: authUser.uid,
        displayName: displayName,
        phone: phone,
        email: email ?? '',
        universityLevel: universityLevel,
        language: language,
        bio: bio,
      );
      if (created != null) {
        _docId = created.uid;
        await prefs.setString(_prefsDocKey, _docId!);
        _subscribe(_docId!);
      }
    } catch (e) {
      AppSnackbar.error(
        title: 'Profile Error',
        message: e.toString(),
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_docId == null) return;
    try {
      await _service.updateFields(_docId!, data);
    } catch (e) {
      AppSnackbar.error(
        title: 'Update Failed',
        message: e.toString(),
      );
    }
  }

  // Profile image management
  void setLocalProfileImage(String imagePath) {
    localImagePath.value = imagePath;
    _saveLocalImagePath(imagePath);
  }

  String? get currentProfileImage {
    if (localImagePath.value.isNotEmpty) {
      return localImagePath.value;
    }
    return current.value?.avatarUrl;
  }

  bool get isLocalImage => localImagePath.value.isNotEmpty;

  Future<void> _saveLocalImagePath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localImageKey, path);
    } catch (e) {
      Get.log('Error saving local image path: $e');
    }
  }

  Future<void> _loadLocalImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString(_localImageKey);
      if (savedPath != null && savedPath.isNotEmpty) {
        localImagePath.value = savedPath;
      }
    } catch (e) {
      Get.log('Error loading local image path: $e');
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
