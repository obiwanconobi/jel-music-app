import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/artist_controller.dart';
import 'package:jel_music/models/artist.dart';
import 'package:jel_music/widgets/album_page.dart';
import 'package:sizer/sizer.dart';
String? artistIds;

class SimilarArtists extends StatefulWidget {
  SimilarArtists({super.key, required this.artistId}){
    artistIds = artistId;
  }
  final String artistId;
  @override
  State<SimilarArtists> createState() => _SimilarArtistsState();


}

class _SimilarArtistsState extends State<SimilarArtists> {

  @override
  void initState(){
    super.initState();
    controller.artistId = artistIds;
    artistsFuture = _loadArtists(); 
  }
  var controller = GetIt.instance<ArtistController>();
  late Future<List<Artists>> artistsFuture; 

  Future<List<Artists>> _loadArtists() async {
    try {
    final artists = await controller.returnSimilar();
    return artists; // Return albums data
  } catch (error) {
    // Handle error, e.g., show error message
    rethrow;
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Artists>>(
      future: artistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child:  Text('Offline'));
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("")
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return 
              const Center(
                child: Text('No artists available.'),
              );
            
        } else {
          // Data is available, build the list
          List<Artists> artistsList = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                    alignment: Alignment.centerLeft,
                    child:  Text('Similar Artists', style:Theme.of(context).textTheme.bodyLarge)),
                Row(
                  children: [
                    SizedBox(
                      height: 22.h,
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
                                          height:35.w,
                                          width: 35.w,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: artistsList[index].picture ?? "",
                                              memCacheHeight: 400,
                                              memCacheWidth: 400,
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
                                       Text(artistsList[index].name!, overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.bodySmall),
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