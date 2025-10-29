class Routes {
  // Student Routes
  static get initialRoute => STUDENT_SIGNUP;

  static const STUDENT_DEAF_HISTORY = '/student/deaf-history';
  static const STUDENT_FORGOT_PASSWORD = '/student/forgot-password';
  static const STUDENT_HOME = '/student/home';
  static const STUDENT_INTERPRETERS = '/student/interpreters';
  static const STUDENT_LOGIN = '/student/login';
  static const STUDENT_SESSIONS = '/student/sessions';
  static const STUDENT_SETTINGS = '/student/settings';
  static const STUDENT_SIGNUP = '/student/signup';

  // Interpreter Routes
  static const INTERPRETER = '/interpreter/main';
  static const INTERPRETER_CHAT = '/interpreter/chat';
  static const INTERPRETER_HOME = '/interpreter/home';
  static const INTERPRETER_SIGNIN = '/interpreter/signin';
  static const INTERPRETER_SIGNUP = '/interpreter/signup';
  static const INTERPRETER_SESSIONS = '/interpreter/sessions';
}
