// lib/presentation/widgets/stroked_text.dart
import 'package:flutter/material.dart';

class StrokedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double strokeWidth;
  final Color strokeColor;

  const StrokedText({
    super.key,
    required this.text,
    required this.style,
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lớp viền (stroke)
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // Lớp chữ chính (fill)
        Text(text, style: style),
      ],
    );
  }
}