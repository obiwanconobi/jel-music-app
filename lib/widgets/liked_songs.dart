import 'package:flutter/material.dart';
import 'package:jel_music/controllers/liked_controller.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:sizer/sizer.dart';


class LikedSongs extends StatefulWidget {
  const LikedSongs({super.key});

  @override
  State<LikedSongs> createState() => _LikedSongsState();
}

class _LikedSongsState extends State<LikedSongs> {
  LikedController controller = LikedController();
  late Future<List<Songs>> songsFuture;

  StreamModel returnStream(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite);
  }

  @override
  void initState() {
    super.initState();
    songsFuture = controller.onInit();
  }

  _addToQueue(Songs song){
    MusicControllerProvider.of(context, listen: false).addToQueue(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title));
  }

  _shuffleQueue(){
    MusicControllerProvider.of(context, listen: false).shuffleQueue();
  }

  _addAllToQueue(List<Songs> allSongs){
    if(allSongs.isNotEmpty){
        List<StreamModel> playList = [];
        for(var song in allSongs){
          playList.add(returnStream(song));
        }
        MusicControllerProvider.of(context, listen: false).addPlaylistToQueue(playList);
    }
    
  }

  

  @override
  Widget build(BuildContext context) {
    var songsList = controller.songs;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1B1B),
        body: Padding(
          padding: EdgeInsets.only(
            top: 5.h,
            left: 16.sp,
            bottom: 10.sp,
            right: 16.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10.sp, bottom: 10.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(onPressed: () => _addAllToQueue(songsList), child: const Text('Play All')),
                              OutlinedButton(onPressed: () => _shuffleQueue(), child: const Text('Shuffle')),
                              OutlinedButton(onPressed: () => _shuffleQueue(), child: const Text('Add queue')),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Songs>>(
                  future: songsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No artists available.'),
                      );
                    } else {
                      // Data is available, build the list
                      songsList = snapshot.data!;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Image.network(
                                                        songsList[0].albumPicture ?? "",
                                                        fit: BoxFit.cover,
                                                        height: 150,
                                                        cacheHeight: 150,
                                                        cacheWidth: 150),
                                Text(songsList[0].album.toString(), style: TextStyle(
                                                                fontSize: 13.sp,
                                                                color: const Color(0xFFACACAC),
                                                                fontWeight: FontWeight.w300,
                                                                fontFamily: "Segoe UI",
                                                              ),),
                                Text(songsList[0].artist.toString(), style: TextStyle(
                                                                fontSize: 11.sp,
                                                                color: const Color(0xFFACACAC),
                                                                fontWeight: FontWeight.w300,
                                                                fontFamily: "Segoe UI",
                                                              ),),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: songsList.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                                  child: InkWell(
                                    onTap:() => _addToQueue(songsList[index]),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.sp),
                                    ),
                                    child: Container(
                                        height: 52.sp,
                                        decoration: BoxDecoration(
                                          color: (const Color(0xFF1C1B1B)),
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
                                                height: 35.sp,
                                                width: 35.sp,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(15.sp)),
                                                  child: Image.network(
                                                    songsList[index].albumPicture ?? "",
                                                    cacheHeight: 50,
                                                    cacheWidth: 50,
                                                    frameBuilder: (BuildContext context,
                                                        Widget child,
                                                        int? frame,
                                                        bool wasSynchronouslyLoaded) {
                                                      return (frame != null)
                                                          ? child
                                                          : Padding(
                                                              padding:
                                                                  EdgeInsets.all(8.sp),
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 5.sp,
                                                                color: const Color(0xFF71B77A),
                                                              ),
                                                            );
                                                    },
                                                    errorBuilder:
                                                        (context, error, stackTrace) {
                                                      return Container(
                                                        color: const Color(0xFF71B77A),
                                                        child: const Center(
                                                          child: Text("404"),
                                                        ),
                                                      );
                                                    },
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
                                                            child: Text(songsList[index].title!,
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: const Color(0xFFACACAC),
                                                                fontWeight: FontWeight.w300,
                                                                fontFamily: "Segoe UI",
                                                              ),
                                                              overflow: TextOverflow.ellipsis, // Set overflow property
                                                              maxLines: 2, // Set the maximum number of lines
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(songsList[index].artist.toString(), style: TextStyle(
                                                                  fontSize: 10.sp,
                                                                  color: const Color(0xFFACACAC),
                                                                  fontWeight: FontWeight.w300,
                                                                  fontFamily: "Segoe UI",
                                                                ),),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  }
                )

              ),
            ],
          ),
        ),
        bottomNavigationBar: const Controls()
      ),
    );
    
  }
}