import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/artist_controller.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/models/artist.dart';
import 'package:jel_music/widgets/album_page.dart';
import 'package:jel_music/widgets/shared_widgets.dart';
import 'package:sizer/sizer.dart';

class FavouriteArtists extends StatefulWidget {
  const FavouriteArtists({super.key});

  @override
  State<FavouriteArtists> createState() => _FavouriteArtistsState();
}

class _FavouriteArtistsState extends State<FavouriteArtists> {
  Conversions conversions = Conversions();
    @override
  void initState() {
    super.initState();
    controller.favourite = true;
    artistsFuture = controller.onInit();
  }
  var controller = GetIt.instance<ArtistController>();
    SharedWidgets sharedWidgets = SharedWidgets();
  late final Future<List<Artists>> artistsFuture;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Artists>>(
      future: artistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text('Offline'),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('no_artists_error'.localise()),
          );
        } else {
          // Data is available, build the list
          List<Artists> artistsList = snapshot.data!;
          artistsList.shuffle();
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  height: 20.h,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: artistsList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        child: InkWell(
                          onTap:() => {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => AlbumPage(artistId: artistsList[index].name!,)),
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
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    child: SizedBox(
                                      height:15.h,
                                      width: 15.h,
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          imageUrl: artistsList[index].picture ?? "",
                                          memCacheHeight: 180,
                                          memCacheWidth: 180,
                                          placeholder: (context, url) => sharedWidgets.artistImage404(artistsList[index].name ?? "", context, Theme.of(context).textTheme.displayLarge!, 180),
                                          errorWidget: (context, url, error) => sharedWidgets.artistImage404(artistsList[index].name ?? "", context, Theme.of(context).textTheme.displayLarge!, 180),
                                        )
                                      ),
                                    ),
                                  ),
                                  Text(artistsList[index].name ?? "", style: Theme.of(context).textTheme.bodySmall)
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