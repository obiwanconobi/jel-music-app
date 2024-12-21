import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/models/playback_artists.dart';

class PlaybackArtistsController{
  var handler = GetIt.instance<IHandler>(instanceName: "PanAudio");

  Mappers mapper = Mappers();
  int? currentMonth;

  Future<List<PlaybackArtists>> onInit() async {
    try {
      var curDate = DateTime(DateTime.now().year, DateTime.now().month + (currentMonth ?? 0), DateTime.now().day + 1);
      var startOfMonth = DateTime(DateTime.now().year, DateTime.now().month + (currentMonth ?? 0), 1);
      return  await fetchData(startOfMonth, curDate);
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  fetchData(DateTime oldDate, DateTime curDate)async{
    var data = await handler.getPlaybackByArtists(oldDate, curDate);
    var mappedData = mapper.convertRawToPlaybackArtists(data);
    mappedData.sort((a, b) => b.totalSeconds!.compareTo(a.totalSeconds!));
    int totalSecondsSum = mappedData.fold(0, (sum, artist) => sum + (artist.totalSeconds ?? 0));
    var artists = mappedData;
    return mappedData;
  }

  Future<List<PlaybackArtists>> changeDate(int month)async{

    var startofMonth = DateTime(2024, DateTime.now().month - month, 1);

    var oldDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    var startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return await fetchData(oldDate, startOfMonth);
  }



}