import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jel_music/widgets/all_albums_page.dart';
import 'package:jel_music/widgets/all_songs_part.dart';
import 'package:jel_music/widgets/artists_page.dart';
import 'package:jel_music/widgets/downloads_page.dart';
import 'package:jel_music/widgets/liked_songs.dart';
import 'package:jel_music/widgets/playlists_page.dart';
import 'package:sizer/sizer.dart';

class StartPageButtons extends StatefulWidget {
  const StartPageButtons({super.key});

  @override
  State<StartPageButtons> createState() => _StartPageButtonsState();
}

class _StartPageButtonsState extends State<StartPageButtons> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).canvasColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
                      backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).canvasColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 45.w, // Set the desired width here
                  height: 12.w,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DownloadsPage()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).canvasColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /*Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                          child: Icon(Icons.save, color: Theme.of(context).textTheme.bodyLarge!.color, size:24)
                                        ),*/
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                              'Downloads',
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
                      backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).canvasColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
                        MaterialPageRoute(builder: (context) => const AllSongsPage()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).canvasColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 45.w, // Set the desired width here
                  height: 12.w,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PlaylistsPage()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).canvasColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
                              'Playlists',
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
        );
      }
    );
  }
}
