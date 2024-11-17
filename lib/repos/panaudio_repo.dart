import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PanaudioRepo{

  String baseServerUrl = "";

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

  addSongToPlaylist(String playlistId, String songId)async{
    String url = "$baseServerUrl/api/addSong?playlistId=$playlistId&songId=$songId";
    http.Response res = await http.put(Uri.parse(url));
    if (res.statusCode == 200) {
      return json.decode(res.body);
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
      return json.decode(res.body);
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
    }

  }

  startPlaybackReporting(String songId)async{
    String url = "$baseServerUrl/api/playback/start?songId=$songId";

    http.Response res = await http.put(Uri.parse(url));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
  }
}