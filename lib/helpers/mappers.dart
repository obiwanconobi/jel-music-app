import 'package:get_storage/get_storage.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/stream.dart';

class Mappers{

  StreamModel returnStreamModel(Songs song){
    return StreamModel(id: song.id, composer: song.artist, music: song.id, picture: song.albumPicture, title: song.title, long: song.length, isFavourite: song.favourite, discNumber: song.discNumber, downloaded: song.downloaded, codec: song.codec, bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate);
  }

  

  Future<List<Songs>> mapSongFromRaw(dynamic songs) async {
    List<Songs> songsList = [];
    Conversions conversions = Conversions();
     String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    
    for(var song in songs["Items"]){
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