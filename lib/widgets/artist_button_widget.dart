import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jel_music/controllers/artist_button_controller.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/models/artist.dart';
import 'package:jel_music/widgets/album_page.dart';
import 'package:jel_music/widgets/shared_widgets.dart';
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
  SharedWidgets sharedWidgets = SharedWidgets();
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
                      return Center(
                        child: Text('no_artists_error'.localise()),
                      );
                    } else {
                      var artist = snapshot.data;
                     return SizedBox(
                        width: 50.w,
                        height: 11.w,
                        child: InkWell(
                          onTap: () => {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => AlbumPage(artistId: artist.name!,)),
                                )},
                          child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                            child: ClipOval(
                              child: CachedNetworkImage(
                               imageUrl: artist!.picture ?? "",
                               memCacheHeight: 150,
                              memCacheWidth: 150,
                                errorWidget: (context, url, error) => sharedWidgets.artistImage404(artist.name ?? "", context, Theme.of(context).textTheme.bodySmall!,11.w),
                              ),
                            ),
                          ),                                             
                           Flexible(
                                child: Text(artist.name!, style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis, // Set overflow property
                                maxLines: 2,),
                              ),
                            ],
                            ),
                        )
                  );
       }
    });
  }
}