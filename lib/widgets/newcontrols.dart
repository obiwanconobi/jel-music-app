import 'package:flutter/material.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:provider/provider.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class Controls extends StatefulWidget {
  const Controls({super.key});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  ApiController apiController = ApiController();

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

  _returnHome(){
    Navigator.popUntil(context, ModalRoute.withName('/'));
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
          color: const Color.fromARGB(255, 37, 37, 37),
          height:50,
          child:  Center(
            child: Container(
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
                    IconButton(onPressed: () => { _returnHome() }, icon: const Icon(Icons.home, color: Colors.blueGrey, size:30)),
                    IconButton(onPressed: () => { _onItemTapped(0) }, icon: const Icon(Icons.skip_previous,color: Colors.blueGrey, size:30)),
                    IconButton(onPressed: () => { _onItemTapped(1) }, icon: Icon((musicController.isPlaying ?? false) ? Icons.pause : Icons.play_arrow, color: ((musicController.isCompleted) ? Colors.grey : Colors.blueGrey), size: 30, )),
                    IconButton(onPressed: () => { _onItemTapped(2) }, icon: const Icon(Icons.skip_next, size:30, color: Colors.blueGrey)),
                    IconButton(onPressed: () => { _favouriteSong(musicController.currentSource!.tag.id, musicController.currentSource!.tag.extras["favourite"]) }, icon: Icon(Icons.favorite, color: ((musicController.currentSource!.tag.extras["favourite"]) ? Colors.red : Colors.blueGrey), size:30),)
                
                  ],
                );
                }
              ),
            ),
          ),
        ), // Your header here
        body:
         Container(
          color: const Color(0xFF1C1B1B),
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
                      ElevatedButton(onPressed: () => { _testClck() }, child: const Text('Clear')),
                      ElevatedButton(onPressed: () => _testClck(), child: const Text('Play All')),
                      ElevatedButton(onPressed: () => _shuffleSongs(), child: const Text('Shuffle')),
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
                                  Text(musicController.currentSource?.tag.title, style: const TextStyle(color: Colors.white, fontSize: 17)),
                                  Text(musicController.currentSource?.tag.album, style: const TextStyle(color: Colors.white)) 
                                ],
                              ),
                              
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