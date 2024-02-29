import 'package:flutter/material.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';

class Test2 extends StatefulWidget {
  const Test2({super.key});

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  void _onPressed(){
    StreamModel addStream = StreamModel(id: "ddd", title: "song 2", composer: "artist 2", picture: "DfffDD", long: "02:50");
    MusicControllerProvider.of(context, listen: false).addNextInQueue(addStream);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: _onPressed, child: const Text('Filledff'));
  }
}