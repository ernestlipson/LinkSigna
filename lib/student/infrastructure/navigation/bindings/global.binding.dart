import 'package:get/get.dart';
import '../../../../infrastructure/dal/services/session.firestore.service.dart';
import '../../../../infrastructure/domain/repositories/country.repository.dart';
import '../../../../infrastructure/presentation/controllers/country.controller.dart';
import '../../dal/services/interpreter.service.dart';

import '../../../presentation/shared/controllers/user.controller.dart';
import '../../../../infrastructure/dal/services/student_user.firestore.service.dart';
import '../../../../infrastructure/dal/services/interpreter_user.firestore.service.dart';
import '../../../presentation/shared/controllers/student_user.controller.dart';
import '../../../../interpreter/presentation/shared/controllers/interpreter_profile.controller.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountryRepository>(() => CountryRepository(), fenix: true);
    Get.lazyPut<CountryController>(() => CountryController(), fenix: true);
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<StudentUserFirestoreService>(
        () => StudentUserFirestoreService(),
        fenix: true);
    Get.lazyPut<StudentUserController>(() => StudentUserController(),
        fenix: true);
    Get.lazyPut<InterpreterUserFirestoreService>(
        () => InterpreterUserFirestoreService(),
        fenix: true);
    Get.lazyPut<InterpreterProfileController>(
        () => InterpreterProfileController(),
        fenix: true);
    Get.lazyPut<SessionFirestoreService>(() => SessionFirestoreService(),
        fenix: true);
    Get.lazyPut<InterpreterService>(() => InterpreterService(), fenix: true);
  }
}
