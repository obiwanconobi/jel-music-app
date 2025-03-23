import 'package:flutter/material.dart';

class AutoScrollText extends StatefulWidget {
  final String text;

  const AutoScrollText(this.text, {super.key});

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(_scrollText);
  }

  void _scrollText() {
    if (_shouldAnimate && _scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(_animation.value * maxScroll);
    }
  }

  void _checkIfShouldAnimate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final newShouldAnimate =
            _scrollController.position.maxScrollExtent > 0;
        if (newShouldAnimate != _shouldAnimate) {
          setState(() {
            _shouldAnimate = newShouldAnimate;
          });
          if (newShouldAnimate) {
            _animationController.repeat();
          } else {
            _animationController.stop();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkIfShouldAnimate();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Text(
        widget.text,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}