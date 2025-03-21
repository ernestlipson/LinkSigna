import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/app_theme.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: appTheme, // Update to use the new theme
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
