import '../core/interfaces/auth.interface.dart';
import '../entities/user.entity.dart';

abstract class IAuthRepo {
  Future<String> sendOtp(String phone); // Returns userId for OTP verification
  Future<UserEntity> verifyOtp(String userId, String otp);
  Future<UserEntity> googleSignIn();
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<bool> isLoggedIn();
}

class AuthRepoImpl implements IAuthRepo {
  final IAuthDataSource ds;

  AuthRepoImpl(this.ds);

  @override
  Future<String> sendOtp(String phone) async {
    try {
      final token = await ds.requestPhoneOTP(phone);
      return token.userId; // Return the userId for OTP verification
    } catch (e) {
      print('Error in sendOtp: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> verifyOtp(String userId, String otp) async {
    try {
      final session = await ds.verifyOTP(userId, otp);
      final appUser = await ds.getCurrentUser();
      return UserEntity(
        id: appUser.$id,
        email: appUser.email,
        name: appUser.name,
        emailVerification: appUser.emailVerification,
      );
    } catch (e) {
      print('Error in verifyOtp: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> googleSignIn() async {
    try {
      await ds.loginWithGoogle();
      final appUser = await ds.getCurrentUser();
      return UserEntity(
        id: appUser.$id,
        email: appUser.email,
        name: appUser.name,
        emailVerification: appUser.emailVerification,
      );
    } catch (e) {
      print('Error in googleSignIn: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      if (await ds.isLoggedIn()) {
        final appUser = await ds.getCurrentUser();
        return UserEntity(
          id: appUser.$id,
          email: appUser.email,
          name: appUser.name,
          emailVerification: appUser.emailVerification,
        );
      }
      return null;
    } catch (e) {
      print('Error in getCurrentUser: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await ds.logout();
    } catch (e) {
      print('Error in logout: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await ds.isLoggedIn();
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
}
