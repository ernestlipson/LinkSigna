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
  StreamSubscription? _sub;
  final _auth = FirebaseAuth.instance;
  late UserFirestoreService _service;
  static const _prefsDocKey = 'student_user_doc_id';
  String? _docId;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<UserFirestoreService>();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authUser = _auth.currentUser;
    if (authUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    _docId = prefs.getString(_prefsDocKey);

    if (_docId != null) {
      _subscribe(_docId!);
      return;
    }

    final byAuth = await _service.findByAuthUid(authUser.uid);
    if (byAuth != null && byAuth.isStudent) {
      _docId = byAuth.uid;
      await prefs.setString(_prefsDocKey, _docId!);
      _subscribe(_docId!);
      return;
    }

    final phone = authUser.phoneNumber;
    if (phone != null && phone.isNotEmpty) {
      final byPhone = await _service.findByPhone(phone);
      if (byPhone != null && byPhone.isStudent) {
        _docId = byPhone.uid;
        await prefs.setString(_prefsDocKey, _docId!);
        _subscribe(_docId!);
        return;
      }
    }
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

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
