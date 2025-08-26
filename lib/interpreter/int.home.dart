import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'presentation/main/interpreter.screen.dart';
import 'presentation/signup/interpreter.screen.dart';

import 'infrastructure/navigation/routes.dart';
import 'infrastructure/navigation/bindings/global.binding.dart';

class InterpreterApp extends StatelessWidget {
  const InterpreterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LinkSigna Interpreter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: GlobalBinding(),
      initialRoute: Routes.SIGNUP,
      getPages: [
        GetPage(
          name: Routes.SIGNUP,
          page: () => const InterpreterSignupScreen(),
        ),
        GetPage(
          name: Routes.INTERPRETER,
          page: () => const InterpreterScreen(),
        ),
      ],
    );
  }
}
