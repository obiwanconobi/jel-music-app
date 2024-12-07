import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jel_music/controllers/album_controller.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/controllers/songs_controller.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/artist_button_widget.dart';
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
  var serverType = GetStorage().read('ServerType');
  late Future<bool> favourite;
  late Future<List<Songs>> songsFuture;
  SongsHelper songsHelper = SongsHelper();
  List<Songs> songsList = [];
  bool? fave;
  bool android = false;

  List<PopupMenuEntry<String>> playlistMenuItems = [];

  StreamModel returnStream(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite, downloaded: song.downloaded, codec: song.codec, bitdepth: song.bitdepth, bitrate: song.bitrate, samplerate: song.samplerate);
  }




  @override
  void initState(){
    super.initState();
    if(Platform.isAndroid){
      android = true;
    }
    favourite = controller.returnFavourite(artistIds!, albumIds!);
    controller.albumId = albumIds;
    controller.artistId = artistIds;
    songsFuture = controller.onInit();
    
    _loadPlaylists();
    
  }

  getFavourite()async{

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

 // _playSong(Songs song){
 //   MusicControllerProvider.of(context, listen: false).playSong(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title, isFavourite: song.favourite, long: song.length, downloaded: song.downloaded, codec: song.codec, bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate));
 // }

  _playSong(List<Songs> allSongs, index){
    if(allSongs.isNotEmpty){
      List<StreamModel> playList = [];
      for(var song in allSongs){
        playList.add(returnStream(song));
      }
      MusicControllerProvider.of(context, listen: false).addPlaylistToQueue(playList, index: index);
    }

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

  _favouriteSong(String songId, bool current, String artist, String title, int index)async{
    await songsHelper.openBox();

    if(current){
      //unfavourite
      controller.toggleFavouriteSong(songId, false);
      songsHelper.likeSong(artist, title, false);
      updateSong(index, true);
    }else{
      //favourite
      controller.toggleFavouriteSong(songId, true);
      songsHelper.likeSong(artist, title, true);
      updateSong(index, false);
    }
  }

  updateSong(int index, bool favourite){
    setState(() {
      songsList[index].favourite = !favourite;
    });

  }

  _uploadArt()async{
    final ImagePicker picker = ImagePicker();
    var response = await picker.pickImage(source: ImageSource.gallery);
    if (response == null) {
      return;
    }

   //uploadFile
   await controller.uploadArt( songsList[0].albumId!,response);
    }

  _tryGetArt(String artist, String album){
    controller.tryGetArt(songsList[0].artist!, songsList[0].album!);
  }

  _downloadAll(List<Songs> songs)async{
    for(var song in songs){
      try{
        bool dl = song.downloaded ?? false;
        if(!dl){
          await _downloadFile(song);
        }

      }catch(e){

      }
    }
  }

  _getArt()async{

  }

  extraTasks(String task)async{
    if(task == "DOWNLOAD"){
     await _downloadAll(songsList);
    }else if (task == "SHUFFLE"){
      await _addShuffledToQueue(songsList);
    }else if(task == "GETART"){
      await _tryGetArt(songsList[0].artist!, songsList[0].album!);
    }else if(task == "UPLOADART"){
      await _uploadArt();
    }
  }

  styleSongLength(String input){
    //This basically checks if the song length is in the format 00:00 or in seconds only. Needs a proper fix but who can be assed
    if(input.contains(':'))return input;

    Duration duration = Duration(seconds: int.parse(input));
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  _downloadFile(Songs song)async{
    var result = await MusicControllerProvider.of(context, listen: false).downloadSong(song.id!, song.codec!);
    String? title = song.title;
    String? artist = song.artist;
    var newSong = song;
    if(result){
            showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            maxLines: 2,
            message:
               "Download of $title by $artist Completed",
          ),
      );
      song.downloaded = true;
      var index = songsList.indexWhere((element) => element.title == title);
      setState(() {
        songsList[index] = song;
      });

    }else{
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          maxLines: 2,
          message:
          "Download of $title by $artist Failed",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.albumId = albumIds;
    songsList = controller.songs;
    return SafeArea(
      child: Scaffold(
        appBar: (android ? null : AppBar(centerTitle: true, title: Text('', style: Theme.of(context).textTheme.bodyLarge),)),
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
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: songsList[0].albumPicture ?? "",
                              memCacheHeight: 400,
                              memCacheWidth: 400,
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF71B77A),
                                child: const Center(
                                  child: Text("404"),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                                  child: Text(songsList[0].album.toString(), style: Theme.of(context).textTheme.bodyLarge),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                                      child: ArtistButton(artistId: artistIds!),
                                    ),
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
                                      Row(
                                      //  mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                            IconButton(onPressed:()=>{_favouriteAlbum(albumIds!, artistIds!, fave!)}, icon: Icon(Icons.favorite, color: (fave! ? Colors.red : Theme.of(context).colorScheme.secondary), size:40),),
                                             IconButton(onPressed:()=>{ _addAllToQueue(songsList)}, icon: Icon(Icons.play_circle_rounded, size: 40, color: Theme.of(context).primaryColor),),
                                          PopupMenuButton(
                                            icon:  Icon(
                                              Icons.more_vert,
                                              size: 40,
                                              color: Theme.of(context).colorScheme.secondary
                                            ),
                                            onSelected: (item) => setState(() => extraTasks(item!)),
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                              const PopupMenuItem(
                                                value: 'SHUFFLE',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.shuffle),
                                                    Text('Shuffle')
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'DOWNLOAD',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.download),
                                                    Text('Download')
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                enabled: (serverType == "PanAudio"),
                                                value: 'GETART',
                                                child: const Row(
                                                      children: [
                                                        Icon(Icons.download),
                                                        Text('Try Get Art')
                                                      ],
                                                    ),
                                                  ),
                                              PopupMenuItem(
                                                enabled: (serverType == "PanAudio"),
                                                value: 'UPLOADART',
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.upload),
                                                    Text('Upload Art')
                                                  ],
                                                ),
                                              ),
                                            ],),
                                          //   IconButton(onPressed:()=>{_addShuffledToQueue(songsList)}, icon: Icon(Icons.shuffle, size: 40, color: Theme.of(context).colorScheme.secondary),),
                                       //   IconButton(onPressed:()=>{_downloadAll(songsList)}, icon: Icon(Icons.download, size: 40, color: Theme.of(context).colorScheme.secondary),),
                                         
                                         // OutlinedButton(onPressed: () => _addAllToQueue(songsList), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor), child: Text('Play All', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                                        // IconButton(icon: Icon(Icons.favorite, color: ((fave ?? false) ? Colors.red : Theme.of(context).colorScheme.secondary), size:30), onPressed: () => { setState(() {fave = !fave!;}),_favouriteAlbum(albumIds!, artistIds!, snapshot.data!) },),
                                        //  OutlinedButton(onPressed: () => _addShuffledToQueue(songsList), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor), child: Text('Shuffle',style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                                        //  OutlinedButton(onPressed: () => _shuffleQueue(), child: const Text('Add queue')),
                                        ],
                                      );
                                    }
                                    }
                                    ),
                                  ],
                                ),
                               /*  Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Text(songsList[0].artist.toString(), style: Theme.of(context).textTheme.bodyMedium),
                                ), */
                    
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
                                    onTap:() => _playSong(songsList, index),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.sp),
                                    ),
                                    child: Container(
                                        height: 69.sp,
                                        decoration: BoxDecoration(
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
                                                            Text('${songsList[index].trackNumber}. ', style: Theme.of(context).textTheme.bodyMedium),
                                                            Flexible(
                                                              child: Text(songsList[index].title!,
                                                                style: Theme.of(context).textTheme.bodyMedium,
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
                                                            child: Text(styleSongLength(songsList[index].length.toString()), style:  Theme.of(context).textTheme.bodySmall)),
                                                            Container(
                                                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child: IconButton(icon: Icon(Icons.download, size: 30, color: ((songsList[index].downloaded ?? false) ? Colors.green : Colors.blueGrey)), onPressed: () { _downloadFile(songsList[index]); }),
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                                            child:PopupMenuButton<String>(
                                                              icon: const Icon(Icons.playlist_add, color: Colors.blueGrey), // Set your desired icon here
                                                              onSelected: (String value) {
                                                                _addToPlaylist(songsList[index].id!, value);
                                                              },
                                                              itemBuilder: (context) => playlistMenuItems.toList(),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                            child: IconButton(icon: Icon(Icons.favorite, color: ((songsList[index].favourite ?? false) ? Colors.red : Colors.blueGrey), size:30), onPressed: () {_favouriteSong(songsList[index].id!, songsList[index].favourite!, songsList[index].artist!, songsList[index].title!, index); },))
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