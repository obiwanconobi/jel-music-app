import 'package:flutter/material.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';



class Test1 extends StatefulWidget {
  const Test1({super.key});

  @override
  State<Test1> createState() => _Test1State();
}

class _Test1State extends State<Test1> {
  void _onPressed(){
    StreamModel addStream = StreamModel(id: "fff", title: "song 1", composer: "artist 1", picture: "DDDD", long: "02:20");
    MusicControllerProvider.of(context, listen: false).addToQueue(addStream);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: _onPressed, child: const Text('Filled'));
  }
}