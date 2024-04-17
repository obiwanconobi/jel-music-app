import 'package:flutter/material.dart';
import 'package:jel_music/widgets/all_albums_page.dart';
import 'package:jel_music/widgets/all_songs_part.dart';
import 'package:jel_music/widgets/artists_page.dart';
import 'package:jel_music/widgets/favourite_albums.dart';
import 'package:jel_music/widgets/favourite_artists.dart';
import 'package:jel_music/widgets/liked_songs.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/settings_page.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
  

}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    // sets theme mode to dark
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(actions: [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 15, 0), child: IconButton(icon: const Icon(Icons.settings), 
                  onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()),);}))],
                  backgroundColor: Theme.of(context).colorScheme.background, centerTitle: true, title: Text('panaudio', style: Theme.of(context).textTheme.bodyLarge),),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.only(
            top: 5.h,
            left: 0.sp,
            bottom: 10.sp,
            right: 0.sp,
          ),
          child: SingleChildScrollView(
            child: Column( 
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Column(children: 
                        [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 45.w, // Set the desired width here
                                height: 12.w,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ArtistPage()),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).canvasColor),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        child: SvgPicture.asset(
                                          'assets/svg/artist.svg',
                                          width: 24,
                                          height: 24,
                                          color: Theme.of(context).textTheme.bodyMedium!.color,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Text(
                                          'Artists',
                                          style: Theme.of(context).textTheme.bodyMedium
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 45.w, // Set the desired width here
                                height: 12.w,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AllAlbumsPage(favourite: false,)),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).canvasColor),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        child: SvgPicture.asset(
                                          'assets/svg/song.svg',
                                          width: 24,
                                          height: 24,
                                          color: Theme.of(context).textTheme.bodyMedium!.color,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Text(
                                          'Albums',
                                          style: Theme.of(context).textTheme.bodyMedium
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    
                        ],),
                        Column(children: 
                        [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                                width: 45.w, // Set the desired width here
                                height: 12.w,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LikedSongs()),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).canvasColor),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        child: Icon(Icons.favorite, size: 24, color:Theme.of(context).textTheme.bodyMedium!.color ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Text(
                                          'Liked Songs',
                                          style: Theme.of(context).textTheme.bodyMedium
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 45.w, // Set the desired width here
                                height: 12.w,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AllSongsPage()),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).canvasColor),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        child: SvgPicture.asset(
                                          'assets/svg/album.svg',
                                          width: 24,
                                          height: 24,
                                          color: Theme.of(context).textTheme.bodyMedium!.color,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Text(
                                          'All Songs',
                                          style: Theme.of(context).textTheme.bodyMedium
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],)
                    
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: Text('Favourite Albums', style: Theme.of(context).textTheme.bodyLarge,)),
                  const FavouriteAlbums(),
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: Text('Favourite Artists', style: Theme.of(context).textTheme.bodyLarge)),
                  const FavouriteArtists(),
                ],
                    ),
          )
      ),
      bottomSheet: const Controls(),
      /* floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              
            });
          },
          foregroundColor: Colors.blueGrey,
          backgroundColor: const Color.fromARGB(255, 59, 59, 59),
          child: const Icon(Icons.search),
        ),
      ), */
          )
    );
  }
}