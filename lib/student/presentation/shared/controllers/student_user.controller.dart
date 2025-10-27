import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/users/student_user.model.dart';
import '../../../../infrastructure/dal/services/student_user.firestore.service.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class StudentUserController extends GetxController {
  final current = Rxn<StudentUser>();
  final loading = false.obs;
  final error = RxnString();
  StreamSubscription? _sub;
  final _auth = FirebaseAuth.instance;
  late StudentUserFirestoreService _service;
  static const _prefsDocKey = 'student_user_doc_id';
  String? _docId; // Firestore document id (auto-generated)

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<StudentUserFirestoreService>();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return; // wait for OTP sign-in
    final prefs = await SharedPreferences.getInstance();
    _docId = prefs.getString(_prefsDocKey);

    // If we already have the doc id, subscribe directly
    if (_docId != null) {
      _subscribe(_docId!);
      return;
    }

    // Try lookup by authUid
    final byAuth = await _service.findByAuthUid(authUser.uid);
    if (byAuth != null) {
      _docId = byAuth.uid;
      await prefs.setString(_prefsDocKey, _docId!);
      _subscribe(_docId!);
      return;
    }

    // Fallback by phone if available
    final phone = authUser.phoneNumber;
    if (phone != null && phone.isNotEmpty) {
      final byPhone = await _service.findByPhone(phone);
      if (byPhone != null) {
        _docId = byPhone.uid;
        await prefs.setString(_prefsDocKey, _docId!);
        _subscribe(_docId!);
        return;
      }
    }
    // Else will be created when ensureProfileExists is called after OTP.
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
      // If doc already determined just update missing fields
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

      // Idempotent: returns existing user by authUid or creates a new UUID doc
      final created = await _service.getOrCreateByAuthUid(
        authUid: authUser.uid,
        displayName: displayName,
        phone: phone,
        email: email,
        universityLevel: universityLevel,
        language: language,
        bio: bio,
      );
      _docId = created.uid;
      await prefs.setString(_prefsDocKey, _docId!);
      _subscribe(_docId!);
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
    if (_docId == null) return; // not ready yet
    try {
      await _service.updateFields(_docId!, data);
    } catch (e) {
      AppSnackbar.error(
        title: 'Update Failed',
        message: e.toString(),
      );
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
