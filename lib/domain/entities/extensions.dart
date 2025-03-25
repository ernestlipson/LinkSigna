import '../../infrastructure/dal/daos/models/flags.model.dart';
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
