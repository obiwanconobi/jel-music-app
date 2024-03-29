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
    controller.favourite = false;
    artistsFuture = controller.onInit();
  }

  void launchAlbum(){

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.background, centerTitle: true, title: Text('artists', style: Theme.of(context).textTheme.bodyLarge),),
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
                      return ListView.builder(
                   // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, mainAxisExtent: 26.h),
                    itemCount: artistController.length,
                    //shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap:() => {
                         Navigator.push(context,
                              MaterialPageRoute(builder: (context) => AlbumPage(artistId: artistController[index].name!)),
                      )},     
                        child: Container(
                          height: 15.h,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.sp),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 3.sp),
                                  child: SizedBox(
                                    height: 27.w,
                                    width: 27.w,
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
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                              child: Text(
                                                artistController[index].name!,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: Theme.of(context).textTheme.bodySmall!.color,
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
        bottomSheet: const Controls(),
      ),
    );
  }
}   
  