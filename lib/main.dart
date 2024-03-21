import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/homepage.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sizer/sizer.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';



Future<void> main() async{
   await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  ); 
 // Hive.init('/');
  await Hive.initFlutter();
  await GetStorage.init();
  Hive.registerAdapter(SongsAdapter());
  Hive.registerAdapter(ArtistsAdapter());
  Hive.registerAdapter(AlbumsAdapter());
  runApp(const MusicControllerProvider(
    child: MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.teal, // Your primary color for dark mode
    canvasColor:Color.fromARGB(255, 179, 179, 179),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey, // Use your primary color here
      accentColor: const Color.fromARGB(255, 69, 69, 69),
      backgroundColor: Color.fromARGB(255, 238, 238, 238), // Your secondary color
    ), // Your accent color for dark mode
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'League Spartan', fontWeight: FontWeight.w400), // Text color for dark theme
      bodySmall: TextStyle(color: Colors.black, fontSize: 14),
    ),
    // Add other dark theme properties here
  );



  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.blueGrey, // Your primary color for dark mode
    canvasColor:const Color.fromARGB(255, 37, 37, 37),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey, // Use your primary color here
      accentColor: Colors.blueGrey,
      errorColor: Colors.blueGrey,
      backgroundColor: const Color(0xFF1C1B1B), // Your secondary color
    ), // Your accent color for dark mode
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFACACAC), fontSize: 20, fontFamily: 'League Spartan', fontWeight: FontWeight.w400), // Text color for dark theme
      bodySmall: TextStyle(color: Color(0xFFACACAC), fontSize: 14),
    ),
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
