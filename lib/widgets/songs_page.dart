import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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
import 'package:path/path.dart' as p;
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
  SongsController controller = SongsController();
  ApiController apiController = ApiController();
  AlbumsHelper albumHelper = AlbumsHelper();
  AlbumController albumController = AlbumController();
  DownloadController downloadController = DownloadController();
  late Future<bool> favourite;
  late Future<List<Songs>> songsFuture;
  SongsHelper songsHelper = SongsHelper();
  bool? fave;

  StreamModel returnStream(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite);
  }

  _openBox()async{
     await albumHelper.openBox();
     return albumHelper.isFavourite(artistIds!, albumIds!);

  }

  @override
  void initState(){
    super.initState();
    favourite = albumController.returnFavourite(artistIds!, albumIds!);
    controller.albumId = albumIds;
    controller.artistId = artistIds;
    songsFuture = controller.onInit();
    
  }

  _addToQueue(Songs song){
    MusicControllerProvider.of(context, listen: false).addToQueue(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title, isFavourite: song.favourite, long: song.length));
  }

  _playSong(Songs song){
    MusicControllerProvider.of(context, listen: false).playSong(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title, isFavourite: song.favourite, long: song.length));
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

  _addToNextInQueue(){

  }

  _favouriteAlbum(String albumName, String artistName, bool favourite)async{
    albumController.toggleFavourite(artistName, albumName, !favourite);
    setState(() {
        favourite = !favourite;
    });
  }

  _favouriteSong(String songId, bool current, String artist, String title)async{
    await songsHelper.openBox();

    if(current){
      apiController.unFavouriteItem(songId);
      songsHelper.likeSong(artist, title, !current);
      setState(() {
        songsFuture = controller.onInit();
      });
    }else{
      apiController.favouriteItem(songId);
      songsHelper.likeSong(artist, title, !current);
       setState(() {
        songsFuture = controller.onInit();
      });
    }
  }

  _downloadFile(Songs song){
    MusicControllerProvider.of(context, listen: false).downloadSong(song.id!);

  }

  

  @override
  Widget build(BuildContext context) {
    controller.albumId = albumIds;
    var songsList = controller.songs;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.background, centerTitle: true, title: Text(albumIds!, style: Theme.of(context).textTheme.bodyLarge),),
        backgroundColor: Theme.of(context).colorScheme.background,
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
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              fave = snapshot.data;
                              return  
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(onPressed: () => _addAllToQueue(songsList), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor), child: Text('Play All', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
                                    IconButton(icon: Icon(Icons.favorite, color: ((snapshot.data ?? false) ? Colors.red : Theme.of(context).colorScheme.secondary), size:30), onPressed: () { setState(){ fave = !fave!;}_favouriteAlbum(albumIds!, artistIds!, snapshot.data!); },),
                                    OutlinedButton(onPressed: () => _shuffleQueue(), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor), child: Text('Shuffle',style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))),
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
                                                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                                            child: IconButton(icon: const Icon(Icons.add, size: 30, color: Colors.blueGrey), onPressed: () { _addToQueue(songsList[index]); }),
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
                            child:  const Text('Similar Albums', style: TextStyle(color: Colors.grey, fontSize: 20))),
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