import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static Widget home({double? size, Color? color}) => SvgPicture.asset(
        'assets/icons/home-2.svg',
        width: size,
        height: size,
        color: color,
      );
  static Widget calendar({double? size, Color? color}) => SvgPicture.asset(
        'assets/icons/calendar-2.svg',
        width: size,
        height: size,
        color: color,
      );
  static Widget messageQuestion({double? size, Color? color}) =>
      SvgPicture.asset(
        'assets/icons/message-question.svg',
        width: size,
        height: size,
        color: color,
      );
  static Widget setting({double? size, Color? color}) => SvgPicture.asset(
        'assets/icons/setting-2.svg',
        width: size,
        height: size,
        color: color,
      );
  static Widget notification({double? size, Color? color}) => SvgPicture.asset(
        'assets/icons/notification-bing.svg',
        width: size,
        height: size,
        color: color,
      );
  static Widget diagram({double? size, Color? color}) => SvgPicture.asset(
        'assets/icons/diagram.svg',
        width: size,
        height: size,
        color: color,
      );
  static Widget vector({double? size, Color? color}) => SvgPicture.asset(
        'assets/icons/Vector.svg',
        width: size,
        height: size,
        color: color,
      );
  static Widget social({double? size, Color? color}) => SvgPicture.asset(
        'assets/icons/Social icon.svg',
        width: size,
        height: size,
        color: color,
      );
  static Widget travelIB({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        'assets/icons/TravelIB.svg',
        width: width,
        height: height,
        color: color,
      );
  static Widget amico({double? width, double? height}) => SvgPicture.asset(
        'assets/icons/amico.svg',
        width: width,
        height: height,
      );
}
