import 'package:get/get.dart';

import '../../init.dart';

class InitController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _resolveRoute();
  }

  Future<void> _resolveRoute() async {
    final route = await initializeUserSession();
    Get.offAllNamed(route);
  }
}
