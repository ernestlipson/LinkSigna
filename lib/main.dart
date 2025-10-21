import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'init.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/theme/app_theme.dart';
import 'student/infrastructure/navigation/bindings/global.binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final initialRoute = await initializeUserSession();

  runApp(Main(initialRoute: initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialBinding: GlobalBinding(),
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
