import 'package:flutter/material.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/songs_controller.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:sizer/sizer.dart';
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
  late Future<List<Songs>> songsFuture;

  StreamModel returnStream(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite);
  }

  @override
  void initState() {
    super.initState();
    controller.albumId = albumIds;
    controller.artistId = artistIds;
    songsFuture = controller.onInit();
  }

  _addToQueue(Songs song){
    MusicControllerProvider.of(context, listen: false).addToQueue(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title, isFavourite: song.favourite, long: song.length));
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

  _favouriteSong(String songId, bool current){
    if(current){
      apiController.unFavouriteItem(songId);
    }else{
      apiController.favouriteItem(songId);
    }
    
    
  }

  

  @override
  Widget build(BuildContext context) {
    
    controller.albumId = albumIds;
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
                                        height: 69.sp,
                                        decoration: BoxDecoration(
                                          color: (const Color(0xFF1C1B1B)),
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
                                                                  color: const Color(0xFFACACAC),
                                                                  fontWeight: FontWeight.w300,
                                                                  fontFamily: "Segoe UI",
                                                                )),
                                                            Flexible(
                                                              child: Text(songsList[index].title!,
                                                                style: TextStyle(
                                                                  fontSize: 13.sp,
                                                                  color: const Color(0xFFACACAC),
                                                                  fontWeight: FontWeight.w300,
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
                                                            child: Text(songsList[index].length.toString(), style: TextStyle(color: Colors.white))),
                                                          Container(
                                                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                            child: IconButton(icon: Icon(Icons.favorite, color: ((songsList[index].favourite ?? false) ? Colors.red : Colors.blueGrey), size:30), onPressed: () { setState(){ } _favouriteSong(songsList[index].id!, songsList[index].favourite!); },))
                                                        ],
                                                      ),
                                                      Divider(color: Color.fromARGB(255, 65, 65, 65), indent: 40, endIndent: 40,),
                                                          
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