import 'package:sign_language_app/infrastructure/dal/models/flags.model.dart';
import 'flag.entity.dart';

extension FlagsModelExtension on Flags {
  Flag toEntity() {
    return Flag(
      png: png,
      svg: svg,
      alt: alt,
    );
  }
}
