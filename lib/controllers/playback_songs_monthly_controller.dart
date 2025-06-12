import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playback_days.dart';
import 'package:jel_music/models/playback_songs_monthly.dart';

class PlaybackSongsMonthlyController{
  var handler = GetIt.instance<IHandler>(instanceName: "PanAudio");
  Mappers mapper = Mappers();
  Future<List<PlaybackSongsMonthlyModel>> onInit() async {
    try {
      return  await fetchData(DateTime.now().add(const Duration(days: -6)), DateTime.now());
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  fetchData(DateTime oldDate, DateTime curDate)async{
    var data = await handler.getPlaybackSongsMonthly(oldDate, curDate);
    var mappedData = mapper.convertRawToPlaybackSongsMonthly(data);
    return mappedData;
  }

  Future<List<PlaybackDays>> changeDate(int week)async{
    var days = (week * 7) - 1;
    var oldDate = DateTime.now().add(Duration( days: -(days) ));
    var curDate = DateTime.now().add(Duration( days: -(days-6)));
    return await fetchData(oldDate, curDate);
  }

}