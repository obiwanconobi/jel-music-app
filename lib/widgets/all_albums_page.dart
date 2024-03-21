import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/all_albums_controller.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:sizer/sizer.dart';
bool? favouriteBool;

class AllAlbumsPage extends StatefulWidget {
  AllAlbumsPage({super.key, required this.favourite}){
    favouriteBool = favourite;
  }

  final bool favourite;
  @override
  State<AllAlbumsPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AllAlbumsPage> {
  TextEditingController _searchController = TextEditingController();
  AllAlbumsController controller = AllAlbumsController();
  late Future<List<Album>> albumsFuture;
  List<Album> _filteredAlbums = []; // List to hold filtered albums
  List<Album> albumsList = [];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.favouriteVal = favouriteBool;
    albumsFuture = controller.onInit();
    _searchController.addListener(_filterAlbums);
  }

   void _filterAlbums() {
      String searchText = _searchController.text.toLowerCase();
      setState(() {
        if (searchText.isNotEmpty) {
          _filteredAlbums = albumsList
              .where((album) => album.title!.toLowerCase().contains(searchText))
              .toList();
        } else {
          _filteredAlbums = List.from(albumsList); // Reset to original list if search text is empty
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    controller.artistId = artistIds;
    String title = "All Albums";
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.background, centerTitle: true, title: Text('albums', style: Theme.of(context).textTheme.bodyLarge),),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.only(
            top: 0.h,
            left: 5.sp,
            bottom: 10.sp,
            right: 5.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FutureBuilder<List<Album>>(
                  future: albumsFuture,
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
                      albumsList = snapshot.data!;
                      if(_searchController.text.isEmpty){
                        _filteredAlbums = albumsList;
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            GridView.builder(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 250, // Adjust this value according to your needs
                                  mainAxisSpacing: 18,
                                  mainAxisExtent: 25.h,
                                ),
                             shrinkWrap: true,
                              itemCount: _filteredAlbums.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  child: InkWell(
                                    onTap:() => {
                                      Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => SongsPage(albumId: _filteredAlbums[index].title!, artistId: _filteredAlbums[index].artist!,)),
                                      )}, 
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.sp),
                                    ),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.background,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.sp),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                              child: SizedBox(
                                                height:40.w,
                                                width: 42.w,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(4.w),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    imageUrl: _filteredAlbums[index].picture ?? "",
                                                    memCacheHeight: 180,
                                                    memCacheWidth: 180,
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
                                                  )
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Center(
                                                          child: Text(
                                                            _filteredAlbums[index].title!,
                                                            style: TextStyle(
                                                              fontSize: 13.sp,
                                                              color: Theme.of(context).textTheme.bodySmall!.color,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: "Segoe UI",
                                                            ),
                                                            overflow: TextOverflow.ellipsis, // Set overflow property
                                                            maxLines: 1, // Set the maximum number of lines
                                                          ),
                                                        ),
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
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: TextField(controller: _searchController, decoration: InputDecoration.collapsed(hintText: 'Search',hintStyle:  TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 18)), style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 18)),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const Controls(),
      ),
    );
    
  }
}

