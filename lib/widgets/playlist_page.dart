import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/playlist_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:sizer/sizer.dart';

String? playlistIds;
String? playlistNames;

class PlaylistPage extends StatefulWidget {
  PlaylistPage({super.key, required this.playlistId, required this.playlistName}){
    playlistIds = playlistId;
    playlistNames = playlistName;
  }
  
  final String playlistId;
  final String playlistName;
  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<ModelSongs> songsList = [];
  var controller = GetIt.instance<PlaylistController>();
  Mappers mapper = Mappers();
  late Future<List<ModelSongs>> songsFuture;

  @override
  void initState() {
    super.initState();
    songsList.clear();
    controller.playlistId = playlistIds!;
    songsFuture = controller.onInit();
  }

  _addToQueue(ModelSongs song){
    MusicControllerProvider.of(context, listen: false).addToQueue(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title));
  }

  _shuffle(List<ModelSongs> allSongs){
    allSongs.shuffle();
    _addAllToQueue(allSongs);
  }

  _addAllToQueue(List<ModelSongs> allSongs){
    if(allSongs.isNotEmpty){
        List<StreamModel> playList = [];
        for(var song in allSongs){
          playList.add(mapper.returnStreamModel(song));
        }
        MusicControllerProvider.of(context, listen: false).addPlaylistToQueue(playList);
    }
    
  }


  _deleteSong(String playlistSongId)async{
    await controller.deleteSongFromPlaylist(playlistSongId, playlistIds!);
    setState(() {
      int indexToRemove = songsList.indexWhere((item) => item.albumId == playlistSongId);
      if (indexToRemove != -1) {
        // Remove the item at the specified index
        songsList.removeAt(indexToRemove);
      } else {
        // Log Error
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    songsList = controller.playlistList;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(playlistNames!, style: Theme.of(context).textTheme.bodyLarge),),
        body: Padding(
          padding: EdgeInsets.only(
            top: 0.h,
            left: 16.sp,
            bottom: 10.sp,
            right: 16.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FutureBuilder<List<ModelSongs>>(
                  future: songsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        //child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('no_songs_error'.localise()),
                      );
                    } else {
                      // Data is available, build the list
                      songsList = snapshot.data!;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            /* Row(
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
                            ), */
                            Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      OutlinedButton(onPressed: () => _addAllToQueue(songsList), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor, foregroundColor: Theme.of(context).canvasColor), child: Text('play'.localise(), style: Theme.of(context).textTheme.bodySmall)),
                                      OutlinedButton(onPressed: () => _shuffle(songsList), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor, foregroundColor: Theme.of(context).canvasColor), child: Text('Shuffle', style: Theme.of(context).textTheme.bodySmall)),
                                    ],
                                  ),
                                  
                                ],
                              ),
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
                                        height: 55.sp,
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
                                                height: 35.sp,
                                                width: 35.sp,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(2.w),
                                                  child: CachedNetworkImage(
                                                    imageUrl: songsList[index].albumPicture ?? "",
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
                                                            child: Text(songsList[index].title!,
                                                              style: Theme.of(context).textTheme.bodyMedium,
                                                              overflow: TextOverflow.ellipsis, // Set overflow property
                                                              maxLines: 2, // Set the maximum number of lines
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(songsList[index].artist.toString(), style: Theme.of(context).textTheme.bodySmall,),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(icon: const Icon(Icons.delete), color: Colors.red, onPressed: () {_deleteSong(songsList[index].id!);},)
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