import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/album_controller.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/controllers/songs_controller.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/similar_albums.dart';
import 'package:sizer/sizer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
String? albumIds;
String? artistIds;

class SongsPage extends StatefulWidget {
  SongsPage({super.key, required this.albumId, required this.artistId}){
    albumIds = albumId;
    artistIds = artistId;
  }

  final String albumId;
  final String artistId;
  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  var controller = GetIt.instance<SongsController>();
  //ApiController apiController = ApiController();
  var apiController = GetIt.instance<ApiController>();
  AlbumsHelper albumHelper = AlbumsHelper();
  var albumController = GetIt.instance<AlbumController>();
  var downloadController= GetIt.instance<DownloadController>();
  late Future<bool> favourite;
  late Future<List<Songs>> songsFuture;
  SongsHelper songsHelper = SongsHelper();
  bool? fave;

  List<PopupMenuEntry<String>> playlistMenuItems = [];

  StreamModel returnStream(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite, downloaded: song.downloaded, codec: song.codec, bitdepth: song.bitdepth, bitrate: song.bitrate, samplerate: song.samplerate);
  }




  @override
  void initState(){
    super.initState();
    favourite = controller.returnFavourite(artistIds!, albumIds!);
    controller.albumId = albumIds;
    controller.artistId = artistIds;
    songsFuture = controller.onInit();
    
    _loadPlaylists();
    
  }

  _loadPlaylists()async{
    playlistMenuItems.clear();
    var playlistsRaw = await controller.returnPlaylists();
    List<PopupMenuEntry<String>> playlistMenus = [];
      for(var playlist in playlistsRaw){
          playlistMenus.add(PopupMenuItem(
          value: playlist.id,
          child: Text(playlist.name!, style: Theme.of(context).textTheme.bodyMedium),
        ));
      }
      playlistMenuItems = playlistMenus;
    
  }

  _addToPlaylist(String songId, String playlistId)async{
      await controller.addSongToPlaylist(songId, playlistId);
  }


  _addToQueue(Songs song){
    MusicControllerProvider.of(context, listen: false).addToQueue(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title, isFavourite: song.favourite, long: song.length, downloaded: song.downloaded, codec: song.codec, bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate));
  }

  _playSong(Songs song){
    MusicControllerProvider.of(context, listen: false).playSong(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title, isFavourite: song.favourite, long: song.length, downloaded: song.downloaded, codec: song.codec, bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate));
  }


  _addShuffledToQueue(List<Songs> allSongs){
      if(allSongs.isNotEmpty){
        List<StreamModel> playList = [];
        for(var song in allSongs){
          playList.add(returnStream(song));
        }
        playList.shuffle();
        MusicControllerProvider.of(context, listen: false).addPlaylistToQueue(playList);
    }
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

  _favouriteAlbum(String albumName, String artistName, bool fave)async{
    controller.toggleFavourite(artistName, albumName, !fave);
    
    setState(() {
      favourite = controller.returnFavourite(artistIds!, albumIds!);
      fave = !fave;
    });
  }

  _favouriteSong(String songId, bool current, String artist, String title)async{
    await songsHelper.openBox();

    if(current){
      //unfavourite
      controller.toggleFavouriteSong(songId, false);
      songsHelper.likeSong(artist, title, false);
      setState(() {
        songsFuture = controller.onInit();
      });
    }else{
      //favourite
      controller.toggleFavouriteSong(songId, true);
      songsHelper.likeSong(artist, title, true);
       setState(() {
        songsFuture = controller.onInit();
      });
    }
  }

  _downloadFile(Songs song)async{
    var result = await MusicControllerProvider.of(context, listen: false).downloadSong(song.id!, song.codec!);
    String? title = song.title;
    String? artist = song.artist;
    if(result){
            showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            maxLines: 2,
            message:
               "Download of $title by $artist Completed",
          ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.albumId = albumIds;
    var songsList = controller.songs;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(foregroundColor: Theme.of(context).textTheme.bodySmall!.color, backgroundColor: Theme.of(context).colorScheme.background, centerTitle: true, title: Text(albumIds!, style: Theme.of(context).textTheme.bodyLarge),),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.only(
            top: 0.h,
            left: 0.sp,
            bottom: 10.sp,
            right: 0.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FutureBuilder<List<Songs>>(
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
                                songsList[0].albumPicture ?? "", // this image doesn't exist
                                fit: BoxFit.cover,
                                height:250,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                  //  color: Colors.amber,
                                    alignment: Alignment.center,
                                    child: Image.asset('assets/images/album.png', height: 250),
                                  );
                                },
                              ),
                                Text(songsList[0].album.toString(), style: TextStyle(
                                                                fontSize: 13.sp,
                                                                color: Theme.of(context).textTheme.bodySmall!.color,
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: "Segoe UI",
                                                              ),),
                                Text(songsList[0].artist.toString(), style: TextStyle(
                                                                fontSize: 11.sp,
                                                                color: Theme.of(context).textTheme.bodySmall!.color,
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: "Segoe UI",
                                                              ),),
                                                              Center(
                      child: 
                      FutureBuilder<bool>(
                          future: favourite,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                //child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              fave = snapshot.data ?? false;
                              return  
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(onPressed: () => _addAllToQueue(songsList), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor), child: Text('Play All', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                                    IconButton(onPressed:()=>{_favouriteAlbum(albumIds!, artistIds!, fave!)}, icon: Icon(Icons.favorite, color: ((fave!) ? Colors.red : Theme.of(context).colorScheme.secondary), size:30),),
                                   // IconButton(icon: Icon(Icons.favorite, color: ((fave ?? false) ? Colors.red : Theme.of(context).colorScheme.secondary), size:30), onPressed: () => { setState(() {fave = !fave!;}),_favouriteAlbum(albumIds!, artistIds!, snapshot.data!) },),
                                    OutlinedButton(onPressed: () => _addShuffledToQueue(songsList), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor), child: Text('Shuffle',style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                                  //  OutlinedButton(onPressed: () => _shuffleQueue(), child: const Text('Add queue')),
                                  ],
                                ),
                              ],
                            );
                          }
                          }
                          ),
                    ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            ListView.builder(
                              padding: EdgeInsets.fromLTRB(16.sp, 0, 16.sp, 0),
                              shrinkWrap: true,
                              itemCount: songsList.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                                  child: InkWell(
                                    onTap:() => _playSong(songsList[index]),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.sp),
                                    ),
                                    child: Container(
                                        height: 69.sp,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.background,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.sp),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                          children: [
                                                            Text('${songsList[index].trackNumber}. ', style: TextStyle(
                                                                  fontSize: 13.sp,
                                                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontFamily: "Segoe UI",
                                                                )),
                                                            Flexible(
                                                              child: Text(songsList[index].title!,
                                                                style: TextStyle(
                                                                  fontSize: 13.sp,
                                                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontFamily: "Segoe UI",
                                                                ),
                                                                softWrap: true,
                                                                overflow: TextOverflow.ellipsis, // Set overflow property
                                                                maxLines: 1, // Set the maximum number of lines
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      
                                                    ],
                                                  ),
                                                  Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Container(
                                                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child: Text(songsList[index].length.toString(), style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                                                            Container(
                                                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child: IconButton(icon: Icon(Icons.download, size: 30, color: ((songsList[index].downloaded ?? false) ? Colors.green : Colors.blueGrey)), onPressed: () { _downloadFile(songsList[index]); }),
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child:PopupMenuButton<String>(
                                                              color: Theme.of(context).canvasColor,
                                                              icon: const Icon(Icons.playlist_add), // Set your desired icon here
                                                              onSelected: (String value) {
                                                                _addToPlaylist(songsList[index].id!, value);
                                                              },
                                                              itemBuilder: (context) => playlistMenuItems.toList(),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                            child: IconButton(icon: Icon(Icons.favorite, color: ((songsList[index].favourite ?? false) ? Colors.red : Colors.blueGrey), size:30), onPressed: () {_favouriteSong(songsList[index].id!, songsList[index].favourite!, songsList[index].artist!, songsList[index].title!); },))
                                                        ],
                                                      ),
                                                      Divider(color: Theme.of(context).colorScheme.secondary, indent: 40, endIndent: 40,),
                                                          
                                                ],
                                              ),
                                              
                                            ),
                                            
                                          ],
                                        ),
                                        
                                      ),
                                      
                                    ),
                                    
                                  );
                              },
                            ),
                            Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                            alignment: Alignment.centerLeft,
                            child: Text('Similar Albums', style: Theme.of(context).textTheme.bodyLarge)),
                            SimilarAlbums(albumId: albumIds!, artistId: artistIds!,),
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