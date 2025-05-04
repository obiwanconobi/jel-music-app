import 'package:get_storage/get_storage.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';

class MostPlayedSongsController{
  var songs = <ModelSongs>[];

  final int currentArtistIndex = 0;
  String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
  SongsHelper  songsHelper = SongsHelper();
  Mappers mapper = Mappers();
  Future<List<ModelSongs>> onInit() async {
    try {
      songs = await fetchSongs();
      return songs;
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  _getMostPlayedSongsFromBox()async{
    await songsHelper.openBox();
    return await songsHelper.returnMostPlayedSongs();
  }

  Future<List<ModelSongs>> fetchSongs() async{
    var songsRaw = await _getMostPlayedSongsFromBox();
    var songsList = await mapper.mapListSongsFromRaw(songsRaw);
  //  songsList.shuffle();
    return songsList;
  }
}