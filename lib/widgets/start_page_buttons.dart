import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/helpers/localisation.dart';
import 'package:jel_music/models/log.dart';
import 'package:jel_music/widgets/all_albums_page.dart';
import 'package:jel_music/widgets/all_songs_part.dart';
import 'package:jel_music/widgets/artists_page.dart';
import 'package:jel_music/widgets/liked_songs.dart';
import 'package:jel_music/widgets/most_played_songs.dart';
import 'package:jel_music/widgets/playlists_page.dart';
import 'package:jel_music/widgets/stats_page.dart';
import 'package:sizer/sizer.dart';

class StartPageButtons extends StatefulWidget {
  const StartPageButtons({super.key});

  @override
  State<StartPageButtons> createState() => _StartPageButtonsState();
}

class _StartPageButtonsState extends State<StartPageButtons> {
  String serverType = GetStorage().read('ServerType') ?? "Jellyfin";
  LogHandler logger = LogHandler();
  Conversions conversions = Conversions();
  bool panAudio = false;
  bool visible = true;
  @override
  void initState() {
    if(serverType == "PanAudio" || serverType == "Jellyfin"){
      panAudio = true;
    }
    super.initState();
    setState(() {
      visible = true;
    //  logger.addToLog(LogModel(logType: "Error", logMessage: "Loading buttons from set state", logDateTime: DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          color:Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                            'artist_title'.localise(),
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
                            'albums_title'.localise(),
                            style: Theme.of(context).textTheme.bodyMedium
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: panAudio,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 45.w, // Set the desired width here
                  height: 12.w,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StatsPage()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                            child: Icon(Icons.save, color: Theme.of(context).textTheme.bodyLarge!.color, size:24)
                                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                              'statistics'.localise(),
                              style: Theme.of(context).textTheme.bodyMedium
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !panAudio,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 45.w, // Set the desired width here
                  height: 12.w,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MostPlayedSongs()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                            child: Icon(Icons.save, color: Theme.of(context).textTheme.bodyLarge!.color, size:24)
                                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                              'most_played'.localise(),
                              style: Theme.of(context).textTheme.bodyMedium
                          ),
                        ),
                      ],
                    ),
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
                            'liked_songs_title'.localise(),
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
                            'all_songs_title'.localise(),
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
                            'playlists_title'.localise(),
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

