import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/providers/music_controller_provider.dart';

class MostPlayedSongsArtistController{

  var songs = <ModelSongs>[];
  Mappers mapper = Mappers();
  SongsHelper  songsHelper = SongsHelper();
  String? artistName;
  Future<List<ModelSongs>> onInit() async {
    try {
      songs = await fetchSongs();
      return songs;
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  mapSongsToStreamModels(List<ModelSongs> songs){
    return mapper.returnStreamModelsList(songs);
  }

  _getMostPlayedSongsFromBox()async{
    await songsHelper.openBox();
    return await songsHelper.returnMostPlayedSongsArtist(artistName ?? "");
  }

  Future<List<ModelSongs>> fetchSongs() async{
    var songsRaw = await _getMostPlayedSongsFromBox();
    var songsList = await mapper.mapListSongsFromRaw(songsRaw);
    //  songsList.shuffle();
    return songsList;
  }

}