import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/all_albums_controller.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/shared_widgets.dart';
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

class _AlbumPageState extends State<AllAlbumsPage> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  SharedWidgets sharedWidgets = SharedWidgets();
  var controller = GetIt.instance<AllAlbumsController>();
  Conversions conversions = Conversions();
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('albums_title'.localise(), style: Theme.of(context).textTheme.bodyLarge),),
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
                child: TextField(controller: _searchController, decoration: InputDecoration.collapsed(hintText: 'search'.localise(),hintStyle: Theme.of(context).textTheme.bodyMedium), style: Theme.of(context).textTheme.bodyMedium),
              ),
              Expanded(
                child: FutureBuilder<List<Album>>(
                  future: albumsFuture,
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
                        child: Text('no_albums_error'.localise()),
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
                                maxCrossAxisExtent: 60.w, // Adjust this value according to your needs
                                mainAxisSpacing: 6.w,
                                mainAxisExtent: 52.w,
                                ),
                             shrinkWrap: true,
                              itemCount: _filteredAlbums.length,
                              physics: const BouncingScrollPhysics(),
                              addAutomaticKeepAlives: true,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  child: InkWell(
                                    onTap:() => {
                                      Navigator.push(context,
                                        MaterialPageRoute(maintainState: true, builder: (context) => SongsPage(albumId: _filteredAlbums[index].title!, artistId: _filteredAlbums[index].artist!,)),
                                      )}, 
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.sp),
                                    ),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.sp),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              child: SizedBox(
                                                height:40.w,
                                                width: 40.w,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(4.w),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    imageUrl: _filteredAlbums[index].picture ?? "",
                                                    memCacheHeight: 400,
                                                    memCacheWidth: 400,
                                                      // Cache key for unique identification
                                                    cacheKey: _filteredAlbums[index].picture ?? "",
                                                    errorWidget: (context, url, error) => sharedWidgets.albumImage404(_filteredAlbums[index].artist!, _filteredAlbums[index].title!, context)
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
                                                            style: Theme.of(context).textTheme.bodyMedium,
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
              
            ],
          ),
        ),
        bottomNavigationBar: const Controls(),
      ),
    );
    
  }
}

