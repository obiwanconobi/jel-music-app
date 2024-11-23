import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double width;
  final double height;
  final double fontSize;
  final Widget child;

  const Button({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 10.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.fontSize = 16.0,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Handle tap events
      onTap: onPressed,

      // Add visual feedback on tap
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        decoration: BoxDecoration(
          // Main button decoration
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),

          // Optional: add shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        // Scale down slightly when pressed
        transform: onPressed != null
            ? Matrix4.identity()
            : Matrix4.diagonal3Values(0.95, 0.95, 1),

        // Center the text within the container
        child: Center(
          child: Row(
            children: [
              child,
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}