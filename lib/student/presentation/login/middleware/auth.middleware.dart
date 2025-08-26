import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login.controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return Get.find<LoginController>().phoneController.text.isEmpty
        ? RouteSettings(name: '/login')
        : null;
  }
}
