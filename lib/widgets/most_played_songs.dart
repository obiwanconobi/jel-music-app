import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/PlaybackByDaysController.dart';
import 'package:jel_music/controllers/most_played_songs_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/bar%20chart/bar_data.dart';
import 'package:jel_music/models/playback_days.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/playback_days_chart.dart';
import 'package:sizer/sizer.dart';


class MostPlayedSongs extends StatefulWidget {
  const MostPlayedSongs({super.key});

  @override
  State<MostPlayedSongs> createState() => _MostPlayedSongsState();
}

class _MostPlayedSongsState extends State<MostPlayedSongs> {
  var controller = GetIt.instance<MostPlayedSongsController>();
  var serverType = GetStorage().read('ServerType') ?? "Jellyfin";
  Mappers mapper = Mappers();
  late Future<List<ModelSongs>> songsFuture;


  @override
  void initState() {
    super.initState();
    songsFuture = controller.onInit();
  }

  _addToQueue(List<ModelSongs> songs, int index){
    var sm = mapper.returnStreamModelsList(songs);
    MusicControllerProvider.of(context, listen: false).addPlaylistToQueue(sm, index: index);
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




  @override
  Widget build(BuildContext context) {
    var songsList = controller.songs;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(centerTitle: true, title: Text('most_played_songs_title'.localise(), style: Theme.of(context).textTheme.bodyLarge),),
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
                Flexible(
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
                                          onTap:() => _addToQueue(songsList, index),
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
                                                Flexible(
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
                                                                  maxLines: 1, // Set the maximum number of lines
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(songsList[index].artist.toString(), style: Theme.of(context).textTheme.bodySmall,
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text('${'play_count'.localise()}: ${songsList[index].playCount.toString()}', style:  Theme.of(context).textTheme.bodySmall,),
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