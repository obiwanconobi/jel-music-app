import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/album_controller.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:sizer/sizer.dart';
String? albumIds;
String? artistIds;

class SimilarAlbums extends StatefulWidget {
  SimilarAlbums({super.key, required this.albumId, required this.artistId}){
    albumIds = albumId;
    artistIds = artistId;
  }
  final String albumId;
  final String artistId;
  @override
  State<SimilarAlbums> createState() => _SimilarAlbumsState();


}

class _SimilarAlbumsState extends State<SimilarAlbums> {

  @override
  void initState(){
    super.initState();
    controller.artistId = artistIds;
    controller.albumId = albumIds;
    albumsFuture = _loadAlbums(); 
  }
  var controller = GetIt.instance<AlbumController>();
  late Future<List<Album>> albumsFuture; 

  Future<List<Album>> _loadAlbums() async {
    try {
    final albums = await controller.returnSimilar();
    return albums; // Return albums data
  } catch (error) {
    // Handle error, e.g., show error message
    rethrow;
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Album>>(
      future: albumsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child:  Text('Offline'));
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
          List<Album> albumsList = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 30.h,
                      width: 100.w, 
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: albumsList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            child: InkWell(
                              onTap:() => {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => SongsPage(albumId: albumsList[index].title!, artistId: albumsList[index].artist!,)),
                                )}, 
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.sp),
                              ),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: (Theme.of(context).colorScheme.background),
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
                                          height:35.w,
                                          width: 37.w,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4.w),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: albumsList[index].picture ?? "",
                                              memCacheHeight: 180,
                                              memCacheWidth: 180,
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
                                      SizedBox(
                                        width:33.w,
                                        child: Column(
                                          children: [
                                            Text(albumsList[index].title!, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text(albumsList[index].artist!, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
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
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      }
    );
  }
}