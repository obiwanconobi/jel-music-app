import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';
import 'package:get_storage/get_storage.dart';


class LikedController {
    var songs = <Songs>[];
  
    final int currentArtistIndex = 0;
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    SongsHelper  songsHelper = SongsHelper();
    Mappers mapper = Mappers();
     Future<List<Songs>> onInit() async {
    try {
      songs = await fetchSongs();
      return songs;
    } catch (error) {
      // Handle errors if needed
     
      rethrow; // Rethrow the error if necessary
    }
  }

    _getFavouriteSongsFromBox()async{
      await songsHelper.openBox();
      return songsHelper.returnFavouriteSongs();
      }

  Future<List<Songs>> fetchSongs() async{
    var songsRaw = await _getFavouriteSongsFromBox();
   var songsList = await mapper.mapListSongsFromRaw(songsRaw);
  
    songsList.shuffle();
     return songsList;
  }

}
