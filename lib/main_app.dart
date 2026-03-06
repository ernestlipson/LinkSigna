import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/app_theme.dart';
import 'student/infrastructure/navigation/bindings/global.binding.dart';

class LinkSigna extends StatelessWidget {
  const LinkSigna({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialBinding: GlobalBinding(),
      initialRoute: Routes.INITIAL,
      getPages: Nav.routes,
    );
  }
}
