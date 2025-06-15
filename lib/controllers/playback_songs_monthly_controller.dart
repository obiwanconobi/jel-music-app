import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playback_days.dart';
import 'package:jel_music/models/playback_songs_monthly.dart';

class PlaybackSongsMonthlyController{

  Mappers mapper = Mappers();
  var serverType = GetStorage().read('ServerType') ?? "Jellyfin";
  late IHandler handler;
  Future<List<PlaybackSongsMonthlyModel>> onInit() async {
    handler = GetIt.instance<IHandler>(instanceName: serverType);
    try {
      return  await fetchData(DateTime.now().add(const Duration(days: -6)), DateTime.now());
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  Future<List<PlaybackSongsMonthlyModel>> fetchData(DateTime oldDate, DateTime curDate)async{
    handler = GetIt.instance<IHandler>(instanceName: serverType);
    var data = await handler.getPlaybackSongsMonthly(oldDate, curDate);
    if(serverType == "PanAudio"){
      var mappedData = await mapper.convertRawToPlaybackSongsMonthly(data);
      return mappedData;
    }
    var mappedData = await mapper.convertRawToPlaybackSongsMonthlyJellyfin(data);
    return mappedData;

  }

  Future<List<PlaybackSongsMonthlyModel>> changeDate(int month)async{
    var currentMonthInt = DateTime.now().month - month;
    var currentMonth = currentMonthInt.toString();
    if(currentMonth.length == 1){
      currentMonth = "0$currentMonth";
    }
    var year = DateTime.now().year.toString();
    var startOfMonth = DateTime.parse("$year-$currentMonth-01");
    var EndOfMonth = DateTime.parse("$year-$currentMonth-30");




    return await fetchData(startOfMonth, EndOfMonth);
  }

}