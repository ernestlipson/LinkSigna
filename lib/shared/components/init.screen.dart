import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/init.controller.dart';

class InitScreen extends GetView<InitController> {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
