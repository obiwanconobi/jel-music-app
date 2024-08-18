
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jel_music/controllers/music_controller.dart';



class MusicControllerProvider extends StatelessWidget {
  final Widget child;

  const MusicControllerProvider({super.key,required this.child});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MusicController(),
      child: child,
    );
  }

  static MusicController of(BuildContext context, {bool listen = true}) {
    return Provider.of<MusicController>(context, listen: listen);
  }
  
}