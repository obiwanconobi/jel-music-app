import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/playback_history.dart';

class PlaybackHistoryDayListController{
  String serverType = "";
  String baseServerUrl = "";
  late IHandler handler;
  Mappers mapper = Mappers();
  SongsHelper songsHelper = SongsHelper();
  DateTime? day;
  Future<List<PlaybackHistory>> onInit()async{
    serverType = GetStorage().read('ServerType') ?? "Jellyfin";
    baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    handler = GetIt.instance<IHandler>(instanceName: serverType);
    await songsHelper.openBox();
    if(day == null)return [];

    var datta = await fetchData(day ?? DateTime.now());
    return datta;
  }

  fetchData(DateTime day)async{
      var data = await  handler.getPlaybackForDay(day);
      if(serverType == "PanAudio"){
        var mappedData = await mapper.convertRawToPlaybackHistory(data);
        return mappedData;
      }else{
        var mappedData = await mapper.convertRawToPlaybackHistoryJellyfin(data);
        return mappedData;
      }


  }

}