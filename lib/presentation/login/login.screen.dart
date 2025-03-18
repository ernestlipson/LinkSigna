import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoginScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'LoginScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
