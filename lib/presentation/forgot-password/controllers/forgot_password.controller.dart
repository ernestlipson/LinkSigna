import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class ForgotPasswordController extends GetxController {
  Future<void> appDatabase() async {
    try {
      // Simulate a database operation
      final database = await openDatabase('my_database.db', version: 1,
          onCreate: (db, version) {
        // Create tables
        return db.execute(
          'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)',
        );
      });
      await Future.delayed(Duration(seconds: 2));
      print("Database opened successfully");
    } catch (e) {
      print("Error opening database: $e");
    }
  }

  final count = 0.obs;

  void increment() => count.value++;
}
