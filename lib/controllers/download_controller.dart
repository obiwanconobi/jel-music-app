import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:jel_music/models/songs.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadController{


  downloadSingleFile(Songs song)async{

    var baseServerUrl = GetStorage().read('serverUrl');
    var accessToken = GetStorage().read('accessToken');
    var itemId = song.id;
    var artistName = song.artist;
    var songName = song.title;
    var albumName = song.album;
    var baseFileName = '$artistName-$songName.flac';

    String hardCodePath = "/storage/emulated/0/Download/panaudio/";

    String downloadUrl =  "$baseServerUrl/Items/$itemId/Download?api_key=$accessToken";
    Directory? appDocDir = await getApplicationSupportDirectory();
    String hardPath = appDocDir!.path;
    String fullHardPath = '$hardPath/panaudio/';

    if(!Directory(hardCodePath).existsSync()){
        await Directory(hardCodePath).create();
    }
  //  String appDocPath = appDocDir;
    String totalPath = '$appDocDir/panaudio/';
    try{
      final taskId = await FlutterDownloader.enqueue(
            url: downloadUrl,
            savedDir: appDocDir.path,
            fileName: baseFileName,
            saveInPublicStorage: true,
            showNotification: true, // show download progress in status bar (for Android)
            openFileFromNotification: true, // click on notification to open downloaded file (for Android)
          );
    }catch(e){
      print(e);
    }
    

    var tasks = await FlutterDownloader.loadTasks();
    List<String> names = [];

    
    if(tasks != null){
      for(var task in tasks!){
          var filename = task.filename;
          var progress = task.progress;
          var rr = task.savedDir;
          names.add(filename ?? "");
      }
    }
    
    print(names);

  }
}