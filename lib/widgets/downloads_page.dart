import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/helpers/sync_helper.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:sizer/sizer.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});


  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final TextEditingController _searchController = TextEditingController();
  SyncHelper syncHelper = SyncHelper();
  var controller = GetIt.instance<DownloadController>();
  Mappers mapper = Mappers();
  late Future<List<ModelSongs>> songsFuture;
  List<ModelSongs> _filteredSongs = []; // List to hold filtered albums
  List<ModelSongs> songsList = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _syncDownloads();
    songsFuture = controller.onInit();
    _searchController.addListener(_filterAlbums);
  }

   void _filterAlbums() {
      String searchText = _searchController.text.toLowerCase();
      setState(() {
        if (searchText.isNotEmpty) {
          _filteredSongs = songsList
              .where((album) => album.title!.toLowerCase().contains(searchText))
              .toList();
        } else {
          _filteredSongs = List.from(songsList); // Reset to original list if search text is empty
        }
      });
  }

   _playSong(ModelSongs song){
    MusicControllerProvider.of(context, listen: false).playSong(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title, isFavourite: song.favourite, long: song.length));
  }

  _syncDownloads()async{
    await controller.syncDownloads();
  }

  _clearDownloads()async{
    controller.clearDownloads();
  }

  _deleteSong(String id)async{
    controller.deleteDownloadFile(id);
     setState(() {
      int indexToRemove = songsList.indexWhere((item) => item.id == id);
      if (indexToRemove != -1) {
        // Remove the item at the specified index
        songsList.removeAt(indexToRemove);
      } else {
        // Log Error
      }
    });
  }

  _playAll(List<ModelSongs> allSongs){
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('downloads_title'.localise(), style: Theme.of(context).textTheme.bodyLarge),),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(onPressed: () => { _playAll(songsList) }, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child:  Text('play'.localise(), style:Theme.of(context).textTheme.bodySmall)),
                                ElevatedButton(onPressed: () => { _syncDownloads() }, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child:  Text('sync'.localise(), style: Theme.of(context).textTheme.bodySmall)),
                                ElevatedButton(onPressed: () => { _clearDownloads() }, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor,), child:  Text('clear'.localise(), style: Theme.of(context).textTheme.bodySmall)),
                             
                              ],              
                            ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: TextField(controller: _searchController, decoration: InputDecoration.collapsed(hintText: 'search'.localise(),hintStyle:  Theme.of(context).textTheme.bodyMedium), style: Theme.of(context).textTheme.bodyMedium),
              ),
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
                      if(_searchController.text.isEmpty){
                        _filteredSongs = songsList;
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                             ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredSongs.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                                  child: InkWell(
                                    onTap:() => _playSong(_filteredSongs[index]),
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
                                                    imageUrl: _filteredSongs[index].albumPicture ?? "",
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
                                                            child: Text(_filteredSongs[index].title!,
                                                              style: Theme.of(context).textTheme.bodyMedium,
                                                              overflow: TextOverflow.ellipsis, // Set overflow property
                                                              maxLines: 2, // Set the maximum number of lines
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(_filteredSongs[index].artist.toString(), style: Theme.of(context).textTheme.bodySmall),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(icon: const Icon(Icons.delete), color: Colors.red, onPressed: () { _deleteSong(_filteredSongs[index].id!) ;},)
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
        bottomNavigationBar: const Controls(),
      ),
    );
    
  }
}

