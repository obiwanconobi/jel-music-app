import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playback_days.dart';

class PlaybackByDaysController{

  String serverType = GetStorage().read('ServerType') ?? "Jellyfin";
  late IHandler handler;
  Mappers mapper = Mappers();
  Future<List<PlaybackDays>> onInit() async {
    handler = GetIt.instance<IHandler>(instanceName: serverType);
    try {
      return  await fetchData(DateTime.now().add(const Duration(days: -6)), DateTime.now());
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  fetchData(DateTime oldDate, DateTime curDate)async{
    handler = GetIt.instance<IHandler>(instanceName: serverType);
    serverType = GetStorage().read('ServerType') ?? "Jellyfin";
    if(serverType == "PanAudio"){
      var data = await handler.getPlaybackByDays(oldDate, curDate);
      var mappedData = mapper.convertRawToPlaybackDays(data);
      return mappedData;
    }else{
      var data = await handler.getPlaybackByDays(oldDate, curDate);
      var mappedData = mapper.convertRawToPlaybackDaysJellyfin(data, oldDate, curDate);
      return mappedData;
    }


  }

  Future<List<PlaybackDays>> changeDate(int week)async{
    var days = (week * 7) - 1;
    var oldDate = DateTime.now().add(Duration( days: -(days) ));
    var curDate = DateTime.now().add(Duration( days: -(days-6)));
    return await fetchData(oldDate, curDate);
  }

}