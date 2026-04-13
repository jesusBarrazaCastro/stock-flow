import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData? icon;

  const Button({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textStyle,
    this.width,
    this.height = 40,
    this.borderRadius,
    this.icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primary,
          foregroundColor: AppTheme.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusFull),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(icon != null)...[
              Icon(icon!, color: AppTheme.textOnPrimary, size: 20),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                text,
                style: textStyle ?? GoogleFonts.manrope(
                  color: AppTheme.textOnPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
