import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  /// The text to display inside the button.
  final String text;

  /// The callback that is fired when the button is tapped.
  final VoidCallback onPressed;

  /// An optional icon to display before the text.
  final Widget? icon;

  /// Optionally, you can pass a [TextStyle] to customize the text style.
  final TextStyle? textStyle;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 44,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF9E1068), // Background color #9E1068
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101828), // Shadow: 0px 1px 2px 0px #1018280D
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Center(
            child: icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                      const SizedBox(width: 12), // Gap between icon and text
                      Text(
                        text,
                        style: textStyle ??
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: textStyle ??
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
