import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? icon;
  final TextStyle? textStyle;
  final Color? color;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.textStyle,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isLoading
            ? const Color.fromARGB(255, 233, 189, 216)
            : (color ?? const Color(0xFF9E1068)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        )),
                  )
                : icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon!,
                          const SizedBox(width: 12),
                          Text(
                            text,
                            style: textStyle ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      )
                    : Text(
                        text,
                        style: textStyle ??
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? icon;
  final TextStyle? textStyle;
  final Color? borderColor;
  final Color? textColor;
  final bool isLoading;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.textStyle,
    this.borderColor,
    this.textColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? const Color(0xFF9E1068);
    final effectiveTextColor = textColor ?? Colors.black;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isLoading
              ? const Color.fromARGB(255, 233, 189, 216)
              : effectiveBorderColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveBorderColor,
                        )),
                  )
                : icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon!,
                          const SizedBox(width: 12),
                          Text(
                            text,
                            style: textStyle ??
                                TextStyle(
                                  color: effectiveTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      )
                    : Text(
                        text,
                        style: textStyle ??
                            TextStyle(
                              color: effectiveTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
          ),
        ),
      ),
    );
  }
}
