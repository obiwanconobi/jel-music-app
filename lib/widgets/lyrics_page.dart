import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/lyrics_page_controller.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/models/synced_lyrics.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class LyricsPage extends StatefulWidget {
  const LyricsPage({super.key});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {

  var controller = GetIt.instance<LyricsPageController>();
  Conversions conversions = Conversions();
  Duration? currentDuration;
  String lyricsFuture = "";

  List<SyncedLyrics> syncedLyrics = [];
  bool synced = false;
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _updateLyrics(Duration currentDuration){
    for (var lyric in syncedLyrics) {
      lyric.active = false;
    }

    // Find the correct lyric to activate
    for (int i = 0; i < syncedLyrics.length; i++) {
      // Convert timestamp strings to Duration objects
      Duration currentLyricTime = conversions.parseTimeStamp(syncedLyrics[i].timeStamp!);

      // If this is the last lyric
      if (i == syncedLyrics.length - 1) {
        if (currentDuration >= currentLyricTime) {
          syncedLyrics[i].active = true;
        }
        break;
      }

      // Get next lyric timestamp
      Duration nextLyricTime = conversions.parseTimeStamp(syncedLyrics[i + 1].timeStamp!);

      // Check if current duration is between current and next timestamp
      if (currentDuration >= currentLyricTime && currentDuration < nextLyricTime) {
        syncedLyrics[i].active = true;
        break;
      }
    }

    // Trigger a rebuild if needed

  }



  setSongPosition(Duration duration){
    MusicControllerProvider.of(context, listen: false).seek(duration);
  }

  _getData()async{
    final regex = RegExp(r'^\[\d{2}:\d{2}\.\d{2}\]\s*');
    controller.track = MusicControllerProvider.of(context, listen:false).currentSource?.tag.title;
    controller.artist = MusicControllerProvider.of(context, listen:false).currentSource?.tag.album;
    var test = await controller.onInit();
    setState(() {
      if(test.startsWith("[")){
        synced = true;
        int counter = 0;
        for(var line in test.split('\n')){
          var timestamp = line.replaceRange(10,line.length, '');
          var value = line.replaceRange(0, 10, '');
          syncedLyrics.add(SyncedLyrics(index: counter, timeStamp: timestamp, value: value, active: false));
          counter++;
        }

      }
      lyricsFuture = test;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Lyrics", style: Theme.of(context).textTheme.bodyLarge),),
      body: SingleChildScrollView(child: !synced ?
    Text(lyricsFuture) :
    Consumer<MusicController>(
        builder: (context, musicController, snapshot) {
      if (musicController.currentQueue == null) {
        return const Center(
          child: Text('No artists available.'),
        );
      } else {
        return StreamBuilder<Duration>(
          stream: musicController.durationStream,
          builder: (context, snapshot){
            if(snapshot.hasData){
              currentDuration = snapshot.data;
              _updateLyrics(currentDuration!);
            }
            return SizedBox(
                height:90.h,
                child: ListView.builder(
                  itemCount: syncedLyrics.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => {setSongPosition(conversions.parseTimeStamp(syncedLyrics[index].timeStamp!))},
                      child: Text(
                        syncedLyrics[index].value!,
                        style: syncedLyrics[index].active! ? TextStyle(color: Colors.blue) : Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ));
          }
        );
      }
    }
    ))
    );
  }
}
