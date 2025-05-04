import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/songs_controller.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/hive/helpers/sync_helper.dart';
import 'package:jel_music/models/log.dart';
import 'package:jel_music/models/songs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DownloadController{

    SongsHelper songsHelper = SongsHelper();
    SyncHelper syncHelper = SyncHelper();
    Mappers mapper = Mappers();
    LogHandler logger = LogHandler();
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    var songs = <ModelSongs>[];
    late SongsController songsController;

  DownloadController(){
    songsController = GetIt.instance<SongsController>();
  }

  Future<List<ModelSongs>> onInit() async {
    try {
     // songs = await fetchSongs(albumId!);
     songs = await _getSongsFromBox();
      return songs;
    } catch (error) {
      // Handle errors if needed
     
      rethrow; // Rethrow the error if necessary
    }
  }

  deleteDownloadFile(String id)async{
      await syncHelper.songsHelper.openBox();
      await syncHelper.songsHelper.setDownloadedFalseForSong(id);

      var documentsDar = await getApplicationDocumentsDirectory();
      final files = Directory(p.joinAll([documentsDar.path, 'panaudio/cache/'])).listSync().where((element) => element.path.contains(id),);
      for(var file in files){
        await file.delete();
      }

      await syncHelper.songsHelper.closeBox();
  }

  clearDownloads()async{
      await syncHelper.songsHelper.openBox();
      await syncHelper.songsHelper.setDownloadedFalseAll();

      var documentsDar = await getApplicationDocumentsDirectory();
      final files = Directory(p.joinAll([documentsDar.path, 'panaudio/cache/'])).listSync();
      for(var file in files){
        await file.delete();
      }

      await syncHelper.songsHelper.closeBox();

  }

  syncDownloads()async{
    var documentsDar = await getApplicationDocumentsDirectory();

   // final files = Directory(p.joinAll([documentsDar.path, 'panaudio/cache/'])).listSync().where((entity) => entity.path.endsWith('.flac')).toList();

      final files = Directory(p.joinAll([documentsDar.path, 'panaudio/cache/']))
    .listSync()
    .where((entity) =>
        entity.path.endsWith('.flac') ||
        entity.path.endsWith('.mp3') ||
        entity.path.endsWith('.aac') ||
        entity.path.endsWith('.wav') ||
        entity.path.endsWith('.m4a'))
    .toList();
   /*   final files = documentsDar.listSync().where((entity) {
        return entity is File && (entity.path.endsWith('.flac') || entity.path.endsWith('.mp3') || entity.path.endsWith('.aac'));
      }).toList();
 */
    for(var file in files){
        if(file.path.endsWith('.flac') ||
        file.path.endsWith('.mp3') ||
        file.path.endsWith('.aac') ||
        file.path.endsWith('.wav') ||
        file.path.endsWith('.m4a')){
          String path = file.path;
          var first = p.joinAll([documentsDar.path, 'panaudio/cache/']);
          var second = path.replaceAll(first, '');
          var id = second.split('.').first;
          
          songsController.setDownloaded(id);
    

        }
    }
    logger.addToLog(LogModel(logType: "Log", logDateTime: DateTime.now(), logMessage: "Download Sync Complete"));

  }

  _getSongsFromBox()async{
      await songsHelper.openBox();
      var songsRaw =  await songsHelper.returnDownloadedSongs();
      var songsList = await mapper.mapListSongsFromRaw(songsRaw);
      return songsList;
  }

}