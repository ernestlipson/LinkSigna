import 'package:appwrite/models.dart' as models;

abstract class IAuthDataSource {
  Future<models.Token> requestPhoneOTP(String phone);
  Future<models.Session> verifyOTP(String userId, String secret);
  Future<models.Session> loginWithGoogle();
  Future<models.User> getCurrentUser();
  Future<void> logout();
  Future<bool> isLoggedIn();
}
