import '../../app/modules/signin_module/signin_bindings.dart';
import '../../app/modules/signin_module/signin_page.dart';
import 'package:get/get.dart';
part './app_routes.dart';
/**
 * GetX Generator - fb.com/htngu.99
 * */

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SIGNIN,
      page: () => signinPage(),
      binding: signinBinding(),
    ),
  ];
}