import 'package:flutter/material.dart';

enum CustomButtonStyle {
  primary,
  secondary,
  danger,
  outline,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final Widget? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: null,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    final buttonStyle = _getButtonStyle();

    if (style == CustomButtonStyle.outline) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: buttonStyle,
        icon: icon ?? const Icon(Icons.touch_app),
        label: Text(text),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      style: buttonStyle,
      icon: icon ?? const Icon(Icons.touch_app),
      label: Text(text),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (style) {
      case CustomButtonStyle.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        );

      case CustomButtonStyle.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        );

      case CustomButtonStyle.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        );

      case CustomButtonStyle.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        );
    }
  }
}