import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/signup.controller.dart';

class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignupScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SignupScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
