import 'package:get/get.dart';
import '../services/firebase_storage_service.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Firebase Storage Service
    Get.lazyPut<FirebaseStorageService>(() => FirebaseStorageService(),
        fenix: true);
  }
}
