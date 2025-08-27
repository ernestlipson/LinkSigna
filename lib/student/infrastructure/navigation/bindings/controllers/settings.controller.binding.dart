import 'package:get/get.dart';

import '../../../../presentation/settings/controllers/settings.controller.dart';
import '../../../services/firebase_storage_service.dart';

class SettingsControllerBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Firebase Storage Service first
    Get.lazyPut<FirebaseStorageService>(() => FirebaseStorageService(),
        fenix: true);

    // Initialize Settings Controller
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
  }
}
