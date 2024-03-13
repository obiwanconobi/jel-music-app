import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/controllers/album_controller.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/widgets/newcontrols.dart';
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
        backgroundColor: const Color(0xFF1C1B1B),
        body: Padding(
          padding: EdgeInsets.only(
            top: 5.h,
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
                            Text(albumsList[0].artist!, style: TextStyle(
                                                            fontSize: 20.sp,
                                                            color: const Color(0xFFACACAC),
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: "Segoe UI",
                                                          ),),
                            GridView.builder(
                              gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                              shrinkWrap: true,
                              itemCount: albumsList.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                                  child: InkWell(
                                    onTap:() => {
                                      Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => SongsPage(albumId: albumsList[index].id!)),
                                      )},
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.sp),
                                    ),
                                    child: Container(
                                        height: 52.sp,
                                        decoration: BoxDecoration(
                                          color: (const Color(0xFF1C1B1B)),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.sp),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.symmetric(horizontal: 13.sp),
                                              child: SizedBox(
                                                height: 90.sp,
                                                width: 90.sp,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(5.sp)),
                                                  child: CachedNetworkImage(
                                                    imageUrl: albumsList[index].picture ?? "",
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
                                                  )
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
                                                              color: const Color(0xFFACACAC),
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
            ],
          ),
        ),
        bottomNavigationBar: const Controls()
      ),
    );
    
  }
}