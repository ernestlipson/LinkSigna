import 'package:sign_language_app/infrastructure/dal/services/network/network.mixin.dart';

abstract class BaseNetwork with NetworkMixin {
  BaseNetwork() {
    initializeNetwork();
  }
}
