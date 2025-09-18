import 'package:get/get.dart';

import '../../../infrastructure/dal/services/cloudinary.service.dart';
import '../dal/services/firebase_storage_service.dart';
import '../dal/services/interpreter.service.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirebaseStorageService>(() => FirebaseStorageService(),
        fenix: true);
    Get.lazyPut<InterpreterService>(() => InterpreterService(), fenix: true);
    Get.lazyPut<CloudinaryService>(() => CloudinaryService(), fenix: true);
  }
}
