import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:provider/provider.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';

class Controls extends StatefulWidget {
  const Controls({super.key});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  ApiController apiController = ApiController();
  final Conversions _conversions = Conversions();

  void onInit(){

    MusicControllerProvider.of(context, listen: true).onInit();
 
  }

  _getQueue(){
    MusicControllerProvider.of(context, listen: false).getQueue();
  }

  // Add your music player control logic here
  _onItemTapped(int index) async{
    if(index == 0){
      MusicControllerProvider.of(context, listen: false).previousSong();
      _getQueue();
    }
    if(index == 1){
      MusicControllerProvider.of(context, listen: false).playPause(true, false);
      _getQueue();
      
    }
    if(index == 2){
      MusicControllerProvider.of(context, listen: false).nextSong();
      _getQueue();
    }

    
        
  }

  _seekSong(Duration seek){
    MusicControllerProvider.of(context, listen: false).seekInSong(seek);
  }

  _returnHome(){
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  //  Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  _favouriteSong(String itemId, bool current){
    apiController.updateFavouriteStatus(itemId, current);
    MusicControllerProvider.of(context, listen: false).updateCurrentSongFavStatus();
  }

  _shuffleSongs() async{
      MusicControllerProvider.of(context, listen:false).shuffleQueue();
    }
  void _testClck(){

  }



  @override
  Widget build(BuildContext context) {
    onInit();
    return  SolidBottomSheet(
      autoSwiped: true,
      draggableBody: true,
      elevation: 5,
      smoothness: Smoothness.high,
      //  minHeight: 40,
        headerBar: Container(
          color: Theme.of(context).canvasColor,
          height:70,
          child:  Center(
            child: Column(
              children: [
                 Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child:  Divider(
                    height: 2,
                    thickness: 5,
                    indent: 160,
                    endIndent: 160,
                    color: Theme.of(context).colorScheme.secondary
                  ),
                ),
                Container(
                decoration: const BoxDecoration(borderRadius: BorderRadius.only(
                topRight: Radius.circular(40.0),
                          //  bottomRight: Radius.circular(40.0),
                topLeft: Radius.circular(40.0),)),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                 // padding: EdgeInsets.fromLTRB(10, 10, 10, 50),
                  child: Consumer<MusicController>(
                    builder: (context, musicController, child) {
                      return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(onPressed: () => { _returnHome() }, icon:  Icon(Icons.home, color: Theme.of(context).colorScheme.secondary, size:30)),
                        IconButton(onPressed: () => { _onItemTapped(0) }, icon: Icon(Icons.skip_previous,color: Theme.of(context).colorScheme.secondary, size:30)),
                        IconButton(onPressed: () => { _onItemTapped(1) }, icon: Icon((musicController.isPlaying ?? false) ? Icons.pause : Icons.play_arrow, color: Theme.of(context).colorScheme.secondary, size: 30, )),
                        IconButton(onPressed: () => { _onItemTapped(2) }, icon: Icon(Icons.skip_next, size:30, color: Theme.of(context).colorScheme.secondary)),
                        IconButton(onPressed: () => { _favouriteSong(musicController.currentSource!.tag.id, musicController.currentSource!.tag.extras["favourite"]) }, icon: Icon(Icons.favorite, color: ((musicController.currentSource!.tag.extras["favourite"]) ? Colors.red : Theme.of(context).colorScheme.secondary), size:30),)
                    
                      ],
                    );
                    }
                  ),
                ),
              ],
            ),
          ),
        ), // Your header here
        body:
         Container(
          color: Theme.of(context).colorScheme.background,
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      ElevatedButton(onPressed: () => { _testClck() }, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child:  Text('Clear', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                      ElevatedButton(onPressed: () => _testClck(), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child:  Text('Play All', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                      ElevatedButton(onPressed: () => _shuffleSongs(), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child:  Text('Shuffle',style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                    ],),
                  ),
                  Consumer<MusicController>(
                    builder: (context, musicController, snapshot) {
                    if (musicController.currentQueue == null) {
                      return const Center(
                        child: Text('No artists available.'),
                      );
                    } else {
                          return Center(
                          child: Column(
                            children: [
                              Column(
                                children: [  
                                  Image.network(
                                    (musicController.currentSource!.tag.artUri.toString()), // this image doesn't exist
                                    fit: BoxFit.cover,
                                    height:250,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Image.asset('assets/images/album.png', height: 250),
                                      );
                                    },
                                  ),
                                  Text(musicController.currentSource?.tag.title, style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 17)),
                                  Text(musicController.currentSource?.tag.album, style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color)) 
                                ],
                              ),
                              StreamBuilder<Duration>(
                                stream: musicController.durationStream,
                                builder: (context, snapshot) {    
                                  final duration = snapshot.data ?? Duration.zero;
                                  var total = musicController.currentSource!.tag.duration;
                                  return 
                                    Column(
                                      children: [
                                        Container(
                                          width: 200,
                                          child:
                                              ProgressBar(
                                                progress: Duration(seconds: duration.inSeconds),
                                                total: musicController.currentSource!.tag.duration,
                                                onSeek: (duration) {
                                                  _seekSong(duration);
                                                 // print('User selected a new time: $duration');
                                                },
                                              ),
                                        
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(duration.inMinutes.remainder(60).toString() + ":" + duration.inSeconds.remainder(60).toString()  + " : ", style:TextStyle(color:Theme.of(context).textTheme.bodySmall!.color),),
                                            Text(musicController.currentSource!.tag.duration.inMinutes.remainder(60).toString() + ":"+ musicController.currentSource!.tag.duration.inSeconds.remainder(60).toString() , style:TextStyle(color:Theme.of(context).textTheme.bodySmall!.color)),
                                          ],
                                        )
                                      ],
                                    );
                                }                    
                              )     
                            ],
                          ),
                        );
                    }
                  } ),    
                ],
              )
            ],
          ),
        ),
      );
  }
}