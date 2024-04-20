import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';

class Mappers{

  StreamModel returnStreamModel(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite);
  }
}