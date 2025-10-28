import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  // Initialize Firebase App Check to prevent placeholder tokens and protect backend calls
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    // Use debug provider on iOS for development. Configure App Attest for production later if needed.
    appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
  );

  // Optional: set language code for Firebase Auth to avoid null locale header warnings
  try {
    await FirebaseAuth.instance.setLanguageCode('en');
  } catch (_) {
    // No-op: ignore if not available on some platforms at init time
  }

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
