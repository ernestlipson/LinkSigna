import 'package:get/get.dart';
import '../../../../infrastructure/dal/services/session.firestore.service.dart';
import '../../dal/services/interpreter.service.dart';

import '../../../domain/repositories/country.repo.dart';
import '../../../presentation/shared/controllers/country.controller.dart';
import '../../../presentation/shared/controllers/user.controller.dart';
import '../../../../infrastructure/dal/services/student_user.firestore.service.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
import '../../../presentation/shared/controllers/student_user.controller.dart';
import '../../../../interpreter/presentation/shared/controllers/interpreter_profile.controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Register country repository and controller
    Get.lazyPut<CountryRepository>(() => CountryRepository(), fenix: true);
    Get.lazyPut<CountryController>(() => CountryController(), fenix: true);
    // Register user controller globally
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    // Student user Firestore service & controller
    Get.lazyPut<StudentUserFirestoreService>(
        () => StudentUserFirestoreService(),
        fenix: true);
    Get.lazyPut<StudentUserController>(() => StudentUserController(),
        fenix: true);
    // Interpreter user Firestore service
    Get.lazyPut<InterpreterUserFirestoreService>(
        () => InterpreterUserFirestoreService(),
        fenix: true);
    // Interpreter profile controller
    Get.lazyPut<InterpreterProfileController>(
        () => InterpreterProfileController(),
        fenix: true);
    // Register Firestore session service
    Get.lazyPut<SessionFirestoreService>(() => SessionFirestoreService(),
        fenix: true);
    // Register interpreter service (Firestore)
    Get.lazyPut<InterpreterService>(() => InterpreterService(), fenix: true);
  }
}
