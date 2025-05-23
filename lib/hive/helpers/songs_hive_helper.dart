import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/androidid.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:http/http.dart' as http;
import 'package:jel_music/models/log.dart';

class SongsHelper{

  late Box<Songs> songsBox;
  var accessToken = GetStorage().read('accessToken');
  var baseServerUrl = GetStorage().read('serverUrl');
  Conversions conversions = Conversions();
  LogHandler logger = LogHandler();
  AndroidId androidId = const AndroidId();

  String _ticksToTimestampString(int ticks) {
      // Ticks per second
        const int ticksPerSecond = 10000000;

        // Calculate the total seconds
        int totalSeconds = ticks ~/ ticksPerSecond;

        // Extract minutes and seconds
        int minutes = totalSeconds ~/ 60;
        int seconds = totalSeconds % 60;

        // Format the result as "mm:ss"
        String timestampString = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

        return timestampString;
      }

  List<Songs> returnAllSongs(){
    return songsBox.values.toList();
  }

  List<Songs> returnSongsFromAlbum(String artist, String album){
    return songsBox.values.where((element) => element.artist.toLowerCase() == artist.toLowerCase() && element.album.toLowerCase() == album.toLowerCase()).toList();
  }

  List<Songs> returnSongsForArtist(String artist){
    return songsBox.values.where((element) => element.artist.toLowerCase() == artist.toLowerCase()).toList();
  }

  Songs? returnSong(String artist, String title){
    return songsBox.values.where((element) => element.artist == artist && element.name == title).firstOrNull;
  }

  Songs returnSongById(String id){
    var song = songsBox.values.where((element)=>element.id == id).firstOrNull;
    return song ?? Songs(name: 'ERROR', id: 'ERROR', artist: 'ERROR', artistId: 'ERROR', album: 'ERROR', albumId: 'ERROR', index: 0, year: 1000, length: '1', playCount: 0);
  }

  returnDownloadedSongs()async{
    return songsBox.values.where((element)=>element.downloaded == true).toList();
  }

  setDownloadedFalseForSong(String id)async{
    var song = returnSongById(id);
    song.downloaded = false;
    songsBox.put(song.key, song);
  }

  setDownloadedFalseAll()async{
    var downloadedSongs = await returnDownloadedSongs();

    for(var song in downloadedSongs){
      song.downloaded = false;
      songsBox.put(song.key, song);
    }

  }

  setDownloaded(String id){
    var song = returnSongById(id);

    if((song.downloaded == null || song.downloaded == false) && song.id != "ERROR"){
      song.downloaded = true;
      songsBox.put(song.key,song);
    }
    
  }

  likeSong(String artist, String title, bool value){
      var song = returnSong(artist, title);
      song!.favourite = value;
      songsBox.put(song.key,song);
  }

  clearSongs()async{
    await songsBox.clear();
  }

  Future<void> openBox()async{
     await Hive.openBox<Songs>('songs');
     songsBox = Hive.box('songs');
  }

  updateSongPlayCount(String songId, int playCount)async{
    var song = returnSongById(songId);
    song.playCount = playCount;
    songsBox.put(song.key, song);
  }

  updateSong(Songs song)async{
    try{
      await songsBox.put(song.key, song);
    }catch(e){
      await logger.addToLog(LogModel(logType: "Error", logMessage: "Error updating song: ${song.name}", logDateTime: DateTime.now()));
    }

  }


  closeBox()async{
    await Hive.close();
  }

  Future<List<Songs>> returnSongs()async{
    return songsBox.values.toList();
  }

  returnFavouriteSongs()async{
    return songsBox.values.where((element) => element.favourite == true).toList();
  }

  returnMostPlayedSongsArtist(String artistName)async{
    var songs = songsBox.values.where((element) => element.artist == artistName).where((element) => element.playCount > 0).toList();
    songs.sort((a, b) => b.playCount.compareTo(a.playCount));
    return songs.take(100);
  }

  returnMostPlayedSongs()async{
    var songs = songsBox.values.toList();
    songs.sort((a, b) => b.playCount.compareTo(a.playCount));
    return songs.take(100);
  }

  addSongToBox(Songs song)async{
    songsBox.add(song);
  }

 bool mediaStreams(dynamic song){
    try {
      var string = song["MediaStreams"];

      var test = song["MediaStreams"][0];
      return true;
    } catch (e) {
      return false;
    }
  }

   addSongsToBox(dynamic songs)async{
    List<Songs> songsList = [];
    //var songs = await _getSongsDataRaw();

    var codec = "N/A";
    var bitrate = 0;
    var bitdepth = 0;
    double? samplerate;
    for(var song in songs["Items"]){
      var msAvailable = mediaStreams(song);

      if(msAvailable){
         bitrate = song["MediaStreams"][0]["BitRate"]~/1000 ?? 0;
         bitdepth = song["MediaStreams"][0]["BitDepth"] ?? 0;
         samplerate = song["MediaStreams"][0]["SampleRate"]/1000 ?? 0;
         codec = conversions.codecCleanup(song["MediaStreams"][0]["Codec"].toUpperCase());
      }

      var songName = song["Name"];
      if(songName.contains("�")){
        await logger.addToLog(LogModel(logType: "Error", logMessage: "Error adding song: $songName", logDateTime: DateTime.now()));
        continue;
      }


        try{
          songsList.add(Songs(id: song["Id"], name: song["Name"], artist: song["ArtistItems"][0]["Name"],
           artistId: song["ArtistItems"][0]["Id"], album: song["Album"], albumId: song["AlbumId"], 
           index: song["IndexNumber"] ?? 0, year: song["ProductionYear"] ?? 0, length: _ticksToTimestampString(song["RunTimeTicks"] ?? 0),
            favourite: song["UserData"]["IsFavorite"], discIndex: song["ParentIndexNumber"] ?? 1,
            codec: codec, bitrate: "$bitrate kpbs", bitdepth: "$bitdepth bit",
            samplerate: "$samplerate kHz", playCount: song["UserData"]["PlayCount"] ?? 0));
          print("added song " + song["Name"]);

        }catch(e){
         //log error


        }
     }
     for(var song in songsList){
      try{

        //look for element
        var element = songsBox.values.where((x) => x.id == song.id).firstOrNull;
        if(element != null){
          songsBox.put(element.key, song);
        }else{
          songsBox.add(song);
        }


      }catch(e){
        //log error

      }
       
     }

  }

  _getSongsDataRaw() async{
    var userId = await GetStorage().read('userId');
    var uuid = await androidId.getDeviceId();
    String deviceId = "PanAudio_$uuid";
      try {
          Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'X-MediaBrowser-Token': '$accessToken',
          'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="$deviceId",Version="10.8.13"'
        };
      String url = "$baseServerUrl/Users/$userId/Items?recursive=true&includeItemTypes=Audio&fields=MediaStreams&enableUserData=true&enableTotalRecordCount=true&enableImages=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
   }

}