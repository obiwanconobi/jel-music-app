import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/lyrics_page_controller.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/providers/music_controller_provider.dart';

class LyricsPage extends StatefulWidget {
  const LyricsPage({super.key});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {

  var controller = GetIt.instance<LyricsPageController>();
  String lyricsFuture = "";
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData()async{
    controller.track = MusicControllerProvider.of(context, listen:false).currentSource?.tag.title;
    controller.artist = MusicControllerProvider.of(context, listen:false).currentSource?.tag.album;
    var test = await controller.onInit();
    setState(() {
      lyricsFuture = test;
    });

   // print(lyricsFuture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Lyrics", style: Theme.of(context).textTheme.bodyLarge),),
      body: SingleChildScrollView(child: Text(lyricsFuture))
    );
  }
}
