import 'package:get/get.dart';

import '../dal/services/firebase_storage_service.dart';
import '../dal/services/interpreter.service.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Firebase Storage Service
    Get.lazyPut<FirebaseStorageService>(() => FirebaseStorageService(),
        fenix: true);
    Get.lazyPut<InterpreterService>(() => InterpreterService(), fenix: true);
  }
}
