import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/handlers/quick_actions_handler.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/icon_gradient_color.dart';
import 'package:jel_music/widgets/lyrics_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class Controls extends StatefulWidget {
  const Controls({super.key});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  //ApiController apiController = ApiController();
 // var apiController = GetIt.instance<ApiController>();
  String serverType = GetStorage().read('ServerType') ?? "Jellyfin";
  late IHandler jellyfinHandler;
  Conversions conversions = Conversions();
  List<Color> colorList = [];

  final QuickActionsHandler _quickActionsHandler = QuickActionsHandler();
  void onInit(){
    for (var i = 0; i < 10; i++) {
      colorList.add(conversions.returnColor());
    }
    jellyfinHandler = GetIt.instance<IHandler>(instanceName: serverType);
    MusicControllerProvider.of(context, listen: true).onInit();
 
  }

  _getQueue(){
    MusicControllerProvider.of(context, listen: false).getQueue();
  }

  // Add your music player control logic here
  _onItemTapped(int index) async{
    if(index == 0){
      MusicControllerProvider.of(context, listen: false).skipToPrevious();
      _getQueue();
    }
    if(index == 1){
      MusicControllerProvider.of(context, listen: false).playPause(true, false);
      _getQueue();
      
    }
    if(index == 2){
      MusicControllerProvider.of(context, listen: false).skipToNext();
      _getQueue();
    }

    
        
  }

  _seekSong(Duration seek){
    MusicControllerProvider.of(context, listen: false).seek(seek);
  }

  _goHome()async{
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false).then((_){
      _quickActionsHandler.resetBool();
    }).catchError(onError);
  }

  void onError(){

  }

  _returnHome()async{
    await _goHome();
  //  Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  _favouriteSong(String itemId, bool current){
    jellyfinHandler.updateFavouriteStatus(itemId, !current);
    MusicControllerProvider.of(context, listen: false).updateCurrentSongFavStatus();
  }

  _clearQueue() async{
    MusicControllerProvider.of(context, listen:false).clearQueue();
  }


  _goToSong(int index){
    MusicControllerProvider.of(context, listen:false).seekSong(index);
  }


  void _changeSongOnSwipe(DragUpdateDetails details) {
    if (details.delta.dx > 20) {
      // Swipe right
      setState(() {
       MusicControllerProvider.of(context, listen: false).skipToPrevious();
      });
    } else if (details.delta.dx < -20) {
      // Swipe left
      setState(() {
        MusicControllerProvider.of(context, listen: false).skipToNext();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    onInit();
    return  SolidBottomSheet(
      canUserSwipe: MusicControllerProvider.of(context, listen: true).currentQueue?.isNotEmpty ?? false,
      maxHeight: 70.h,
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
                        IconGradientColor(color1: colorList[0],color2: colorList[1], child: IconButton(onPressed: () => { _returnHome() }, icon:  Icon(Icons.home, color: Colors.white, size:30))),
                        IconGradientColor(color1: colorList[2],color2: colorList[3],child: IconButton(onPressed: () => { _onItemTapped(0) }, icon: Icon(Icons.skip_previous,color: Colors.white, size:30))),
                        IconGradientColor(color1: colorList[4],color2: colorList[5],child: IconButton(onPressed: () => { _onItemTapped(1) }, icon: Icon((musicController.isPlaying ?? false) ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30, ))),
                        IconGradientColor(color1: colorList[6],color2: colorList[7],child: IconButton(onPressed: () => { _onItemTapped(2) }, icon: Icon(Icons.skip_next, size:30, color: Colors.white))),
                        IconGradientColor(color1: colorList[8],color2: colorList[9],child: IconButton(onPressed: () => { _favouriteSong(musicController.currentSource!.tag.id, musicController.currentSource!.tag.extras["favourite"]) }, icon: Icon(Icons.favorite, color: ((musicController.currentSource!.tag.extras["favourite"]) ? Colors.red : Colors.white), size:30),))
                    
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
         ListView(
           shrinkWrap: true,
           children: [
             Column(
               children: [
                 Consumer<MusicController>(
                   builder: (context, musicController, snapshot) {
                   if (musicController.currentQueue == null) {
                     return Center(
                       child: Text('no_songs_error'.localise()),
                     );
                   } else {
                         return Center(
                         child: Container(
                           color: Theme.of(context).scaffoldBackgroundColor,
                           child: Column(
                             children: [
                               Column(
                                 children: [
                                   GestureDetector(
                                     onHorizontalDragUpdate: (details){
                                      _changeSongOnSwipe(details);
                                    },
                                     child: CachedNetworkImage(
                                       fit: BoxFit.cover,
                                       imageUrl: musicController.currentSource!.tag.extras["pictureUrl"] ?? "",
                                       memCacheHeight: 1000,
                                       memCacheWidth: 1000,
                                       errorWidget: (context, url, error) => Container(
                                         width: 400,
                                         height: 400,
                                         color: Theme.of(context).scaffoldBackgroundColor,
                                         child: const Center(
                                           child: Text(""),
                                         ),
                                       ),
                                     ),
                                   ),
                                   Text(musicController.currentSource?.tag.title, style: Theme.of(context).textTheme.bodyMedium),
                                   Text(musicController.currentSource?.tag.album, style: Theme.of(context).textTheme.bodySmall),
                                 ],
                               ),
                               StreamBuilder<Duration>(
                                 stream: musicController.durationStream,
                                 builder: (context, snapshot) {
                                   final streamDuration = snapshot.data ?? Duration.zero;
                                   return
                                   StreamBuilder<Duration>(
                                    stream: musicController.bufferStream,
                                    builder: (context, snapshot) {
                                      final bufferDuration = snapshot.data ?? Duration.zero;
                                    return
                                     Column(
                                       children: [
                                         SizedBox(
                                           width: 200,
                                           child:
                                               ProgressBar(
                                                 baseBarColor: Theme.of(context).canvasColor,
                                                 bufferedBarColor: Colors.red,
                                                 progressBarColor: Colors.red,
                                                 buffered: Duration(seconds: bufferDuration.inSeconds),
                                                 progress: Duration(seconds: streamDuration.inSeconds),
                                                 total: musicController.currentSource!.tag.duration,
                                                 onSeek: (duration) {
                                                   _seekSong(duration);

                                                 },
                                               ),

                                         ),
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                           children: [
                                             Text(musicController.currentSource?.tag.extras["codec"], style:  Theme.of(context).textTheme.labelSmall),
                                             Text(musicController.currentSource?.tag.extras["bitrate"] + "kbps", style: Theme.of(context).textTheme.labelSmall),
                                             Text(musicController.currentSource?.tag.extras["bitdepth"] + "bit", style: Theme.of(context).textTheme.labelSmall),
                                             Text(musicController.currentSource?.tag.extras["samplerate"], style: Theme.of(context).textTheme.labelSmall),
                                           ],
                                         ),
                                         ((musicController.currentSource!.tag.extras["downloaded"]) ? Icon(Icons.download, color: Colors.green, size:30) : Icon(Icons.stream, color: Theme.of(context).canvasColor, size:30)),
                                       ],
                                     );
                                 }
                               );
                                 }
                               ),
                               Container(
                                 margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                   children: [
                                     ElevatedButton(onPressed: () => { Navigator.push(context,
                                       MaterialPageRoute(builder: (context) => LyricsPage(),)),
                                     }, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child:  Text('lyrics'.localise(), style: Theme.of(context).textTheme.bodySmall)),

                                     ElevatedButton(onPressed: () => { _clearQueue() }, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child:  Text('clear'.localise(), style: Theme.of(context).textTheme.bodySmall)),
                                 ],),
                               ),
                               ListView.builder(
                               shrinkWrap: true,
                               itemCount: musicController.playlist.length,
                               physics: const BouncingScrollPhysics(),
                               itemBuilder: (context, index) {
                                 return Padding(
                                   padding: EdgeInsets.symmetric(vertical: 8.sp),
                                   child: InkWell(
                                     onTap:() => _goToSong(index),
                                     borderRadius: BorderRadius.all(
                                       Radius.circular(10.sp),
                                     ),
                                     child: Container(
                                         height: 52.sp,
                                         decoration: BoxDecoration(
                                           borderRadius: BorderRadius.all(
                                             Radius.circular(10.sp),
                                           ),
                                         ),
                                         child: Row(
                                           children: [
                                             Padding(
                                               padding:
                                                   EdgeInsets.symmetric(horizontal: 13.sp),
                                               child: SizedBox(
                                                 height: 40.sp,
                                                 width: 40.sp,
                                                 child: ClipRRect(
                                                   borderRadius: BorderRadius.circular(2.w),
                                                   child: CachedNetworkImage(
                                                     imageUrl: musicController.playlist[index].tag.extras["pictureUrl"] ?? musicController.playlist[index].tag.artUri.toString(),
                                                     memCacheHeight: 150,
                                                     memCacheWidth: 150,
                                                     errorWidget: (context, url, error) => Container(
                                                       color: const Color(0xFF71B77A),
                                                       child: const Center(
                                                         child: Text("404"),
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             Expanded(
                                               child: Column(
                                                 mainAxisAlignment:
                                                     MainAxisAlignment.center,
                                                 crossAxisAlignment:
                                                     CrossAxisAlignment.start,
                                                 children: [
                                                   Column(
                                                     children: [
                                                       Row(
                                                         mainAxisSize: MainAxisSize.max,
                                                         mainAxisAlignment:
                                                             MainAxisAlignment.start,
                                                         children: [
                                                           Flexible(
                                                             child: Text(musicController.playlist[index].tag.title!,
                                                               style: Theme.of(context).textTheme.bodyMedium,
                                                               overflow: TextOverflow.ellipsis, // Set overflow property
                                                               maxLines: 1, // Set the maximum number of lines
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                       Container(
                                                         alignment: Alignment.centerLeft,
                                                         child: Text(musicController.playlist[index].tag.album,
                                                          style: Theme.of(context).textTheme.bodySmall,
                                                         overflow: TextOverflow.ellipsis),
                                                       ),
                                                     ],
                                                   ),
                                                 ],
                                               ),
                                             ),
                                             if(musicController.currentSource!.tag.title == musicController.playlist[index].tag.title && musicController.currentSource!.tag.album == musicController.playlist[index].tag.album)Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: Icon(Icons.music_note, color: Theme.of(context).focusColor, size:30),)
                                           ],
                                         ),
                                       ),
                                     ),
                                   );
                               },
                             ),
                             ],
                           ),
                         ),
                       );
                   }
                 } ),
               ],
             ),
           ],
         ),
      );
  }
}