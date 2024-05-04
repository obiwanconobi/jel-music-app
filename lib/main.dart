import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/album_controller.dart';
import 'package:jel_music/controllers/all_albums_controller.dart';
import 'package:jel_music/controllers/all_songs_controller.dart';
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/controllers/artist_controller.dart';
import 'package:jel_music/controllers/download_controller.dart';
import 'package:jel_music/controllers/liked_controller.dart';
import 'package:jel_music/controllers/playlist_controller.dart';
import 'package:jel_music/controllers/playlists_controller.dart';
import 'package:jel_music/controllers/songs_controller.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/homepage.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:jel_music/repos/jellyfin_repo.dart';
import 'package:sizer/sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await GetStorage.init();
  Hive.registerAdapter(SongsAdapter());
  Hive.registerAdapter(ArtistsAdapter());
  Hive.registerAdapter(AlbumsAdapter());



   //Repos
  GetIt.I.registerSingleton<JellyfinRepo>(JellyfinRepo());

   //Handlers
  GetIt.I.registerSingleton<JellyfinHandler>(JellyfinHandler());

  GetIt.I.registerSingleton<ApiController>(ApiController());
  GetIt.I.registerSingleton<AllSongsController>(AllSongsController());
  GetIt.I.registerSingleton<AllAlbumsController>(AllAlbumsController());
  GetIt.I.registerSingleton<SongsController>(SongsController());
  GetIt.I.registerSingleton<AlbumController>(AlbumController());
  GetIt.I.registerSingleton<ArtistController>(ArtistController());
  GetIt.I.registerSingleton<LikedController>(LikedController());
  GetIt.I.registerSingleton<DownloadController>(DownloadController());
  GetIt.I.registerSingleton<PlaylistsController>(PlaylistsController());
  GetIt.I.registerSingleton<PlaylistController>(PlaylistController());

 

 

  runApp(const MusicControllerProvider(
    child: MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.teal, // Your primary color for dark mode
    canvasColor:const Color.fromARGB(255, 179, 179, 179),
    focusColor: Colors.red,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey, // Use your primary color here
      accentColor: const Color.fromARGB(255, 69, 69, 69),
      backgroundColor: const Color.fromARGB(255, 204, 204, 204), // Your secondary color
    ), // Your accent color for dark mode
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'League Spartan', fontWeight: FontWeight.w600), // Text color for dark theme
      bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
      bodySmall: TextStyle(color: Colors.black, fontSize: 14),
    ),
    // Add other dark theme properties here
  );



  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.blueGrey, // Your primary color for dark mode
    canvasColor:const Color.fromARGB(255, 37, 37, 37),
    focusColor: Colors.red,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey, // Use your primary color here
      accentColor: Colors.blueGrey,
      errorColor: Colors.blueGrey,
      backgroundColor: const Color(0xFF1C1B1B), // Your secondary color
    ), // Your accent color for dark mode
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'League Spartan', fontWeight: FontWeight.w600), // Text color for dark theme
      bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
      bodySmall: TextStyle(color: Colors.white, fontSize: 14),
    ),
    iconTheme: const IconThemeData(color: Colors.blueGrey)
    // Add other dark theme properties here
  );
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1C1B1B),
    ));
    return Sizer(builder: (context, orientation, deviceType) {
      return  AdaptiveTheme(
        light: lightTheme,
        dark: darkTheme,
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
