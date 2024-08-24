import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/models/log.dart';
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

  LogHandler logger = LogHandler();

  bool visible = true;
  @override
  void initState() {
    super.initState();
    logger.openBox();
    logger.addToLog(LogModel(logType: "Error", logMessage: "Loading buttons", logDateTime: DateTime.now()));
    setState(() {
      visible = true;
      logger.addToLog(LogModel(logType: "Error", logMessage: "Loading buttons from set state", logDateTime: DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.addToLog(LogModel(logType: "Error", logMessage: "Loading from build", logDateTime: DateTime.now()));
    return Visibility(
      visible: visible,
      child: Row(
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
      )
    );
  }
}

