import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:get/get.dart';

import '../../../domain/core/app.write.client.dart';
import '../../../domain/core/interfaces/auth.interface.dart';

class AppWriteService implements IAuthDataSource {
  final account = Get.find<AppWriteClient>().account;
  AppWriteService get put => Get.put(AppWriteService());

  @override
  Future<void> requestPhoneOTP(String phone) async {
    try {
      print('Requesting OTP for phone: $phone');

      final token = await account.createPhoneToken(
        userId: ID.unique(),
        phone: phone,
      );
      print('Phone OTP token: $token');
    } catch (e) {
      print('Error requesting phone OTP: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  @override
  Future<models.Session> verifyOTP(String userId, String secret) async {
    try {
      // Create session with the OTP secret
      final session = await account.createSession(
        userId: userId,
        secret: secret,
      );
      return session;
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  @override
  Future<models.Session> loginWithGoogle() async {
    try {
      // For mobile apps, you need to handle the OAuth flow differently
      // This creates an OAuth2 session
      await account.createOAuth2Session(
        provider: OAuthProvider.google,
        success: 'your-app://success', // Your app's custom URL scheme
        failure: 'your-app://failure', // Your app's custom URL scheme
      );

      // Get the current session after OAuth success
      final session = await account.getSession(sessionId: 'current');
      return session;
    } catch (e) {
      print('Error with Google login: $e');
      rethrow;
    }
  }

  // Additional helper methods
  Future<models.User> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Test network connectivity to AppWrite
  Future<bool> testConnection() async {
    try {
      print('Testing connection to AppWrite...');
      // Try to get account info to test connection
      await account.get();
      print('Connection successful');
      return true;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }
}
