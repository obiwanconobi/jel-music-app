import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playback_days.dart';

class PlaybackByDaysController{
  var handler = GetIt.instance<IHandler>(instanceName: "PanAudio");
  Mappers mapper = Mappers();
  Future<List<PlaybackDays>> onInit() async {
    try {
      return  await fetchData(DateTime.now().add(const Duration(days: -6)), DateTime.now());
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  fetchData(DateTime oldDate, DateTime curDate)async{
    var data = await handler.getPlaybackByDays(oldDate, curDate);
    var mappedData = mapper.convertRawToPlaybackDays(data);
    return mappedData;
  }

  Future<List<PlaybackDays>> changeDate(int week)async{
    var days = (week * 7) - 1;
    var oldDate = DateTime.now().add(Duration( days: -(days) ));
    var curDate = DateTime.now().add(Duration( days: -(days-6)));
    return await fetchData(oldDate, curDate);
  }

}