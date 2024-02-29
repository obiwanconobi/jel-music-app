import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/homepage.dart';
import 'package:jel_music/providers/music_controller_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async{
   await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  ); 

  await GetStorage.init();
  runApp(MusicControllerProvider(
    child: const MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1C1B1B),
    ));
    return Sizer(builder: (context, orientation, deviceType) {
      return  MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        home: MyHomePage(),
      );
    });
  } 
}  
