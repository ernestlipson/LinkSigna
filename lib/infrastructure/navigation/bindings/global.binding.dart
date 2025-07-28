import 'package:get/get.dart';

import '../../../domain/core/app.write.client.dart';
import '../../../domain/core/interfaces/auth.interface.dart';
import '../../../domain/repositories/auth.repo.dart';
import '../../../domain/repositories/country.repo.dart';
import '../../../presentation/shared/controllers/country.controller.dart';
import '../../../presentation/shared/controllers/user.controller.dart';
import '../../dal/services/app.write.service.dart';
import '../../services/video_call.service.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AppWrite client is available globally
    if (!Get.isRegistered<AppWriteClient>()) {
      Get.put<AppWriteClient>(AppWriteClient(), permanent: true);
    }

    // Register auth data source globally
    Get.lazyPut<IAuthDataSource>(() => AppWriteService(), fenix: true);

    // Register auth repository implementation globally
    Get.lazyPut<IAuthRepo>(() => AuthRepoImpl(Get.find<IAuthDataSource>()),
        fenix: true);

    // Register country repository and controller
    Get.lazyPut<CountryRepository>(() => CountryRepository(), fenix: true);
    Get.lazyPut<CountryController>(() => CountryController(), fenix: true);

    // Register user controller globally
    Get.lazyPut<UserController>(() => UserController(), fenix: true);

    // Register video call service globally
    Get.lazyPut<VideoCallService>(() => VideoCallService(), fenix: true);
  }
}
