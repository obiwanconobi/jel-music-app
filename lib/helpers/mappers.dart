import 'package:get_storage/get_storage.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';

class Mappers{

    Conversions conversions = Conversions();
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    String serverType = GetStorage().read('ServerType') ?? "ERROR";


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

    String getImageUrl(String albumId){
      serverType = GetStorage().read('ServerType') ?? "ERROR";
      baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
      if(serverType == "Jellyfin"){
        return "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";

      }else if (serverType == "PanAudio"){
        return "$baseServerUrl/api/albumArt?albumId=$albumId";
      }

      return "";
    }



  StreamModel returnStreamModel(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite, discNumber: song.discNumber, downloaded: song.downloaded, codec: song.codec, bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate);
  }

    Future<List<StreamModel>> convertHiveSongsToStreamModelSongs(dynamic songsRaw)async{
      List<StreamModel> songsList = [];
      for(var song in songsRaw){
        String songId = song.albumId;
        var imgUrl = getImageUrl(song.albumId);
       // var imgUrl = "$baseServerUrl/Items/$songId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";

        songsList.add(StreamModel(id: song.id, composer: song.artist, music: song.id, picture: imgUrl, title: song.name, long: song.length, isFavourite: song.favourite, discNumber: song.discIndex, downloaded: song.downloaded, codec: song.codec, bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate));

      }
      songsList.shuffle();
      return songsList;
    }

  
  Future<List<Songs>> mapListSongsFromRaw(dynamic songs)async{
    List<Songs> songsList = [];
      for(var song in songs){
      String songId = song.albumId;
      var imgUrl = getImageUrl(song.albumId);
    //  var imgUrl = "$baseServerUrl/Items/$songId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      try{
        songsList.add(Songs(id: song.id, trackNumber: song.index, artistId: song.artistId, title: song.name,
        artist: song.artist, albumPicture: imgUrl, album: song.album, albumId: song.albumId, length: song.length,
         favourite: song.favourite, codec: song.codec, bitdepth: song.bitdepth, bitrate: song.bitrate, samplerate: song.samplerate,
         downloaded: song.downloaded, playCount: song.playCount));
      }catch(e){
        //log error
      }
    } 
    return songsList;
  }

  Future<List<Album>> mapAlbumFromRaw(dynamic albums)async{
    List<Album> albumsList = [];
    for(var album in albums["Items"]){
          String albumId = album["Id"];
        //  Albums? albumGot = albumHelper.returnAlbum(artist, title);
      var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      albumsList.add(Album(id: album["Id"], title: album["Name"],artist: album["AlbumArtist"], year: album["ProductionYear"] ?? 1900, picture: imgUrl));
  
    }
    return albumsList;
  }

  Future<List<Songs>> mapSongFromRaw(dynamic songs) async {
    List<Songs> songsList = [];
    Conversions conversions = Conversions();
     String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    
    for(var song in songs){
      //var songId = song["Id"];
      var albumImgId = song["AlbumId"];
      var imgUrl = "$baseServerUrl/Items/$albumImgId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
     
       var codec = song["MediaStreams"][0]["Codec"];
      codec = conversions.codecCleanup(codec.toUpperCase());



      var bitrate = song["MediaStreams"][0]["BitRate"]~/1000;
      var bitdepth = song["MediaStreams"][0]["BitDepth"];
      var samplerate = song["MediaStreams"][0]["SampleRate"]/1000;
        try{
          songsList.add(Songs(id: song["Id"], title: song["Name"], artist: song["ArtistItems"][0]["Name"],
           artistId: song["ArtistItems"][0]["Id"], album: song["Album"], albumId: song["AlbumId"], 
           trackNumber: song["IndexNumber"] ?? 0, length: conversions.returnTicksToTimestampString(song["RunTimeTicks"] ?? 0),
            favourite: song["UserData"]["IsFavorite"], discNumber: song["ParentIndexNumber"] ?? 1,
            codec: codec, bitrate: "$bitrate kpbs", bitdepth: "$bitdepth bit",
            samplerate: "$samplerate kHz", albumPicture: imgUrl));
        }catch(e){
         //log error
        }

        try{


        //  songsList.add(Songs(id: song["Id"], title: song["Name"], artist: song["ArtistItems"][0]["Name"], artistId: song["ArtistItems"][0]["Id"], album: song["Album"], albumId: song["PlaylistItemId"], trackNumber: song["IndexNumber"] ?? 0, length: conversions.returnTicksToTimestampString(song["RunTimeTicks"] ?? 0), favourite: song["UserData"]["IsFavorite"], albumPicture: imgUrl, codec: song["MediaStreams"][0]["Codec"], bitdepth: song["MediaStreams"][0]["BitDepth"], ));
        }catch(e){
         //log error
        }
     }
     
     return songsList;
  }
}