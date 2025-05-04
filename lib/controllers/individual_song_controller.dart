import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';

class IndividualSongController{
  SongsHelper helper = SongsHelper();
  Mappers mapper = Mappers();



  Future<ModelSongs> onInit(String songId)async{
    await helper.openBox();
    var song = helper.returnSongById(songId);
    var mappedSong =  mapper.convertHiveSongToModelSong(song);
    return mappedSong;
  }

}