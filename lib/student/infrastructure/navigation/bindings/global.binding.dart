import 'package:get/get.dart';
import '../../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../../../infrastructure/domain/repositories/country.repository.dart';
import '../../../../infrastructure/presentation/controllers/country.controller.dart';
import '../../dal/services/interpreter.service.dart';

import '../../../../infrastructure/dal/services/user.firestore.service.dart';
import '../../../presentation/shared/controllers/student_user.controller.dart';
import '../../../../interpreter/presentation/shared/controllers/interpreter_profile.controller.dart';
import '../../../../shared/call/services/webrtc_signaling.service.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountryRepository>(() => CountryRepository(), fenix: true);
    Get.lazyPut<CountryController>(() => CountryController(), fenix: true);
    Get.lazyPut<UserFirestoreService>(() => UserFirestoreService(),
        fenix: true);
    Get.lazyPut<StudentUserController>(() => StudentUserController(),
        fenix: true);
    Get.lazyPut<InterpreterProfileController>(
        () => InterpreterProfileController(),
        fenix: true);
    Get.lazyPut<BookingFirestoreService>(() => BookingFirestoreService(),
        fenix: true);
    Get.lazyPut<InterpreterService>(() => InterpreterService(), fenix: true);
    Get.lazyPut<WebRTCSignalingService>(() => WebRTCSignalingService(),
        fenix: true);
  }
}
