import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/models/songs.dart';

class DownloadController{

    Future<String?> _getSavedDir() async {
    /* String? externalStorageDirPath;
    externalStorageDirPath =
        (await getApplicationDocumentsDirectory()).absolute.path; */

    return "";
  }

  downloadSingleFile(Songs song)async{

    var baseServerUrl = GetStorage().read('serverUrl');
    var accessToken = GetStorage().read('accessToken');
    var itemId = song.id;
    var artistName = song.artist;
    var songName = song.title;
    var albumName = song.album;
    var baseFileName = '$artistName-$songName.flac';
    MusicController musicController = MusicController();

    String hardCodePath = "/storage/emulated/0/Download/panaudio/";

    String downloadUrl =  "$baseServerUrl/Items/$itemId/Download?api_key=$accessToken";
      
    String? savedPath = await _getSavedDir();
    String? fullSavedPath = '$savedPath/panaudio/$baseFileName';
    String? checkPath = '$savedPath/panaudio/';
    Directory ff = Directory(checkPath!);
    
    if(!ff.existsSync()){
      ff.create();
    }
    var listt = ff.listSync();

    for(var ff in listt){
     String test =  ff.uri.toFilePath();
    }

    try{
     
    }catch(e){
      print(e);
    }
    

    
    List<String> names = [];

    
   
    
    print(names);

  }
}