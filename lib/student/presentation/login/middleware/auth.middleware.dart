import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}
