import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/all_albums_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/widgets/shared_widgets.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:jel_music/widgets/start_page_buttons.dart';
import 'package:sizer/sizer.dart';

class FavouriteAlbums extends StatefulWidget {
  const FavouriteAlbums({super.key});

  @override
  State<FavouriteAlbums> createState() => _FavouriteAlbumsState();


}

class _FavouriteAlbumsState extends State<FavouriteAlbums> {

  @override
  void initState() {
    super.initState();
    controller.favouriteVal = true;
    albumsFuture = controller.onInit(); 
  }
  var controller = GetIt.instance<AllAlbumsController>();
    SharedWidgets sharedWidgets = SharedWidgets();
  late Future<List<Album>> albumsFuture;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StartPageButtons(),
        FutureBuilder<List<Album>>(
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
              return Center(
                child: Text('no_albums_error'.localise()),
              );
            } else {
              // Data is available, build the list
              List<Album> albumsList = snapshot.data!;
              albumsList.shuffle();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height:20),
                    Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text('fav_albums_title'.localise(), style: Theme.of(context).textTheme.bodyLarge,)),
                    Row(
                      children: [
                        SizedBox(
                          height: 22.h,
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
                                      width: 15.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(2.h),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                            child: SizedBox(
                                              height:15.h,
                                              width: 20.h,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(2.h),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.fill,
                                                  imageUrl: albumsList[index].picture ?? "",
                                                  memCacheHeight: 400,
                                                  memCacheWidth: 400,
                                                  //placeholder: (context, url) => sharedWidgets.albumImage404(albumsList[index].artist!, albumsList[index].title!, context),
                                                  errorWidget: (context, url, error) => sharedWidgets.albumImage404(albumsList[index].artist!, albumsList[index].title!, context)
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
                  ],
                ),
              );
            }
          }
        ),
      ],
    );
  }
}