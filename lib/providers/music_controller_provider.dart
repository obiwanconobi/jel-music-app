
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jel_music/controllers/music_controller.dart';



class MusicControllerProvider extends StatelessWidget {
  final Widget child;
  final MusicController? controller;

  const MusicControllerProvider({super.key,required this.child, this.controller});
  @override
  Widget build(BuildContext context) {
    final musicController = controller;
    if (musicController != null) {
      return ChangeNotifierProvider<MusicController>.value(
        value: musicController,
        child: child,
      );
    }
    return ChangeNotifierProvider<MusicController>(
      create: (context) => MusicController(),
      child: child,
    );
  }

  static MusicController of(BuildContext context, {bool listen = true}) {
    return Provider.of<MusicController>(context, listen: listen);
  }
  
}