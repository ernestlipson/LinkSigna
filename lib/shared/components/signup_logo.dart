import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppCenterLogo extends StatelessWidget {
  const AppCenterLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        "assets/icons/TravelIB.svg",
      ),
    );
  }
}
