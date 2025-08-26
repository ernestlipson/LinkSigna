import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  /// The text to display inside the button.
  final String text;

  /// The callback that is fired when the button is tapped.
  final VoidCallback? onPressed;

  /// An optional icon to display before the text.
  final Widget? icon;

  /// Optionally, you can pass a [TextStyle] to customize the text style.
  final TextStyle? textStyle;

  /// The color of the button.
  final Color? color;

  /// Indicates whether the button is in a loading state.
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.textStyle,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 44,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color:
            color ?? const Color(0xFF9E1068), // Use provided color or default
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
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon!,
                          const SizedBox(
                              width: 12), // Gap between icon and text
                          Text(
                            text,
                            style: textStyle ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w600,
                            ),
                      ),
          ),
        ),
      ),
    );
  }
}
