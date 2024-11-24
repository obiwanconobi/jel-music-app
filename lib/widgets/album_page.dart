import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/album_controller.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/models/artist.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/similar_artists.dart';
import 'package:jel_music/widgets/songs_page.dart';
import 'package:sizer/sizer.dart';
import 'package:expandable_text/expandable_text.dart';
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
  late Artists artist;
  var controller = GetIt.instance<AlbumController>();
  var serverType = GetStorage().read('ServerType') ?? "ERROR";
  late Future<List<Album>> albumsFuture;
  late Future<Artists> artistInfo;
  bool fav = false;

  @override
  void initState() {
    super.initState();
    controller.artistId = artistIds;
    albumsFuture = controller.onInit();
    artistInfo = controller.getArtistInfo();

  }


  //Icon(Icons.favorite, color: ((controller.artistInfo.favourite ?? false) ? Colors.red : Theme.of(context).colorScheme.secondary), size:30),)

  playAll()async{
    MusicControllerProvider.of(context, listen: false).playAllSongsFromArtist(artistIds!);
  }

  _toggleFavourite(String artistId)async{
    var current = controller.artistInfo.favourite;
    await controller.toggleArtistFavourite(artistId, current!);
    setState(() {
     // artist.favourite;
      artist.favourite = !artist.favourite!;
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.artistId = artistIds;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(artistIds!, style: Theme.of(context).textTheme.bodyLarge),),
        body: Padding(
          padding: EdgeInsets.only(
            top: 0.h,
            left: 0.sp,
            bottom: 10.sp,
            right: 0.sp,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<Artists>(
                          future: artistInfo,
                          builder: (context, snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
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
                                    artist = snapshot.data!;
                                    fav = artist.favourite ?? false;
                                    return Column(mainAxisSize: MainAxisSize.min,children: 
                                    [
                                      FutureBuilder<List<Album>>(
                  future: albumsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        //child: CircularProgressIndicator(),
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
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(onPressed:()=>{_toggleFavourite(artist.id!)}, icon: Icon(Icons.favorite, color: ((artist.favourite ?? false) ? Colors.red : Theme.of(context).colorScheme.secondary), size:30),),
                                IconButton(onPressed:()=>{playAll()}, icon: Icon(Icons.play_circle, color: Theme.of(context).colorScheme.secondary, size:30),),
                              ],
                            ),
                          GridView.builder(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 60.w, // Adjust this value according to your needs
                              mainAxisSpacing: 6.w,
                              mainAxisExtent: 52.w,
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
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.sp),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                            child: SizedBox(
                                              height:40.w,
                                              width: 40.w,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(4.w),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.fill,
                                                  imageUrl: albumsList[index].picture ?? "",
                                                  memCacheHeight: 400,
                                                  memCacheWidth: 400,
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
                          
                        ],
                      );
                    }
                  }
                ),

                Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                          alignment: Alignment.centerLeft,
                          child:  Text('Similar Artists', style:Theme.of(context).textTheme.bodyLarge)),
                          SimilarArtists(artistId: artistIds!,),

                if(artist.overview != null)Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    color: Theme.of(context).canvasColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Set the clip behavior of the card
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    // Define the child widgets of the card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                       /*  CachedNetworkImage(
                                 imageUrl: artist.picture ?? "",
                                 memCacheHeight: 150,
                                memCacheWidth: 150,
                                errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF71B77A),
                                child: const Center(
                                  child: Text("404"),),),), */
                        // Add a container with padding that contains the card's title, text, and buttons
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Display the card's title using a font size of 24 and a dark grey color
                              Text(
                                "Biography",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              // Add a space between the title and the text
                              Container(height: 10),
                              // Display the card's text using a font size of 15 and a light grey color
                              ExpandableText(
                                              artist.overview ?? "",
                                              expandText: 'show more',
                                              collapseText: 'show less',
                                              maxLines: 4,
                                              linkColor: Colors.blue,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                              // Add a row with two buttons spaced apart and aligned to the right side of the card
                            ],
                          ),
                        ),
                        // Add a small space between the card and the next widget
                        Container(height: 5),
                      ],
                    ),
                  ),
                ),
                                       ],
                                    );
                            }}),
                
                
              ],
            ),
          ),
        ),
        bottomNavigationBar: const Controls(),
      ),
    );
    
  }
}