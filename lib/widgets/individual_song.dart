import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/individual_song_controller.dart';
import 'package:jel_music/helpers/datetime_extensions.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:sizer/sizer.dart';

class IndividualSong extends StatefulWidget {
  const IndividualSong({super.key, required this.songId, required this.playbackDate});
  final String songId;
  final DateTime playbackDate;
  @override
  State<IndividualSong> createState() => _IndividualSongState();
}

class _IndividualSongState extends State<IndividualSong> {

  late IndividualSongController controller;
  late Future<ModelSongs> songFuture;


  @override
  void initState() {
    controller = GetIt.instance<IndividualSongController>();
    songFuture = controller.onInit(widget.songId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: songFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              //child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text('no_songs_error'.localise()),
            );
          } else {
            var song = snapshot.data;
            return InkWell(
              onTap:()=>{
                Navigator.push(context,
                  MaterialPageRoute(maintainState: true, builder: (context) => SongsPage(albumId: song.album!, artistId: song.artist!,)),
                )
              },
              child: SizedBox(
                height: 12.w,
                child: Row(
                  children: [
                    SizedBox(
                     // height: 8.h,
                      width: 8.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.w),
                        child: CachedNetworkImage(
                          imageUrl: song!.albumPicture ?? "",
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
                  //  SizedBox(width: 2.w,),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 1.h, 0, 0),
                      width: 75.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                        Text(song!.title!, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text("${song!.artist!}", style: Theme.of(context).textTheme.bodySmall,maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(song!.album!, style: Theme.of(context).textTheme.bodySmall,maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text("${widget.playbackDate.hour.convertMinuteInt()}:${widget.playbackDate.minute.convertMinuteInt()}", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall,),
                      ],),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }
}