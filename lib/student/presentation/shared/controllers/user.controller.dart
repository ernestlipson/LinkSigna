import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String? name;
  final String? phone;
  final String? photo;

  User({this.name, this.phone, this.photo});
}

class UserController extends GetxController {
  final RxString displayName = ''.obs;
  final RxString photoUrl = ''.obs;
  final RxString localImagePath = ''.obs; // Add this for local images
  final Rx<User?> user = Rx<User?>(null);

  void setUser({String? name, String? phone, String? photo}) {
    displayName.value = name ?? '';
    if (photo != null) {
      photoUrl.value = photo;
    }

    // Update user object
    user.value = User(
      name: name ?? user.value?.name,
      phone: phone ?? user.value?.phone,
      photo: photo ?? user.value?.photo,
    );
  }

  // Add method to set local profile image
  void setLocalProfileImage(String imagePath) {
    localImagePath.value = imagePath;
    // Save to SharedPreferences for persistence
    _saveLocalImagePath(imagePath);
  }

  // Add method to get the current profile image (local or network)
  String? get currentProfileImage {
    if (localImagePath.value.isNotEmpty) {
      return localImagePath.value;
    }
    if (photoUrl.value.isNotEmpty) {
      return photoUrl.value;
    }
    return null;
  }

  // Check if current image is local file
  bool get isLocalImage => localImagePath.value.isNotEmpty;

  Future<void> _saveLocalImagePath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_profile_image', path);
    } catch (e) {
      print('Error saving local image path: $e');
    }
  }

  Future<void> loadLocalImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('local_profile_image');
      if (savedPath != null && savedPath.isNotEmpty) {
        localImagePath.value = savedPath;
      }
    } catch (e) {
      print('Error loading local image path: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadLocalImagePath();
  }
}
