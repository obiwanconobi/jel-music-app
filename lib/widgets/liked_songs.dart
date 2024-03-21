import 'package:cached_network_image/cached_network_image.dart';
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
        backgroundColor: Theme.of(context).colorScheme.background,
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
                              OutlinedButton(onPressed: () => _addAllToQueue(songsList), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor, foregroundColor: Theme.of(context).canvasColor), child: Text('Play All', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                              OutlinedButton(onPressed: () => _shuffleQueue(), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child: Text('Shuffle', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                              OutlinedButton(onPressed: () => _shuffleQueue(), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child: Text('Add queue', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    CachedNetworkImage(
                                                        imageUrl: songsList[0].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                                      CachedNetworkImage(
                                                        imageUrl: songsList[1].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                                      CachedNetworkImage(
                                                        imageUrl: songsList[2].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    CachedNetworkImage(
                                                        imageUrl: songsList[3].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                                      CachedNetworkImage(
                                                        imageUrl: songsList[4].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                                      CachedNetworkImage(
                                                        imageUrl: songsList[5].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    CachedNetworkImage(
                                                        imageUrl: songsList[6].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                                      CachedNetworkImage(
                                                        imageUrl: songsList[7].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                                      CachedNetworkImage(
                                                        imageUrl: songsList[8].albumPicture ?? "",
                                                        memCacheHeight: 50,
                                                        memCacheWidth: 50,
                                                        placeholder: (context, url) => const CircularProgressIndicator(
                                                          strokeWidth: 5,
                                                          color: Color.fromARGB(255, 60, 60, 60),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF71B77A),
                                                          child: const Center(
                                                            child: Text("404"),
                                                          ),
                                                        ),
                                                      ),
                                  ],
                                ),
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
                                          color: (Theme.of(context).colorScheme.background),
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
                                                  child: CachedNetworkImage(
                                                    imageUrl: songsList[index].albumPicture ?? "",
                                                    memCacheHeight: 150,
                                                    memCacheWidth: 150,
                                                    placeholder: (context, url) => const CircularProgressIndicator(
                                                      strokeWidth: 5,
                                                      color: Color.fromARGB(255, 60, 60, 60),
                                                    ),
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
                                                            child: Text(songsList[index].title!,
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: Theme.of(context).textTheme.bodySmall!.color,
                                                                fontWeight: FontWeight.w400,
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
                                                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                                                  fontWeight: FontWeight.w400,
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