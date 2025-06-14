import 'package:flutter/material.dart';
import 'package:jel_music/helpers/conversions.dart';

class IconGradientColor extends StatelessWidget {
  final Widget child;
  final Color color1;
  final Color color2;
  const IconGradientColor({super.key,required this.child,required this.color1, required this.color2});



  @override
  Widget build(BuildContext context) {
    return ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color1, color2],
          ).createShader(bounds);
        },
        child: child);
  }
}


