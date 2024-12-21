import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/playlists_controller.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/playlist_page.dart';
import 'package:sizer/sizer.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> with SingleTickerProviderStateMixin {
  var controller = GetIt.instance<PlaylistsController>();
  double mainAxis = 250.h;
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Playlists>> playlistsFuture;
  List<Playlists> _filteredPlaylists = []; // List to hold filtered albums
  List<Playlists> playlistsList  = [];
  @override
  void initState() {
    super.initState();
    playlistsFuture = controller.onInit();
    _searchController.addListener(_filterPlaylists);
  }

  void _filterPlaylists() {
      String searchText = _searchController.text.toLowerCase();
      setState(() {
        if (searchText.isNotEmpty) {
          _filteredPlaylists = _filteredPlaylists
              .where((album) => album.name!.toLowerCase().contains(searchText))
              .toList();
        } else {
          _filteredPlaylists = List.from(playlistsList); // Reset to original list if search text is empty
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('Playlists', style: Theme.of(context).textTheme.bodyLarge),),
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
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: TextField(controller: _searchController, decoration: InputDecoration.collapsed(hintText: 'Search',hintStyle:  TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 18)), style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 18)),
              ),
              Expanded(
                child:
                FutureBuilder<List<Playlists>>(
                  future: playlistsFuture,
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
                        child: Text('No playlists available.'),
                      );
                    } else {
                      // Data is available, build the list
                      
                      if(_searchController.text.isNotEmpty){
                      
                      }else{
                        _filteredPlaylists = snapshot.data!;
                      }
                      return ListView.builder(
                   // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, mainAxisExtent: 26.h),
                    itemCount: _filteredPlaylists.length,
                   // shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap:() => {
                         Navigator.push(context,
                              MaterialPageRoute(builder: (context) => PlaylistPage(playlistId: _filteredPlaylists[index].id!, playlistName: _filteredPlaylists[index].name!,)),
                      )},     
                        child: SizedBox(
                          height: 15.h,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.sp),
                            child: Row(
                              children: [
                                /* Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 3.sp),
                                  child: SizedBox(
                                    height: 27.w,
                                    width: 27.w,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: _filteredPlaylists[index].id ?? "",
                                        memCacheHeight: 150,
                                        memCacheWidth: 150,
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
                                    ),
                                  ),
                                ), */
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        child: Text(
                                          _filteredPlaylists[index].name!,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                          overflow: TextOverflow.ellipsis, // Set overflow property
                                          maxLines: 2, 
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        child: Text(
                                          _filteredPlaylists[index].runtime!,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis, // Set overflow property
                                          maxLines: 2, 
                                          textAlign: TextAlign.center,
                                        ),
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
                  );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomSheet: const Controls(),
      ),
    );
  }
}   

