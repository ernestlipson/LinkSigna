import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../zoom_config.dart';

String generateJwt(String sessionName, String roleType) {
  final jwt = JWT(
    {
      'iss': configs['ZOOM_SDK_KEY'],
      'exp':
          DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch,
    },
  );

  final token = jwt.sign(
    SecretKey(configs['ZOOM_SDK_SECRET']!),
    algorithm: JWTAlgorithm.HS256,
  );

  return token;
}
