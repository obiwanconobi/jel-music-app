import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/all_albums_controller.dart';
import 'package:jel_music/controllers/latest_albums_controller.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:sizer/sizer.dart';

class LatestAlbums extends StatefulWidget {
  const LatestAlbums({super.key});

  @override
  State<LatestAlbums> createState() => _LatestAlbumsState();


}

class _LatestAlbumsState extends State<LatestAlbums> {
    @override
  void initState() {
    super.initState();
    controller.favouriteVal = true;
    albumsFuture = controller.onInit(); 
  }
  var controller = GetIt.instance<LatestAlbumsController>();
  late Future<List<Album>> albumsFuture;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Album>>(
      future: albumsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text('Offline')
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
          List<Album> albumsList = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
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
                              width: 38.w,
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
                                  Text(albumsList[index].title ?? "", overflow: TextOverflow.clip, maxLines: 1, style: Theme.of(context).textTheme.bodySmall),
                                  Text(albumsList[index].artist ?? "",  overflow: TextOverflow.clip, maxLines: 1 , style: Theme.of(context).textTheme.bodySmall)
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
          );
        }
      }
    );
  }
}