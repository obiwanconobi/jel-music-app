import 'package:flutter/material.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class Controls extends StatefulWidget {
  const Controls({super.key});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {


  void onInit(){

    MusicControllerProvider.of(context, listen: true).onInit();

 
  }

  // Add your music player control logic here
  void _onItemTapped(int index) {
    if(index == 0){
      MusicControllerProvider.of(context, listen: false).previousSong();
    }
    if(index == 1){
      MusicControllerProvider.of(context, listen: false).playPause(true, false);
    }
    if(index == 2){
      MusicControllerProvider.of(context, listen: false).nextSong();
    }
        
  }
  @override
  Widget build(BuildContext context) {
    onInit();
    return  SizedBox(
      height: 7.h,
      child: Column(
        children: [
          BottomNavigationBar(
                  onTap: _onItemTapped,
                  backgroundColor: const Color.fromARGB(255, 48, 46, 46),
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.skip_previous, color: Color.fromARGB(255, 255, 255, 255)),
                      label: 'Back',
                    ),
                    BottomNavigationBarItem(
                      icon: Consumer<MusicController>(
                        builder: (context, musicController, child) {
                          return Icon(
                            (musicController.isPlaying ?? false)
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          );
                        },
                      ),
                      label: 'Pause',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.skip_next, color: Color.fromARGB(255, 255, 255, 255),),
                      label: 'Next',
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}