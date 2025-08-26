import 'package:get/get.dart';

class UserController extends GetxController {
  final RxString displayName = ''.obs;
  final RxString photoUrl = ''.obs;

  void setUser({String? name, String? photo}) {
    displayName.value = name ?? '';
    if (photo != null) {
      photoUrl.value = photo;
    }
  }
}
