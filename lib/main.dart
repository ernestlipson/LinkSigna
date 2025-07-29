import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'domain/core/app.write.client.dart';
import 'firebase_options.dart';
import 'infrastructure/navigation/bindings/global.binding.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize AppWrite (keeping for backward compatibility)
  final appWriteClient = AppWriteClient();
  Get.put<AppWriteClient>(appWriteClient);

  runApp(Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: appTheme.copyWith(
          textTheme: appTheme.textTheme.apply(
        fontFamily: 'WorkSans',
      )),
      initialBinding: GlobalBinding(), // Add global binding
      initialRoute: Routes.initialRoute,
      getPages: Nav.routes,
    );
  }
}
