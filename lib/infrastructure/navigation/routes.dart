class Routes {
  static Future<String> get initialRoute async {
    return LOGIN;
  }

  static const HOME = '/home';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const FORGOT_PASSWORD = '/forgot-password';
}
