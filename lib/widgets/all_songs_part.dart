import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/all_songs_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:sizer/sizer.dart';


class AllSongsPage extends StatefulWidget {
  const AllSongsPage({super.key});


  @override
  State<AllSongsPage> createState() => _AllSongsPageState();
}
 enum SortOptions { random, asc, desc, }

class _AllSongsPageState extends State<AllSongsPage> {
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  var controller = GetIt.instance<AllSongsController>();
  late Future<List<ModelSongs>> songsFuture;
  SongsHelper songsHelper = SongsHelper();
  List<ModelSongs> _filteredSongs = []; // List to hold filtered albums
  List<ModelSongs> songsList = [];
  int _currentPage = 1;
  SortOptions sortOptionsView = SortOptions.random;
 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
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

  void _loadMore()async{
        if (_scrollController.position.pixels-500 == _scrollController.position.maxScrollExtent-500) {
          setState(() {
            _currentPage++;
            _filteredSongs.addAll(songsList.sublist((_currentPage*100), ((_currentPage*100)+100)));
          });
        }
  }

   _playSong(ModelSongs song){
    MusicControllerProvider.of(context, listen: false).playSong(StreamModel(id: song.id, music: song.id, picture: song.albumPicture, composer: song.artist, title: song.title, isFavourite: song.favourite, long: song.length, bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate, codec: song.codec));
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

  _sortList(SortOptions sort){
    if(sort == SortOptions.asc){
      controller.orderByNameAsc();
    }else if(sort == SortOptions.desc){
      controller.orderByNameDesc();
    }else{
      controller.shuffleOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.artistId = artistIds;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('all_songs_title'.localise(), style: Theme.of(context).textTheme.bodyLarge),),
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
              SegmentedButton<SortOptions>(
                style: ButtonStyle(backgroundColor:  WidgetStateProperty.all<Color>(Theme.of(context).canvasColor)),
                segments: <ButtonSegment<SortOptions>>[
                   ButtonSegment<SortOptions>(
                      value: SortOptions.asc,
                      label: Text('Asc', style: Theme.of(context).textTheme.bodySmall,),
                      icon: const Icon(Icons.north)),
                  ButtonSegment<SortOptions>(
                      value: SortOptions.random,
                      label: Text('Random', style: Theme.of(context).textTheme.bodyMedium),
                      icon: const Icon(Icons.shuffle)),
                  ButtonSegment<SortOptions>(
                      value: SortOptions.desc,
                      label: Text('Desc', style: Theme.of(context).textTheme.bodySmall,),
                      icon: const Icon(Icons.south)),
                ],
                selected: <SortOptions>{sortOptionsView},
                onSelectionChanged: (Set<SortOptions> newSelection) {
                  setState(() {
                    // By default there is only a single segment that can be
                    // selected at one time, so its value is always the first
                    // item in the selected set.
                    sortOptionsView = newSelection.first;
                    _sortList(sortOptionsView);
                  });
                },
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
                      songsList = snapshot.data!.toList();
                      if(_searchController.text.isEmpty && _currentPage == 1){
                        _filteredSongs = songsList.take(100).toList();
                      }
                      return SingleChildScrollView(
                        controller: _scrollController,
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
                                        height: 60.sp,
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
                                                        child: Text(_filteredSongs[index].artist.toString(), style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.clip,),
                                                      ),
                                                    ],
                                                  ),

                                                ],
                                              ),
                                            ),
                                            Container(
                                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: IconButton(icon: Icon(Icons.favorite, color: ((_filteredSongs[index].favourite ?? false) ? Colors.red : Colors.blueGrey), size:30), onPressed: () {_favouriteSong(_filteredSongs[index].id!, _filteredSongs[index].favourite!, _filteredSongs[index].artist!, _filteredSongs[index].title!, index); },))

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

