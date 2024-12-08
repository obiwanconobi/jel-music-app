import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playback_days.dart';

class PlaybackByDaysController{
  var handler = GetIt.instance<IHandler>(instanceName: "PanAudio");
  Mappers mapper = Mappers();
  Future<List<PlaybackDays>> onInit() async {
    try {
      return  await fetchData();
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  fetchData()async{
    var data = await handler.getPlaybackByDays();
    var mappedData = mapper.convertRawToPlaybackDays(data);
    return mappedData;
  }

}