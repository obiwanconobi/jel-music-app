import 'package:get_storage/get_storage.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/models/songs.dart';

class PanaudioMappers{

  String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
  String serverType = GetStorage().read('ServerType') ?? "ERROR";
  SongsHelper songsHelper = SongsHelper();

  PanaudioMappers(){
    songsHelper.openBox();
}

  //FIX THIS
  Future<List<Songs>> mapSongFromRaw(dynamic songs) async {
    var songsList = [];
    Conversions conversions = Conversions();
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";

    for(var playlistItems in songs){
      var song = playlistItems["song"];
      //var songId = song["Id"];
      var albumImgId = song["AlbumId"];

      var dbSong = songsHelper.returnSong(song["artist"], song["title"]);

      try{
        songsList.add(dbSong);
      }catch(e){
        //log error
      }
    }

    return convertHiveSongsToModelSongs(songsList);
  }


  Future<List<Songs>> convertHiveSongsToModelSongs(dynamic songsRaw)async{
    List<Songs> songsList = [];
    for(var song in songsRaw){
      String songId = song.albumId;
      String imgUrl = "";
      if(serverType == "Jellyfin"){
        imgUrl = "$baseServerUrl/Items/$songId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      }else if (serverType == "PanAudio"){
        imgUrl = "$baseServerUrl/api/albumArt?albumId=${song.albumId}";
      }


      songsList.add(Songs(id: song.id, trackNumber: song.index, artistId: song.artistId, title: song.name,
          artist: song.artist, albumPicture: imgUrl, album: song.album, albumId: song.albumId, length: song.length,
          favourite: song.favourite, discNumber: song.discIndex, downloaded: song.downloaded, codec: song.codec,
          bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate
      ));
    }
    songsList.sort((a, b) {
      // First compare discNumber
      int discComparison = a.discNumber!.compareTo(b.discNumber ?? 0);

      // If discNumber is the same, then compare trackNumber
      if (discComparison == 0) {
        return a.trackNumber!.compareTo(b.trackNumber ?? 0);
      } else {
        return discComparison;
      }
    });

    return songsList;
  }


  Future<List<String>> mapArtistIdsFromRaw(dynamic artists)async{
    List<String> artistsList = [];
    for(var artist in artists){
      String artistId = artist["id"];
      artistsList.add(artistId);
    }
    return artistsList;
  }

  Future<List<Album>> mapAlbumFromRaw(dynamic albums)async{
    List<Album> albumsList = [];
    for(var album in albums){
      String albumId = album["id"];
      String picture =  "$baseServerUrl/api/albumArt?albumId=$albumId";

      //  Albums? albumGot = albumHelper.returnAlbum(artist, title);
      //    var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      albumsList.add(Album(id: album["id"], title: album["title"],artist: album["artist"], year: album["year"] ?? 1900, picture: picture));

    }
    return albumsList;
  }
}