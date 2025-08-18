import 'package:get/get.dart';

import '../../../domain/core/app.write.client.dart';
import '../../../domain/core/interfaces/auth.interface.dart';
import '../../../domain/repositories/country.repo.dart';
import '../../../presentation/shared/controllers/country.controller.dart';
import '../../../presentation/shared/controllers/user.controller.dart';
import '../../dal/services/app.write.service.dart';
import '../../dal/services/firebase.auth.service.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AppWrite client is available globally
    if (!Get.isRegistered<AppWriteClient>()) {
      Get.put<AppWriteClient>(AppWriteClient(), permanent: true);
    }

    // Register auth data source globally
    Get.lazyPut<IAuthDataSource>(() => AppWriteService(), fenix: true);

    // Register AppWriteService globally (keeping for backward compatibility)
    Get.lazyPut<AppWriteService>(() => AppWriteService(), fenix: true);

    // Register FirebaseAuthService globally
    Get.lazyPut<FirebaseAuthService>(() => FirebaseAuthService(), fenix: true);

    // Register country repository and controller
    Get.lazyPut<CountryRepository>(() => CountryRepository(), fenix: true);
    Get.lazyPut<CountryController>(() => CountryController(), fenix: true);

    // Register user controller globally
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
  }
}
