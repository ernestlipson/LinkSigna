import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupLogo extends StatelessWidget {
  const SignupLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        "assets/icons/TravelIB.svg",
      ),
    );
  }
}
