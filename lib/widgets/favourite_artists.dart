import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/artist_controller.dart';
import 'package:jel_music/models/artist.dart';
import 'package:jel_music/widgets/album_page.dart';
import 'package:sizer/sizer.dart';

class FavouriteArtists extends StatefulWidget {
  const FavouriteArtists({super.key});

  @override
  State<FavouriteArtists> createState() => _FavouriteArtistsState();
}

class _FavouriteArtistsState extends State<FavouriteArtists> {
    @override
  void initState() {
    super.initState();
    controller.favourite = true;
    artistsFuture = controller.onInit(); 
  }
  var controller = GetIt.instance<ArtistController>();
  late Future<List<Artists>> artistsFuture;
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
          return const Center(
            child: Text('No artists available.'),
          );
        } else {
          // Data is available, build the list
          List<Artists> artistsList = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  height: 180,
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
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          imageUrl: artistsList[index].picture ?? "",
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