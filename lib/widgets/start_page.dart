import 'package:flutter/material.dart';
import 'package:jel_music/widgets/all_albums_page.dart';
import 'package:jel_music/widgets/artists_page.dart';
import 'package:jel_music/widgets/favourite_albums.dart';
import 'package:jel_music/widgets/favourite_artists.dart';
import 'package:jel_music/widgets/liked_songs.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:jel_music/widgets/settings_page.dart';
import 'package:sizer/sizer.dart';

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
                  Row(
                    children: [
                      SizedBox(
                        height:20.h,
                        width: 50.w,
                        child: Card(
                          color: Theme.of(context).colorScheme.background,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.album),
                                title: Text('All Music', style: Theme.of(context).textTheme.bodySmall),
                                subtitle: Text('All your music', style: Theme.of(context).textTheme.bodySmall),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  const SizedBox(width: 8),
                                  TextButton(
                                    child: Text('ARTISTS', style: Theme.of(context).textTheme.bodySmall),
                                    onPressed: () {Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ArtistPage()),
                                      );},
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    child:  Text('ALBUMS', style: Theme.of(context).textTheme.bodySmall),
                                    onPressed: () {Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => AllAlbumsPage(favourite: false)),
                                      );},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height:20.h,
                        width: 50.w,
                        child: Card(
                          color: Theme.of(context).colorScheme.background,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.album),
                                title: Text('Liked Songs', style: Theme.of(context).textTheme.bodySmall),
                                subtitle: Text('Your liked songs', style: Theme.of(context).textTheme.bodySmall),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  TextButton(
                                    child: Text('VIEW', style: Theme.of(context).textTheme.bodySmall),
                                    onPressed: () {Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LikedSongs()),
                                      );},
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    child: Text('LISTEN', style: Theme.of(context).textTheme.bodySmall),
                                    onPressed: () {Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ArtistPage( )),
                                      );},
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                  Text('Favourite Albums', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 20)),
                  const FavouriteAlbums(),
                  Text('Favourite Artists', style: Theme.of(context).textTheme.bodySmall),
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