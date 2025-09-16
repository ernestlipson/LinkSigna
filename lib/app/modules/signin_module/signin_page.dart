import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/app/modules/signin_module/signin_controller.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class signinPage extends GetView<signinController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('signin Page')),
      body: Container(
        child: Obx(()=>Container(child: Text(controller.obj),)),
      ),
    );
  }
}
