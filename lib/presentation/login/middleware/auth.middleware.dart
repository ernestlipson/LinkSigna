import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/presentation/login/controllers/login.controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return Get.find<LoginController>().passwordController.text.isEmpty
        ? RouteSettings(name: '/login')
        : null;
  }
}
