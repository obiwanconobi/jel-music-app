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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemCount: artistController.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap:() => {
                         Navigator.push(context,
                              MaterialPageRoute(builder: (context) => AlbumPage(artistId: artistController[index].id!)),
                      )},     
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.sp),
                          child: InkWell(
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
                                        height: 80.sp,
                                        width: 80.sp,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50.sp)),
                                          child: Image.network(
                                            artistController[index].picture ?? "",
                                            cacheHeight: 150,
                                            cacheWidth: 150,
                                            frameBuilder: (BuildContext context,
                                                Widget child,
                                                int? frame,
                                                bool wasSynchronouslyLoaded) {
                                              return (frame != null)
                                                  ? child
                                                  : Padding(
                                                      padding:
                                                          EdgeInsets.all(8.sp),
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 5.sp,
                                                        color: const Color(0xFF71B77A),
                                                      ),
                                                    );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: const Color(0xFF71B77A),
                                                child: const Center(
                                                  child: Text("404"),
                                                ),
                                              );
                                            },
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
                                                      fontSize: 12.sp,
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
  