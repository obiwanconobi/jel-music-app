import 'package:jel_music/handlers/panaudio_handler.dart';

class PanaudioSyncHelper{

  PanaudioHandler panaudioHandler = PanaudioHandler();
  runSync(bool check)async{
    var songs = panaudioHandler.returnSongs();
  }
}