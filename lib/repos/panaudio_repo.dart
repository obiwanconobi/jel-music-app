import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/datetime_extensions.dart';
import 'package:jel_music/models/log.dart';

class PanaudioRepo{

  String baseServerUrl = "";
  var logger = GetIt.instance<LogHandler>();

  getPlaybackForDay(DateTime day)async{
    baseServerUrl = GetStorage().read('serverUrl');
    try {

      var date = day.formatDate();

      String url = "$baseServerUrl/api/playback/playbackday?day=$date";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  getPlaybackArtists(DateTime inOldDate, DateTime inCurDate)async{
    baseServerUrl = GetStorage().read('serverUrl');
    try {

      var curDate = inCurDate.formatDate();
      var oldDate = inOldDate.formatDate();
      String url = "$baseServerUrl/api/playback/historyartists?startDate=$oldDate&endDate=$curDate";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  getPlaybackDays(DateTime inOldDate, DateTime inCurDate)async{
    baseServerUrl = GetStorage().read('serverUrl');
    try {

      var curDate = inCurDate.formatDate();
      var oldDate = inOldDate.formatDate();
      String url = "$baseServerUrl/api/playback/historydays?startDate=$oldDate&endDate=$curDate";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  tryGetArt(String artist, String album)async{
    baseServerUrl = GetStorage().read('serverUrl');
    try {
      String url = "$baseServerUrl/setalbumpicture?artistName=$artist&albumName=$album";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  getFavouriteAlbums()async{
    baseServerUrl = await GetStorage().read('serverUrl');
    try {
      String url = "$baseServerUrl/api/favourite-albums";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }
  getFavouriteArtists()async{
    baseServerUrl = await GetStorage().read('serverUrl');
    try {
      String url = "$baseServerUrl/api/favourite-artists";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  getLatestAlbums()async{
    baseServerUrl = await GetStorage().read('serverUrl');
    try {
      String url = "$baseServerUrl/api/recent-released-albums";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  getAlbumById(String albumId)async{
    baseServerUrl = await GetStorage().read('serverUrl');
    try {
      String url = "$baseServerUrl/api/songs";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  getSongsDataRaw() async{
    baseServerUrl = await GetStorage().read('serverUrl');
   // var userId = await GetStorage().read('userId');
  //  var uuid = await androidId.getDeviceId();
 //   String deviceId = "PanAudio_${uuid}";
    try {
/*      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'X-MediaBrowser-Token': accessToken,
        'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="$deviceId",Version="10.8.13"'
      };*/
      String url = "$baseServerUrl/api/songs";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  uploadArt(String albumId, File image)async{
    String url = "$baseServerUrl/api/upload-album?albumId=$albumId";
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(url)
    );
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
  //  request.fields['albumId'] = albumId;
    try {
      var response = await request.send();
      if (response.statusCode == 200) {

      } else {

      }
    } catch (e) {

    }
  }

  deleteSongFromPlaylist(String playlistId, String songId)async{
    String url = "$baseServerUrl/api/deleteSong?playlistId=$playlistId&songId=$songId";
    http.Response res = await http.put(Uri.parse(url));
    if (res.statusCode == 200) {
      return true;
    }
  }

  addSongToPlaylist(String playlistId, String songId)async{
    String url = "$baseServerUrl/api/addSong?playlistId=$playlistId&songId=$songId";
    http.Response res = await http.put(Uri.parse(url));
    if (res.statusCode == 200) {
      return true;
    }
  }

  getPlaylists()async{
    try {
    //  var requestHeaders = await apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/api/playlists";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  getPlaylistSongs(String playlistId)async{
    try {
     // var requestHeaders = await apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/api/playlist?playlistId=$playlistId";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFavouriteStatus(String input, bool current) async {

   // String itemId = '${input.substring(0, 8)}-${input.substring(8, 12)}-${input.substring(12, 16)}-${input.substring(16, 20)}-${input.substring(20)}';
  //  var requestHeaders = await apiHelper.returnJellyfinHeaders();
    String url = "$baseServerUrl/api/favourite?songId=$input&favourite=$current";

    http.Response res = await http.post(Uri.parse(url));
    if (res.statusCode == 200) {

    }

  }

  Future<void> updateFavouriteAlbumStatus(String input, bool current) async {

    // String itemId = '${input.substring(0, 8)}-${input.substring(8, 12)}-${input.substring(12, 16)}-${input.substring(16, 20)}-${input.substring(20)}';
    //  var requestHeaders = await apiHelper.returnJellyfinHeaders();
    String url = "$baseServerUrl/api/favourite-album?albumId=$input&favourite=$current";

    http.Response res = await http.post(Uri.parse(url));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }

  }



  Future<void> updateFavouriteArtistStatus(String input, bool current) async {

    // String itemId = '${input.substring(0, 8)}-${input.substring(8, 12)}-${input.substring(12, 16)}-${input.substring(16, 20)}-${input.substring(20)}';
    //  var requestHeaders = await apiHelper.returnJellyfinHeaders();
    String url = "$baseServerUrl/api/favourite-artist?artistId=$input&favourite=$current";

    http.Response res = await http.post(Uri.parse(url));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }else{

    }

  }

  startPlaybackReporting(String songId)async{
    String url = "$baseServerUrl/api/playback/start?songId=$songId";
    http.Response res = await http.put(Uri.parse(url));
    if (res.statusCode == 200) {
      await logger.addToLog(LogModel(logType: "Log", logMessage: "Logged playback for song: $songId. Url: $url", logDateTime: DateTime.now()));
     // return json.decode(res.body);
    }else{
      await logger.addToLog(LogModel(logType: "Error", logMessage: "Error logging playback for song: $songId. Err: ${res.body}", logDateTime: DateTime.now()));
    }
  }
}