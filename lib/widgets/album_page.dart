import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/controllers/album_controller.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/similar_artists.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:sizer/sizer.dart';
String? artistIds;

class AlbumPage extends StatefulWidget {
  AlbumPage({super.key, required this.artistId}){
    artistIds = artistId;
  }

  final String artistId;
  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  AlbumController controller = AlbumController();
  late Future<List<Album>> albumsFuture;


  @override
  void initState() {
    super.initState();
    controller.artistId = artistIds;
    albumsFuture = controller.onInit();
  }


  @override
  Widget build(BuildContext context) {
    controller.artistId = artistIds;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.background, centerTitle: true, title: Text(artistIds!, style: Theme.of(context).textTheme.bodyLarge),),
        backgroundColor: Theme.of(context).colorScheme.background,
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
                      List<Album> albumsList = snapshot.data!;
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
                                          color: Theme.of(context).colorScheme.background,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.sp),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.fromLTRB(5, 5, 5, 5),
                                              child: SizedBox(
                                                height:40.w,
                                                width: 42.w,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(4.w),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    imageUrl: albumsList[index].picture ?? "",
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
                                                            albumsList[index].title!,
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
                             Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                            alignment: Alignment.centerLeft,
                            child:  const Text('Similar Artists', style: TextStyle(color: Colors.grey, fontSize: 20))),
                           
                            SimilarArtists(artistId: artistIds!,),
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