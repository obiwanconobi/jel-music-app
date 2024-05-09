import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/controllers/artist_button_controller.dart';
import 'package:jel_music/models/artist.dart';
import 'package:jel_music/widgets/album_page.dart';
import 'package:sizer/sizer.dart';

String? artistIds;

class ArtistButton extends StatefulWidget {
  ArtistButton({super.key, required this.artistId}){
    artistIds = artistId;
  }

  final String artistId;


  @override
  State<ArtistButton> createState() => _ArtistButtonState();
}


class _ArtistButtonState extends State<ArtistButton> {

  ArtistButtonController controller = ArtistButtonController();
  late Future<Artists> artistsFuture;

  @override
  void initState() {
    super.initState();
    controller.artistId = artistIds!;
    artistsFuture = controller.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: artistsFuture, 
    builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        //child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: Text('No artists available.'),
                      );
                    } else {
                      var artist = snapshot.data;
                     return Container(
                        width: 30.w,
                        height: 10.w,
                        child: InkWell(
                          onTap: () => {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => AlbumPage(artistId: artist.name!,)),
                                )},
                          child: Row(children: 
                                                [
                          ClipOval(
                            child: CachedNetworkImage(
                             imageUrl: artist!.picture ?? "",
                             memCacheHeight: 150,
                            memCacheWidth: 150,
                            errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF71B77A),
                            child: const Center(
                              child: Text("404"),),),),
                          ),                                             
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(artist.name!, style: Theme.of(context).textTheme.bodyMedium),
                          ),
                                                ],
                                              ),
                        )
                  );
       }
    });
  }
}