import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/PlaybackByDaysController.dart';
import 'package:jel_music/controllers/album_controller.dart';
import 'package:jel_music/controllers/all_albums_controller.dart';
import 'package:jel_music/controllers/all_songs_controller.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/artist_controller.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/controllers/individual_song_controller.dart';
import 'package:jel_music/controllers/latest_albums_controller.dart';
import 'package:jel_music/controllers/liked_controller.dart';
import 'package:jel_music/controllers/log_box_controller.dart';
import 'package:jel_music/controllers/lyrics_page_controller.dart';
import 'package:jel_music/controllers/most_played_songs_artist_controller.dart';
import 'package:jel_music/controllers/most_played_songs_controller.dart';
import 'package:jel_music/controllers/playback_artists_controller.dart';
import 'package:jel_music/controllers/playback_history_day_list_controller.dart';
import 'package:jel_music/controllers/playlist_controller.dart';
import 'package:jel_music/controllers/playlists_controller.dart';
import 'package:jel_music/controllers/songs_controller.dart';
import 'package:jel_music/controllers/songs_list_item_controller.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/handlers/panaudio_handler.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/hive/classes/log.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/isynchelper.dart';
import 'package:jel_music/hive/helpers/panaudio_sync_helper.dart';
import 'package:jel_music/hive/helpers/sync_helper.dart';
import 'package:jel_music/homepage.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/repos/jellyfin_repo.dart';
import 'package:jel_music/repos/panaudio_repo.dart';
import 'package:jel_music/repos/subsonic_repo.dart';
import 'package:jel_music/themes/dark_theme.dart';
import 'package:jel_music/themes/light_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quick_actions/quick_actions.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await GetStorage.init();
  Hive.registerAdapter(SongsAdapter());
  Hive.registerAdapter(ArtistsAdapter());
  Hive.registerAdapter(AlbumsAdapter());
  Hive.registerAdapter(LogAdapter());





  GetIt.I.registerSingleton<LogHandler>(LogHandler());

   //Repos
  GetIt.I.registerSingleton<PanaudioRepo>(PanaudioRepo());
  GetIt.I.registerSingleton<SubsonicRepo>(SubsonicRepo());
  GetIt.I.registerSingleton<JellyfinRepo>(JellyfinRepo());


  //  await startup();
  var serverType = GetStorage().read('ServerType') ?? "Jellyfin";

  //SyncHelpers
  GetIt.I.registerSingleton<ISyncHelper>(
    SyncHelper(),
    instanceName: 'Jellyfin',
  );
  GetIt.I.registerSingleton<ISyncHelper>(
    PanaudioSyncHelper(),
    instanceName: 'PanAudio',
  );

  GetIt.I.registerSingleton<IHandler>(
    JellyfinHandler(),
    instanceName: 'Jellyfin',
  );

  GetIt.I.registerSingleton<IHandler>(
    PanaudioHandler(),
    instanceName: 'PanAudio',
  );

   //Handlers

  GetIt.I.registerSingleton<LogBoxController>(LogBoxController());
  GetIt.I.registerSingleton<ApiController>(ApiController());
  GetIt.I.registerSingleton<AllSongsController>(AllSongsController());
  GetIt.I.registerSingleton<AllAlbumsController>(AllAlbumsController());
  GetIt.I.registerSingleton<LatestAlbumsController>(LatestAlbumsController());
  GetIt.I.registerSingleton<SongsController>(SongsController());
  GetIt.I.registerSingleton<AlbumController>(AlbumController());
  GetIt.I.registerSingleton<ArtistController>(ArtistController());
  GetIt.I.registerSingleton<LikedController>(LikedController());
  GetIt.I.registerSingleton<DownloadController>(DownloadController());
  GetIt.I.registerSingleton<PlaylistsController>(PlaylistsController());
  GetIt.I.registerSingleton<PlaylistController>(PlaylistController());
  GetIt.I.registerSingleton<MostPlayedSongsController>(MostPlayedSongsController());
  GetIt.I.registerSingleton<MostPlayedSongsArtistController>(MostPlayedSongsArtistController());
  GetIt.I.registerSingleton<PlaybackByDaysController>(PlaybackByDaysController());
  GetIt.I.registerSingleton<PlaybackArtistsController>(PlaybackArtistsController());
  GetIt.I.registerSingleton<SongsListItemController>(SongsListItemController());
  GetIt.I.registerSingleton<PlaybackHistoryDayListController>(PlaybackHistoryDayListController());
  GetIt.I.registerSingleton<IndividualSongController>(IndividualSongController());
  GetIt.I.registerSingleton<LyricsPageController>(LyricsPageController());


  const QuickActions quickActions = QuickActions();
  quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
      type: 'play_liked_songs',
      localizedTitle: 'Play Liked Songs',
    ),
    const ShortcutItem(
      type: 'play_most_played',
      localizedTitle: 'Play Most Played',
    )
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MusicControllerProvider(
    child:MyApp(),
    ));
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return  AdaptiveTheme(
        light: getLightTheme(),
        dark: getDarkTheme(),
        initial: AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'panaudio',
          theme: theme,
          darkTheme: darkTheme,
          home: const MyHomePage(),
        ),
      );
    });
  } 
}  
