library mini_music_visualizer;

import "package:flutter/material.dart";
import 'dart:math';

class MiniMusicVisualizer extends StatelessWidget {
  const MiniMusicVisualizer({
    Key? key,
    this.color,
    this.width,
    this.height,
    this.radius = 0,
    this.animate = false,
    this.shadows,
  }) : super(key: key);

  /// Color of bars
  final Color? color;

  /// width of visualizer widget
  final double? width;

  /// height of visualizer widget
  final double? height;

  final bool animate;
  final double radius;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final List<int> duration = [900, 800, 700, 600, 500];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(
        3,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: VisualComponent(
            curve: Curves.bounceOut,
            duration: duration[index % 5],
            color: color ?? Theme.of(context).colorScheme.secondary,
            width: width,
            height: height,
            radius: radius,
            shadows: shadows,
            animate: animate,
          ),
        ),
      ),
    );
  }
}

class VisualComponent extends StatefulWidget {
  const VisualComponent({
    Key? key,
    required this.duration,
    required this.color,
    required this.curve,
    this.width,
    this.height,
    this.radius = 0,
    this.shadows,
    this.animate = false,
  }) : super(key: key);

  final int duration;
  final Color color;
  final Curve curve;
  final double? width;
  final double? height;
  final double radius;
  final List<BoxShadow>? shadows;
  final bool animate;

  @override
  _VisualComponentState createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;
  late double width;
  late double radius;
  late double height;
  late List<BoxShadow>? shadows;

  //https://docs.flutter.dev/development/tools/sdk/release-notes/release-notes-3.0.0
  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    width = widget.width ?? 4;
    height = widget.height ?? 15;
    radius = min(widget.radius, height / 2);
    shadows = widget.shadows;
    addAnimate();
    if (widget.animate) {
      start();
    } else {
      pause();
    }
  }

  @override
  void didUpdateWidget(VisualComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        start();
      } else {
        pause();
      }
    }
  }

  void addAnimate() {
    animationController = AnimationController(
        duration: Duration(milliseconds: widget.duration), vsync: this);
    final curvedAnimation =
    CurvedAnimation(parent: animationController, curve: widget.curve);
    animation = Tween<double>(begin: 2, end: height).animate(curvedAnimation)
      ..addListener(() {
        update();
      });
  }

  void start() {
    animationController.repeat(reverse: true);
  }

  void pause() {
    animationController.stop();
    animationController.reverse();
  }

  void update() {
    _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: animation.value,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(min(radius, animation.value / 2)),
            color: widget.color,
            boxShadow: shadows,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animation.removeListener(() {});
    animation.removeStatusListener((status) {});
    animationController.stop();
    animationController.reset();
    animationController.dispose();
    super.dispose();
  }
}