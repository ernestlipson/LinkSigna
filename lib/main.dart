import 'package:flutter/material.dart';
import 'package:sign_language_app/presentation/components/date_picker_example.dart';

import 'infrastructure/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme.copyWith(
        textTheme: appTheme.textTheme.apply(
          fontFamily: 'WorkSans',
        ),
      ),
      // initialRoute: Routes.initialRoute,
      // getPages: Nav.routes,
      home: MyHomePage(title: "Bottom Sheet"),
    );
  }
}
