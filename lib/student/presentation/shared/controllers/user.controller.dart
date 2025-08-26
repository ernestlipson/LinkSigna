import 'package:get/get.dart';

class User {
  final String? name;
  final String? phone;
  final String? photo;

  User({this.name, this.phone, this.photo});
}

class UserController extends GetxController {
  final RxString displayName = ''.obs;
  final RxString photoUrl = ''.obs;
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
}
