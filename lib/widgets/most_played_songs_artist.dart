import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/most_played_songs_artist_controller.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:sizer/sizer.dart';

String? artistName;

class MostPlayedSongsArtist extends StatefulWidget {
  MostPlayedSongsArtist({super.key, required String this.ArtistName}){
    artistName = ArtistName;
  }

  final String ArtistName;

  @override
  State<MostPlayedSongsArtist> createState() => _MostPlayedSongsArtistState();
}
var controller = GetIt.instance<MostPlayedSongsArtistController>();

class _MostPlayedSongsArtistState extends State<MostPlayedSongsArtist> {

  late Future<List<Songs>> songsFuture;
  List<Songs> songsFull = [];

  @override
  void initState() {
    super.initState();
    controller.artistName = artistName;
    songsFuture = controller.onInit();
  }

  playMostPlayedSongs(int index){
    var smList = controller.mapSongsToStreamModels(songsFull);
    MusicControllerProvider.of(context, listen: false).addPlaylistToQueue(smList, index: index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: FutureBuilder(future: songsFuture, builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            //child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No artists available.'),
          );
        } else {
          songsFull = snapshot.data!;
          List<Songs> songs = songsFull.take(5).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text('Most Played', style: Theme.of(context).textTheme.bodySmall),
              ),
              GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100.w, // Adjust this value according to your needs
                  mainAxisSpacing: 1.w,
                  mainAxisExtent: 12.w,
              ),
                shrinkWrap: true,
                itemCount: songs.length,
                physics: const BouncingScrollPhysics(),
                addAutomaticKeepAlives: true,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => {
                      //play mostplayed songs from here
                      playMostPlayedSongs(index)
                      },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${index+1}. ${songs[index].title!}", style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis,),
                        Text("${songs[index].album!}", style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
              }),
            ],
          );
        }
      }),
    );
  }
}
