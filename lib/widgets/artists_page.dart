import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/controllers/artist_controller.dart';
import 'package:jel_music/models/artist.dart';
import 'package:jel_music/widgets/album_page.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:sizer/sizer.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({super.key});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  ArtistController controller = ArtistController();
  double mainAxis = 250.h;

  late Future<List<Artists>> artistsFuture;

  @override
  void initState() {
    super.initState();
    artistsFuture = controller.onInit();
  }

  void launchAlbum(){

  }

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: EdgeInsets.only(left: 10.sp, bottom: 10.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                       child: Text(
                        "Artists",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "Segoe UI",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ), 
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                FutureBuilder<List<Artists>>(
                  future: artistsFuture,
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
                      List<Artists> artistController = snapshot.data!;
                      return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, mainAxisExtent: 26.h),
                    itemCount: artistController.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap:() => {
                         Navigator.push(context,
                              MaterialPageRoute(builder: (context) => AlbumPage(artistId: artistController[index].name!)),
                      )},     
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.sp),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 3.sp),
                                child: SizedBox(
                                  height: 40.w,
                                  width: 40.w,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: artistController[index].picture ?? "",
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
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Center(
                                            child: Text(
                                              artistController[index].name!,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: const Color(0xFFACACAC),
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Segoe UI",
                                                
                                              ),
                                              overflow: TextOverflow.ellipsis, // Set overflow property
                                              maxLines: 2, 
                                              textAlign: TextAlign.center,
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
        bottomSheet: const Controls()
      ),
    );
  }
}   
  